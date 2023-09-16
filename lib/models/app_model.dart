import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stravadegarschaud/common/brosse_autosaver.dart';

import '../common/drink_data.dart';


class AppModel extends ChangeNotifier {
  final brossesBox = Hive.box(name: 'brosses');
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
    brossesBox.add(
      Brosse(drinker: drinker, consommations: consommations).toJson()
    );

    final brosses = brossesBox.getRange(0, brossesBox.length); // getAll marchait pas je crois
    Share.share(json.encode(brosses));
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

  void setBloodAlcoholContent() {
    var firstSip = const Duration(); // première gorgée à 0 seconde
    var bac = 0.0;
    var subbed = false;

    for(final conso in consommations) {
      var numerator = 0.806*conso.drink.inStandardDrinks;
      var denominator = 1.1*(drinker.sex == Sex.female ? 0.49 : 0.522)*drinker.weight;
      var addTerm = numerator/denominator;
      var subTerm = 0.0017 * ((duration.inSeconds - firstSip.inSeconds) / 3600.0 + 0.03*(duration.inSeconds - conso.timeConsumed.inSeconds) / 3600.0);

      if (subTerm < addTerm) {
        bac += addTerm;
      } 
      if (!subbed) {
        bac -= subTerm;
        subbed = true;
      }

      firstSip = conso.timeConsumed;
    }

    bloodAlcoholContent = bac;
  }

  Drinker get drinker => Drinker.fromJson(configBox.get('drinker', defaultValue: const Drinker(Sex.male, 0).toJson()));
  
  void setSex(Sex sex) {
    configBox['drinker'] = Drinker(sex, drinker.weight);
    setBloodAlcoholContent();
    notifyListeners();
  }

  void setWeight(int weight) {
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