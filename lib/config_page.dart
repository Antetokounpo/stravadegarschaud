import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:stravadegarschaud/drink_data.dart';

class ConfigModel extends ChangeNotifier {
  final configBox = Hive.box(name: 'config');

  Drinker get drinker => Drinker.fromJson(configBox.get('drinker', defaultValue: const Drinker(Sex.male, 0).toJson()));
  
  void setSex(Sex sex) {
    configBox['drinker'] = Drinker(sex, drinker.weight);
    notifyListeners();
  }

  void setWeight(int weight) {
    print(weight);
    configBox['drinker'] = Drinker(drinker.sex, weight);
    notifyListeners();
  }
}

class ConfigPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ChangeNotifierProvider(
            create: (context) => ConfigModel(),
            child: Column(
              children: [
                SexSelector(),
                WeightSetter()
              ],
            ),
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
    var config = context.watch<ConfigModel>();

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
    var config = context.watch<ConfigModel>();

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
