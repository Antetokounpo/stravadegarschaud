import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stravadegarschaud/brosse_autosaver.dart';

import 'drink_data.dart';

class ActivityModel extends ChangeNotifier {
  final brossesBox = Hive.box(name: 'brosses');
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

    final brosses = brossesBox.getRange(0, brossesBox.length);
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

  final Drinker drinker = const Drinker(Sex.male, 70);

  var bloodAlcoholContent = 0.0;

  void setBloodAlcoholContent() {
    var firstSip = const Duration(); // première gorgée à 0 seconde
    var bac = 0.0;
    for(final conso in consommations) {
      var numerator = 0.806*conso.drink.inStandardDrinks;
      var denominator = 1.1*(drinker.sex == Sex.female ? 0.49 : 0.522)*drinker.weight;
      var subTerm = 0.0017 * ((duration.inSeconds - firstSip.inSeconds) / 3600.0 + 0.03*(duration.inSeconds - conso.timeConsumed.inSeconds) / 3600.0);

      bac += numerator/denominator - subTerm;

      firstSip = conso.timeConsumed;
    }

    bloodAlcoholContent = bac;
  }

}

class ActivityPage extends StatelessWidget {
  const ActivityPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    // Put page in running mode if the brosse wasn't stopped manually.
    final model = ActivityModel();
    if(BrosseAutosaver.wasRunning) model.toggleRunning();

    return WillPopScope(
      onWillPop: () async { // This disables the going back button
        return false;
      },
      child: Scaffold(
          body: SafeArea(
          child: Center(
            child: ChangeNotifierProvider(
              create: (context) => model,
              child: PageLayout(),
            ),
          ),
        )
      ),
    );
  }
}

class PageLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChronometerCard(),
        CardDivider(),
        BACCard(),
        CardDivider(),
        DrinkAdder(),
        CardDivider(),
        Expanded(child: ToggleButton()), // Expanded seems to center the button vertically
      ],
    );
  }
}

class CardDivider extends StatelessWidget {
  final dividerSidePadding = 12.0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dividerSidePadding),
      child: const Divider(),
    );
  }
}

class ChronometerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    var elapsedSeconds = context.select<ActivityModel, int>((activity) => activity.duration.inSeconds);

    var chronoString = getChronoString(elapsedSeconds);

    return buildChronometerCard(context, chronoString);
  }

  Widget buildChronometerCard(BuildContext context, String chronoString) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium;
    final chronoStyle =
        theme.textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Temps", style: titleStyle),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(chronoString, style: chronoStyle),
        ),
      ],
    );
  }

}


String getChronoString(num elapsedSeconds) {
  var hours = (elapsedSeconds / 3600).floor();
  var minutes = (elapsedSeconds / 60).floor() % 60;
  var seconds = elapsedSeconds.floor() % 60;

  var f = NumberFormat("00", 'fr_CA');
  var formattedMinutes = f.format(minutes);
  var formattedSeconds = f.format(seconds);

  return "$hours:$formattedMinutes:$formattedSeconds";
}

class ToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const buttonSize = 40.0;

    var isRunning = context.select<ActivityModel, bool>((activity) => activity.isRunning);

    Icon buttonIcon;
    if (isRunning) {
      buttonIcon = const Icon(
        Icons.stop,
        size: buttonSize,
      );
    } else {
      buttonIcon = const Icon(
        Icons.play_arrow,
        size: buttonSize,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: FilledButton(
        onPressed: () {
          var activity = context.read<ActivityModel>();


          if(isRunning) {
            showStopConfirmationDialog(context, activity.toggleRunning);
          } else {
            activity.toggleRunning();
          }
        },
        style: FilledButton.styleFrom(
            shape: const CircleBorder(), padding: const EdgeInsets.all(20)),
        child: buttonIcon,
      ),
    );
  }
}

void showStopConfirmationDialog(BuildContext context, void Function() callback) {
  Widget cancelButton = TextButton(
    onPressed: () {
      Navigator.of(context).pop();
    },
    child: const Text('Annuler') 
  );
  Widget confirmButton = TextButton(
    onPressed: (() {
      callback();
      Navigator.of(context).pop();
    }),
    child: const Text("Arrêter brosse"),
  );

  AlertDialog alert = AlertDialog(
    title: const Text("Voulez-vous vraiment arrêter de brosser?"),
    content: const Text("Cette action mettra fin à votre brosse et la sauvergardera. Êtes-vous sûr de vouloir mettre fin à la débauche?"),
    actions: [
      cancelButton,
      confirmButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    }
  );
}


class BACCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium;
    final displayStyle = theme.textTheme.displayMedium;
    final labelStyle = theme.textTheme.labelLarge;

    var bac = context.select<ActivityModel, double>((activity) => activity.bloodAlcoholContent);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Alcoolémie', style: titleStyle),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(getBAC(bac), style: displayStyle),
              Text(
                "g/100 ml de sang",
                style: labelStyle,
              )
            ],
          ),
        ),
      ],
    );
  }

  String getBAC(double bac) {
    var f = NumberFormat("0.00", "fr_CA");

    return f.format(bac);
  }
}

// Ajouter un  ListView pour défiler la liste des drinks
class DrinkAdder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                'Ajouter consommation',
                  style: titleStyle,
              ),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(0.0),
                ),
                onPressed: () {
                  showModifyDialog(context);
                },
                child: const Text("Modifier")
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DrinkList(),
        )
      ],
    );
  }
}

void showModifyDialog(BuildContext context) {
  var activity = context.read<ActivityModel>();

  final dialog = StatefulBuilder(
    builder: ((context, setState) {
      var consommations = activity.consommations.toList(); // This needs to be inside the builder to have the updated contents when dialog is rebuilt

      return SimpleDialog(
        title: const Text("Modifier consos antérieures",),
        children: [
          SizedBox(
            height: 500,
            width: 500,
            child: ListView(
              children: [for (var i = consommations.length - 1; i >= 0; --i) // List in reverse order so that the last conso in on top
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Card(
                    child: ListTile(
                      title: Text("${consommations[i].drink.name} à ${getChronoString(consommations[i].timeConsumed.inSeconds)}"),
                      trailing: FilledButton(
                        onPressed: () {
                          activity.removeConsommation(i);
                          setState(() {}); // Juste pour refresh le dialog
                        },
                        child: const Icon(Icons.delete)
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      );
    })
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
        return dialog;
    }
  );
}

class DrinkList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 250.0,
      child: ListView.separated(
        itemCount: drinkDataList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) => DrinkTile(
          drink: drinkDataList.elementAt(index),
        ),
        separatorBuilder: (BuildContext context, int index) => const SizedBox(
          width: 6.0,
        ),
      ),
    );
  }
}

class DrinkTile extends StatelessWidget {
  const DrinkTile({
    super.key,
    required this.drink,
  });

  final DrinkData drink;

  @override
  Widget build(BuildContext context) {

    var drinkCounts = context.watch<ActivityModel>().drinkCounts;
    var currentDrinkCount = drinkCounts[drink.name] ?? 0;

    return SizedBox(
        width: 200.0,
        child: ElevatedButton(
          onPressed: () {
            var activity = context.read<ActivityModel>();
            if(activity.isRunning) {
              activity.addConsommation(
                Consommation(drink, activity.duration)
              );
            }
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(5.0),
          ),
          child: Column(
            children: [
              Text(drink.name),
              Image(image: AssetImage(drink.imagePath)),
              const Expanded(
                child: SizedBox(),
              ),
              Text(currentDrinkCount.toString())
            ],
          ),
        )
    );
  }
}
