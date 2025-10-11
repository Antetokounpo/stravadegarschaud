import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:stravadegarschaud/services/location_service.dart';

class GeoLocalisation {

  static Future<void> initializeService() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  static Future<void> initializeBackgroundService() async {
    final service = FlutterBackgroundService();

    // Set up the local notification details for the Foreground Service
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', 
      'Location Tracking Service', 
      description: 'This channel is used for location tracking.',
      importance: Importance.high, 
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart, // The entry point function
        autoStart: false, // Start manually after permission is granted
        isForegroundMode: true,
        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'Location Service Active',
        initialNotificationContent: 'App is tracking your location.',
        foregroundServiceNotificationId: 888, // Must be a unique ID
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStart, // Same function for iOS
        onBackground: onStart,
        autoStart: false,
      ),
    );
  }
}