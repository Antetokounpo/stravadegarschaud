import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final brosse = Brosse(drinker: drinker, consommations: consommations, timeStarted: DateTime.now().subtract(duration), duration: duration);
    brossesBox.add(
      brosse.toJson()
    );

    // Temporaire, seulement pour tester Firestore
    var db = FirebaseFirestore.instance;
    var auth = FirebaseAuth.instance;

    db.collection(auth.currentUser!.uid).add(brosse.toJson());

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
  static const metabolicRate = 0.017; // g/100ml per hour

  void setBloodAlcoholContent() {
    if(consommations.isEmpty) {
      bloodAlcoholContent = 0.0;
      return;
    }

    var bac = 0.0;
    var subbed = false;

    var metabolicStartTime = 0.0;
    for(final conso in consommations) {
      // La métabolisation commence lorsqu'on consomme l'alcool ou lorsque qu'on a fini de métaboliser l'alcool consommé antérieurement
      metabolicStartTime = max(conso.timeConsumed.inSeconds.toDouble(), metabolicStartTime);

      var numerator = 0.806*conso.drink.inStandardDrinks;
      var denominator = 1.1*(drinker.sex == Sex.female ? 0.49 : 0.522)*drinker.weight.kilograms;
      var addTerm = numerator/denominator;
      var subTerm = metabolicRate * (duration.inSeconds - metabolicStartTime) / 3600.0;

      if (subTerm < addTerm) {
        bac += addTerm;
        if (!subbed) {
          bac -= subTerm;
          subbed = true;
        }
      }

      metabolicStartTime = (addTerm / metabolicRate * 3600.0 + metabolicStartTime);
    }

    bloodAlcoholContent = bac;
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