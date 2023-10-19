import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:stravadegarschaud/pages/config_page.dart';

import '../common/drink_data.dart';
import '../models/app_model.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async { // This disables the going back button
        return false;
      },
      child: Scaffold(
          body: SafeArea(
          child: Center(
            child: PageLayout(),
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

    var elapsedSeconds = context.select<AppModel, int>((activity) => activity.duration.inSeconds);

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

    var isRunning = context.select<AppModel, bool>((activity) => activity.isRunning);

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
          var activity = context.read<AppModel>();


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

    var bac = context.select<AppModel, double>((activity) => activity.bloodAlcoholContent);

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
  var activity = context.read<AppModel>();

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
    var drinkDataList = context.watch<AppModel>().drinkDataList;

    return SizedBox(
      height: 250.0,
      child: ListView.separated(
        itemCount: drinkDataList.length+1, // Plus one for the AddDrinkTile
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          if(index == drinkDataList.length) {
            return AddDrinkTile();
          }

          return DrinkTile(drink: drinkDataList.elementAt(index));
        },
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

    var drinkCounts = context.watch<AppModel>().drinkCounts;
    var currentDrinkCount = drinkCounts[drink.name] ?? 0;

    return SizedBox(
        width: 200.0,
        child: ElevatedButton(
          onPressed: () {
            var activity = context.read<AppModel>();
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

// DRY, DrinkTile et AddDrinkTile se répètent. Peut-être à recoder pour les mettre ensemble.
class AddDrinkTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200.0,
      child: ElevatedButton(
        onPressed: () {
          showAddDrinkDialog(context);
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(5.0),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Ajouter drink", style: TextStyle(fontSize: 18.0)),
            Icon(Icons.add, size: 75.0),
          ],
        ),
      ),
    );
  }
}
