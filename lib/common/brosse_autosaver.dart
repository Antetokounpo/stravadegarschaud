import 'package:geolocator/geolocator.dart';
import 'package:hive_ce/hive.dart';
import 'package:stravadegarschaud/common/drink_data.dart';

class BrosseAutosaver {
  static final currentBrosseBox = Hive.box('current_brosse');

  static void saveCurrentBrosse({
    required List<Consommation> consommations,
    required Map<String, int> drinkCounts,
    required Duration duration,
    required DateTime timeLastUpdate,
    required List<Position> trajectory,
  }) {
    currentBrosseBox.put('consommations', consommations.map((e) => e.toJson()).toList());
    currentBrosseBox.put('drinkCounts', drinkCounts);
    currentBrosseBox.put('duration', duration.inSeconds);
    currentBrosseBox.put('timeLastUpdate', timeLastUpdate.millisecondsSinceEpoch);
    currentBrosseBox.put('wasRunning', true);
    currentBrosseBox.put('trajectory', trajectory.map((p) => p.toJson()).toList());
  }

  static List<Consommation> get consommations {
    return currentBrosseBox.get('consommations', defaultValue: []).map<Consommation>((e) => Consommation.fromJson(e)).toList();
  }

  static Map<String, int> get drinkCounts {
    // Empty map because we already check for null keys when we use it.
    // On met '' en clé pour le type sinon ça marche pas. On l'enlève après, mais il y a sûrement un meilleur moyen de faire ça haha
    //Map<dynamic, dynamic> value = currentBrosseBox.get('drinkCounts', defaultValue: {});
    //value.remove('');

    // On veut retourner Map<String, int> et non Map<String, dynamic>. Ça marche avec ce .map, mais je sais pas pourquoi
    //Map<String, int> return_value = value.map((key, value) => MapEntry(key as String, value as int));

    return Map<String, int>.from(currentBrosseBox.get('drinkCounts', defaultValue: {}));
  }

  static Duration get duration {
    var timeElapsed = DateTime.now().difference(timeLastUpdate);

    return Duration(seconds: currentBrosseBox.get('duration', defaultValue: 0)) + timeElapsed;
  }

  static DateTime get timeLastUpdate {
    return DateTime.fromMillisecondsSinceEpoch(currentBrosseBox.get('timeLastUpdate', defaultValue: DateTime.now().millisecondsSinceEpoch));
  }

  static bool get wasRunning { 
    final value = currentBrosseBox.get('wasRunning', defaultValue: false);
    currentBrosseBox.put('wasRunning', false);

    return value;
  }

  static List<Position> get trajectory {
    return currentBrosseBox.get('trajectory', defaultValue: []).map<Position>((p) => Position.fromMap(p)).toList();
  }

  static void resetCurrentBrosse() {
    currentBrosseBox.delete('consommations');
    currentBrosseBox.delete('drinkCounts');
    currentBrosseBox.delete('duration');
    currentBrosseBox.delete('timeLastUpdate');
    currentBrosseBox.put('wasRunning', false);
    currentBrosseBox.delete('trajectory');
  }
}
