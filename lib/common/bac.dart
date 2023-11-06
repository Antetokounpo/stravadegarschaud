import 'dart:math';
import 'package:stravadegarschaud/common/drink_data.dart';

class BAC {
  static const metabolicRate = 0.017; // g/100ml per hour

  final Drinker drinker;
  final List<Consommation> consommations;

  BAC({
    required this.drinker,
    required this.consommations
  });

  double getAlcoholContent(Duration time) {
    var bac = 0.0;
    var subbed = false;

    var metabolicStartTime = 0.0;
    for(final conso in consommations) {
      // La métabolisation commence lorsqu'on consomme l'alcool ou lorsque qu'on a fini de métaboliser l'alcool consommé antérieurement
      metabolicStartTime = max(conso.timeConsumed.inSeconds.toDouble(), metabolicStartTime);

      var numerator = 0.806*conso.drink.inStandardDrinks;
      var denominator = 1.1*(drinker.sex == Sex.female ? 0.49 : 0.522)*drinker.weight.kilograms;
      var addTerm = numerator/denominator;
      var subTerm = metabolicRate * (time.inSeconds - metabolicStartTime) / 3600.0;

      if (subTerm < addTerm) {
        bac += addTerm;
        if (!subbed) {
          bac -= subTerm;
          subbed = true;
        }
      }

      metabolicStartTime = (addTerm / metabolicRate * 3600.0 + metabolicStartTime);
    }

    return bac;
  }
}