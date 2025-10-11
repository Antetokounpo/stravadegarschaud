// lib/service/location_service.dart

import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

// The entry point for the background isolate
@pragma('vm:entry-point')
Future<bool> onStart(ServiceInstance service) async {
  // Dart background isolate initialization
  DartPluginRegistrant.ensureInitialized();

  // Configure location settings
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation, // TEMP: to change wrt to battery usage
    distanceFilter: 0, // Update every 10 meters
  );

  // Subscribe to the position stream
  StreamSubscription<Position>? positionSubscription =
      Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
    // Example: Print and update the notification to show activity
    print('BACKGROUND LOCATION: ${position.latitude}, ${position.longitude}');

    // Update the notification (part of the Foreground Service requirement)
    service.invoke(
      'update',
      position.toJson(),
    );

  }, onError: (e) {
    print('Location Stream Error: $e');
  });

  // Listener to stop the service when commanded
  service.on('stop').listen((event) {
    positionSubscription?.cancel();
    service.stopSelf();
  });

  return true;
}