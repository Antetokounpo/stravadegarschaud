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
              WeightSetter()
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
        leadingIcon: Icon(Icons.wc_rounded),
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
