import 'dart:async';

import 'package:geolocator/geolocator.dart';


class GeoLocalisation {

  static Future<void> initializeService() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  static Stream<Position> getPositionStream()
  {
    return  Geolocator.getPositionStream(locationSettings: 
    AndroidSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 8,
      forceLocationManager: true,
      intervalDuration: const Duration(seconds: 5),
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationTitle: "Running in background", 
        notificationText: "Brosse en cours")
    ));   
  }

}