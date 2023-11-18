import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stravadegarschaud/common/bac.dart';

import 'package:stravadegarschaud/common/brosse_autosaver.dart';
import 'package:stravadegarschaud/common/db_commands.dart';
import '../common/drink_data.dart';


class AppModel extends ChangeNotifier {
  //final brossesBox = Hive.box(name: 'brosses');
  final configBox = Hive.box(name: 'config');
  final consosBox = Hive.box(name: 'consos');
  final currentBrosseBox = BrosseAutosaver.currentBrosseBox;

  var _isRunning = false;

  bool get isRunning => _isRunning;

  void toggleRunning() {
    _isRunning = !_isRunning;
    
    if(_isRunning) {
      startTimer();
      setBloodAlcoholContent();
    } else {
      stopTimer();
      BrosseAutosaver.resetCurrentBrosse();
      saveBrosse();
      resetTimer();
      resetConsommations();
    }

    notifyListeners();
  }

  Duration duration = BrosseAutosaver.duration;
  DateTime? timeLastUpdate;

  Timer? timer;

  void startTimer() {
    timeLastUpdate = DateTime.now();
    timer = Timer.periodic(const Duration(milliseconds: 500), (timer) => addTime());
  }

  void addTime() {
    var now = DateTime.now();
    var timeDiff = now.difference(timeLastUpdate!);
    timeLastUpdate = now;

    duration = duration + timeDiff;

    autoSaveBrosse();

    if(duration.inSeconds % 60 == 0)  setBloodAlcoholContent();
    notifyListeners();
  }

  void stopTimer() {
    timer?.cancel();
    notifyListeners();
  }

  void resetTimer() {
    duration = const Duration();
    notifyListeners();
  }

  void saveBrosse() {
    final brosse = Brosse(drinker: drinker, consommations: consommations, timeStarted: DateTime.now().subtract(duration), duration: duration);
    //brossesBox.add(
    //  brosse.toJson()
    //);

    Database.addBrosse(brosse, Database.auth.currentUser!.uid);
  }

  void autoSaveBrosse() {
    BrosseAutosaver.saveCurrentBrosse(
      consommations: consommations,
      drinkCounts: drinkCounts,
      duration: duration,
      timeLastUpdate: timeLastUpdate!
    );
  }

  List<Consommation> consommations = BrosseAutosaver.consommations;
  Map<String, int> drinkCounts = BrosseAutosaver.drinkCounts;
  
  void addConsommation(Consommation conso) {
    consommations.add(conso);
    drinkCounts[conso.drink.name] = (drinkCounts[conso.drink.name] ?? 0) + 1;

    autoSaveBrosse();
    setBloodAlcoholContent();
    notifyListeners();
  }

  void removeConsommation(int index) {
    drinkCounts[consommations[index].drink.name] = (drinkCounts[consommations[index].drink.name] ?? 0) - 1;
    consommations.removeAt(index);

    autoSaveBrosse(); 
    setBloodAlcoholContent();
    notifyListeners();
  }

  void resetConsommations() {
    consommations = [];
    drinkCounts = {for(final drink in drinkDataList) drink.name : 0};
    setBloodAlcoholContent();
    notifyListeners();
  }

  var bloodAlcoholContent = 0.0;
  static const metabolicRate = 0.017; // g/100ml per hour

  void setBloodAlcoholContent() {
    if(consommations.isEmpty) {
      bloodAlcoholContent = 0.0;
      return;
    }

    bloodAlcoholContent = BAC(drinker: drinker, consommations: consommations).getAlcoholContent(duration);
  }

  Drinker get drinker => Drinker.fromJson(configBox.get('drinker', defaultValue: const Drinker(Sex.male, Weight(0)).toJson()));
  
  void setSex(Sex sex) {
    configBox['drinker'] = Drinker(sex, drinker.weight);
    setBloodAlcoholContent();
    notifyListeners();
  }

  void setWeight(Weight weight) {
    configBox['drinker'] = Drinker(drinker.sex, weight);
    setBloodAlcoholContent();
    notifyListeners();
  }

  List<DrinkData>? _drinkDataList;

  List<DrinkData> get drinkDataList {
    _drinkDataList ??= consosBox.getRange(0, consosBox.length).map(((e) => DrinkData.fromJson(e))).toList();

    return _drinkDataList!;
  }

  void addDrink(DrinkData drink) {
    consosBox.add(drink);
    drinkDataList.add(drink); // Is drinkDataList a reference?
    notifyListeners();
  }

  void removeDrink(int index) {
    drinkDataList.removeAt(index);
    consosBox.deleteAt(index);
    notifyListeners();
  }

  void modifyDrink(DrinkData drink, int index) {
    consosBox.putAt(index, drink);
    drinkDataList[index] = drink;
    notifyListeners();
  }
}