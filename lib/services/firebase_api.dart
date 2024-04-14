import 'package:bankup/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  // Create an instance of Firebase messaging
  static final _firebaseMessaging = FirebaseMessaging.instance;

  // function to initialize notifications
  static Future init() async {
    // Request permission from user
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    // _firebaseMessaging.subscribeToTopic('user_geolocation_topic');
    //fetch the FCM token for this device
    await _firebaseMessaging.setAutoInitEnabled(true);
    final fCMToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fCMToken');
  }

  void handleNotification(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushReplacementNamed("auth");
  }

  Future initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(handleNotification);
  }
}
