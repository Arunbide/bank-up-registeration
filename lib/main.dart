
import 'dart:io' show Platform;
import 'dart:developer';

import 'package:bankup/screens/auth.dart';
import 'package:bankup/screens/business_checking_screen/business_checking_screen.dart';
import 'package:bankup/screens/personal_checking_screen/personal_checking_screen.dart';
import 'package:bankup/screens/introduction_screen/splash_gif_screen.dart';
import 'package:bankup/screens/register_screen/fireBaseAppCheck.dart';
import 'package:bankup/screens/register_screen/register_screen_phone.dart';
import 'package:bankup/screens/subscription_screen/subscription_screen.dart';
import 'package:bankup/services/PurchaseApi.dart';
import 'package:bankup/services/firebase_api.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purchases_flutter/models/purchases_configuration.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options_bkp.dart';

const kWebRecaptchaSiteKey = '064DD31E-B553-4E01-A8D8-E43E9D35CDA1';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print('notification received');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  FirebaseApi.init();
  // await Permission.location.serviceStatus.isEnabled;
  var status = await Permission.location.request();
  if(status == PermissionStatus.granted) {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('LOCATION_ACCESS_GRANTED', true);
  }
  // FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (context) => const SplashGifScreen(),
        // "FirebaseAppCheckExample": (context) => FirebaseAppCheckExample(),
        "subscription": (context) => SubscriptionPage(),
        "auth": (context) => const Auth(),
        "login": (context) => const RegisterScreenPhone(),
        "/personal_checking_offer": (context) => const PersonalCheckingScreen(),
        "/business_checking_offer": (context) => const BusinessCheckingScreen(),
      },
    );
  }
}
