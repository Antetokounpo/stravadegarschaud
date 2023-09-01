
class DrinkData {
  final String name;
  final String imagePath;
  final double abv;
  final double volume;

  double get inStandardDrinks {
    return volume*abv / 17.7; // Standard drink is 17.7 ml in the US
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

class Drinker {
  final Sex sex;
  final double weight;

  const Drinker(this.sex, this.weight);

  Map<String, dynamic> toJson() => {
    'sex': sex == Sex.male,
    'weight': weight
  };

  factory Drinker.fromJson(Map<String, dynamic> json) => Drinker(
    json['sex'] ? Sex.male : Sex.female,
    json['weight'] as double,
  );
}

class Brosse {
  final Drinker drinker;
  final List<Consommation> consommations;

  const Brosse({required this.drinker, required this.consommations});


  Map<String, dynamic> toJson() => {
    'drinker': drinker.toJson(),
    'consommations': consommations.map((e) => e.toJson()).toList(),
  };

  factory Brosse.fromJson(Map<String, dynamic> json) => Brosse(
    drinker: Drinker.fromJson(json['drinker']),
    consommations: json['consommations'].map((e) => Consommation.fromJson(e)).toList()
  );
}
