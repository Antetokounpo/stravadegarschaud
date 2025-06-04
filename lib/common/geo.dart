import 'package:geolocator/geolocator.dart';

class GeoLocalisation {

  static void initializeService() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

}