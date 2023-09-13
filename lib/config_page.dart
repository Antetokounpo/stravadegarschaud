import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stravadegarschaud/drink_data.dart';

import 'app_model.dart';

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
  final List<Sex> sexList = [Sex.male, Sex.female];

  @override
  Widget build(BuildContext context) {
    var config = context.watch<AppModel>();

    return DropdownButton<Sex>(
      value: config.drinker.sex,
      items: sexList.map((value) => 
        DropdownMenuItem<Sex>(
          value: value,
          child: Text(sexToString(value)),
        )
      ).toList(),
      onChanged: (value) {
        config.setSex(value!);
      },
    );
  }

  String sexToString(Sex sex) {
    return sex == Sex.male ? "Homme" : "Femme";
  }
}

class WeightSetter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var config = context.watch<AppModel>();

    return TextFormField(
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
    );
  }
}
