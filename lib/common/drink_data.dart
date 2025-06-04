
import 'package:geolocator/geolocator.dart';

class DrinkData {
  final String name;
  final String imagePath;
  final double abv;
  final double volume;

  double get inStandardDrinks {
    return volume*abv / 15.0; // Standard drink is 17.7 ml in the US, 15 ml in most other countries
  }

  const DrinkData(this.name, this.imagePath, this.abv, this.volume);

  factory DrinkData.fromJson(Map<String, dynamic> json) => DrinkData(
    json['name'],
    json['imagePath'],
    json['abv'],
    json['volume']
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'imagePath': imagePath,
    'abv': abv,
    'volume': volume
  };
}

const drinkTypeImagePath = {
  'Bière': "assets/beer.png",
  'Vin': "assets/vin.png",
  'Cocktail': "assets/cocktail.png",
  'Shot': "assets/shot.png",
  'Sangria': "assets/sangria.png",
  'Autre': "assets/iceberg.png",
};

const drinkVolumes = {
  'Pinte': "568",
  'Shot': "30",
  'Verre': "341"
};

/*
const drinkDataList = {
  DrinkData("Bleue Dry 10.1%", "assets/bleue dry.png", 0.101, 1180),
  DrinkData("Quillosa", "assets/quillosa.png", 0.101/2, 1180),
  DrinkData("Verre de vin", "assets/vin.png", 0.12, 150),
  DrinkData("El Pepito (verre de 150 ml)", "assets/pepito.png", 0.069, 150),
  DrinkData("Belle Mer", "assets/bellemer.png", 0.068, 355),
  DrinkData("Rhum (shooter)", "assets/captainmorgan.png", 0.35, 40),
  DrinkData("Tequila (shooter)", "assets/tequila.png", 0.40, 40),
  DrinkData("Vodka (shooter)", "assets/vodka.png", 0.40, 40),
  DrinkData("Gin (shooter)", "assets/gin.png", 0.45, 40),
  DrinkData("Iceberg", "assets/iceberg.png", 0.12, 500),
  DrinkData("19 Crimes", "assets/19crimes.webp", 0.145, 750),
  DrinkData("Chartreuse jaune", "assets/chartreuse.webp", 0.43, 750),
  DrinkData("Joint", "assets/joint.png", 0, 0)
};
*/

class Consommation {
  final Duration timeConsumed;
  final DrinkData drink;

  const Consommation(this.drink, this.timeConsumed);

  Map<String, dynamic> toJson() => {
    'timeConsumed': timeConsumed.inSeconds,
    'drink': drink.toJson()
  };

  factory Consommation.fromJson(Map<String, dynamic> json) => Consommation(
    DrinkData.fromJson(json['drink'] as Map<String, dynamic>),
    Duration(seconds: json['timeConsumed']),
  );
}

enum Sex {
  male,
  female
}

enum WeightUnit {
  kg,
  lbs
}

class Weight {
  final WeightUnit unit;
  final int weight;

  const Weight(this.weight, [this.unit = WeightUnit.kg]);

  Map<String, dynamic> toJson() => {
    'unit': unit.index,
    'weight': weight
  };

  factory Weight.fromJson(Map<String, dynamic> json) => Weight(
    json['weight'] as int,
    WeightUnit.values[json['unit'] as int]
  );

  int get kilograms {
    if(unit == WeightUnit.lbs) {
      return (0.453592*weight).round();
    }

    return weight;
  }

}

class Drinker {
  final Sex sex;
  final Weight weight;

  const Drinker(this.sex, this.weight);

  Map<String, dynamic> toJson() => {
    'sex': sex == Sex.male,
    'weight': weight.toJson()
  };

  factory Drinker.fromJson(Map<String, dynamic> json) => Drinker(
    json['sex'] ? Sex.male : Sex.female,
    Weight.fromJson(json['weight']),
  );
}

class Brosse {
  final Drinker drinker;
  final List<Consommation> consommations;
  final DateTime timeStarted;
  final Duration duration;
  final List<Position> trajectory;

  const Brosse({
    required this.drinker,
    required this.consommations,
    required this.timeStarted,
    required this.duration,
    required this.trajectory,
    });


  Map<String, dynamic> toJson() => {
    'drinker': drinker.toJson(),
    'consommations': consommations.map((e) => e.toJson()).toList(),
    'timeStarted': timeStarted.millisecondsSinceEpoch,
    'duration': duration.inMilliseconds,
    'trajectory': trajectory.map((p) => p.toJson()).toList(),
  };

  factory Brosse.fromJson(Map<String, dynamic> json) => Brosse(
    drinker: Drinker.fromJson(json['drinker']),
    consommations: json['consommations'].map<Consommation>((e) => Consommation.fromJson(e)).toList(),
    timeStarted: DateTime.fromMillisecondsSinceEpoch(json['timeStarted']),
    duration: Duration(milliseconds: json['duration']),
    trajectory: json['trajectory'].map<Position>((p) => Position.fromMap(p)).toList(),
  );
}

// This goes directly to Firestore
class Activity {
  final Brosse brosse;
  final String userId;
  final String title;
  final String activityId; // Same ID as the one on Firestore

  const Activity({
    required this.brosse,
    required this.userId,
    required this.title,
    required this.activityId,
  });

  Map<String, dynamic> toJson() => {
    'brosse' : brosse.toJson(),
    'userId' : userId,
    'title' : title,
  };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    brosse: Brosse.fromJson(json['brosse']),
    userId: json['userId'],
    title: json['title'],
    activityId: json['activityId'],
  );
}
