import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stravadegarschaud/common/drink_data.dart';

import '../models/app_model.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SexSelector(),
              WeightSetter(),
              Expanded(child: ConsosModifier()),
            ],
          )
        ),
      ),
    );
  }
}


class SexSelector extends StatelessWidget {
  static const entries = [
    DropdownMenuEntry(value: Sex.male, label: "Homme"),
    DropdownMenuEntry(value: Sex.female, label: "Femme"),
  ];

  @override
  Widget build(BuildContext context) {
    var config = context.watch<AppModel>();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: DropdownMenu<Sex>(
        initialSelection: config.drinker.sex,
        dropdownMenuEntries: entries,
        label: const Text("Sexe"),
        leadingIcon: const Icon(Icons.wc_rounded),
        onSelected: (value) {
          if (value != null) config.setSex(value);
        },
      ),
    );
  }
}

class WeightSetter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var config = context.watch<AppModel>();

    return SizedBox(
      width: 170,
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: "Poids (kg)"
        ),
        onChanged: ((value) {
          try {
            config.setWeight(int.parse(value));
          } catch (e) {} // If invalid value, just don't save it
        }),
        keyboardType: TextInputType.number,
        initialValue: config.drinker.weight.toString(),
      ),
    );
  }
}

class ConsosModifier extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Text("Liste des drinks", style: titleStyle,),
              const Spacer(),
              TextButton(
                onPressed: () {
                  showAddDrinkDialog(context);
                },
                child: const Icon(Icons.add_box_rounded),
              ),
            ],
          ),
          ConsosList(),
        ],
      ),
    );
  }
}

class AddDrinkForm extends StatefulWidget {
  const AddDrinkForm({
    super.key,
    required this.name,
    required this.volume,
    required this.abv,
  });

  final String name;
  final String volume;
  final String abv; 

  @override
  State<AddDrinkForm> createState() => _AddDrinkFormState();
}

class _AddDrinkFormState extends State<AddDrinkForm> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController? nameController;
  TextEditingController? volumeController;
  TextEditingController? abvController;

  @override
  void dispose() {
    nameController?.dispose();
    volumeController?.dispose();
    abvController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    nameController = TextEditingController(text: widget.name);
    volumeController = TextEditingController(text: widget.volume);
    abvController = TextEditingController(text: widget.abv);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Nom du drink",
              ),
              validator: (value) {
                if(value == null || value.isEmpty)
                  return "Entrez un nom";
                return null;
              },
              controller: nameController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Volume du drink (en ml)",
              ),
              validator: (value) {
                if(value == null || value.isEmpty)
                  return "Entrez un volume";
                return null;
              },
              keyboardType: TextInputType.number,
              controller: volumeController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Degré du drink (en % d'alcool)",
              ),
              validator: (value) {
                if(value == null || value.isEmpty) {
                  return "Entrez un pourcentage";
                } else if(double.parse(value) < 0.0 || double.parse(value) > 100.0) {
                  return "Entrez une valeur entre 0 et 100 %";
                }
                return null;
              },
              keyboardType: TextInputType.number,
              controller: abvController,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Row(
                children: [
                  TextButton(
                    onPressed: (() {
                      Navigator.of(context).pop();
                    }),
                    child: const Text("Annuler"),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        String name = nameController!.text;
                        double volume = double.parse(volumeController!.text);
                        double abv = double.parse(abvController!.text) / 100.0;
                
                        var appModel = context.read<AppModel>();
                        appModel.addDrink(DrinkData(name, "assets/iceberg.png", abv, volume));
                
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text("Ajouter"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

void showAddDrinkDialog(BuildContext context, {name = "", volume = "", abv = "",}) {

  final dialog = StatefulBuilder(
    builder: ((context, setState) {

      return SimpleDialog(
        title: const Text("Ajouter nouveau drink",),
        children: [
          AddDrinkForm(name: name, volume: volume.toString(), abv: (abv*100).toString())
        ],
      );
    })
  );

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
        return dialog;
    }
  );
}

class ConsosList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    var appModel = context.watch<AppModel>();
    var drinkDataList = appModel.drinkDataList;

    return SizedBox(
      width: 350.0,
      height: 450.0,
      child: ListView.builder(
        itemCount: drinkDataList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Row(
              children: [
                Text(drinkDataList[index].name),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilledButton(
                    onPressed: () {
                      appModel.removeDrink(index);
                    },
                    child: const Icon(Icons.delete),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    final name = drinkDataList[index].name;
                    final volume = drinkDataList[index].volume;
                    final abv = drinkDataList[index].abv;

                    showAddDrinkDialog(context, name: name, volume: volume, abv: abv);
                  },
                  child: const Icon(Icons.edit),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
