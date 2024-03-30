import 'dart:developer';
import 'dart:io' as io;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
// import 'package:bankup/screens/subscription_screen/paywall.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../services/PurchaseApi.dart';
import '../../services/call_api.dart';
import '../personal_checking_screen/personal_checking_screen.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String payWall='';
  String? storedPhoneNumber;
  CustomerInfo? customerInfo;
  bool _isPro = false;

  @override
  void initState() {
    _configureRevenueCatSDK();
    checkUserSubscription();
    super.initState();
  }

  Future<void> checkUserSubscription() async {
    /*await Purchases.configure(configuration
      ..appUserID = storedPhoneNumber);*/
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      EntitlementInfo? entitlement = customerInfo.entitlements.all[payWall];
      if(entitlement?.isActive ?? false) {
        redirectHomeScreen();
      }
    });
  }

  Future<void> checkStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedPh = prefs.getString('phoneNumber') ?? "";

    setState(() {
      storedPhoneNumber = storedPh;
    });
  }

  Future<void> displayPayWall() async {
      try {
        final payWallResult = await RevenueCatUI.presentPaywallIfNeeded(
            payWall);
        log('Paywall result: $payWallResult');
        Offerings offerings = await Purchases.getOfferings();
        log('Offerings: $offerings');
      } on PlatformException catch (e) {
        log('Error getting Offerings:$e');
      }
  }

  Future<void> _configureRevenueCatSDK() async {
    await Purchases.setLogLevel(LogLevel.info);
    PurchasesConfiguration? configuration;

    if (io.Platform.isAndroid) {
      configuration = PurchasesConfiguration(googleApiKey);
      payWall = googlePayWall;
    } else {
      configuration = PurchasesConfiguration(appleApiKey);
      payWall = applePayWall;
    }
    configuration.appUserID=storedPhoneNumber;

    if( configuration != null ) {
      try {
        await Purchases.configure(configuration
          ..appUserID = storedPhoneNumber);
        customerInfo = await Purchases.getCustomerInfo();
        if (customerInfo?.entitlements.all[payWall] != null && customerInfo?.entitlements.all[payWall]?.isActive == true) {
          if(null != customerInfo?.latestExpirationDate) {
            String? latestExpirationDt = customerInfo?.latestExpirationDate;
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('latestExpirationDt', latestExpirationDt!);
          }
          redirectHomeScreen();
        }
        final payWallResult = await RevenueCatUI.presentPaywallIfNeeded(
            payWall);


        log('Paywall result: $payWallResult');
        Offerings offerings = await Purchases.getOfferings();
        log('Offerings: $offerings');
      } on PlatformException catch (e) {
        log('Error getting Offerings:$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Center(
                  ),
                ),
              ],
            ),
          ),
        );
  }

    /*if (customerInfo.entitlements.all[payWall] != null && customerInfo.entitlements.all[payWall]?.isActive == true) {
      if(null != customerInfo.latestExpirationDate) {
        String? latestExpirationDt = customerInfo.latestExpirationDate;
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('latestExpirationDt', latestExpirationDt!);
      }
      redirectHomeScreen();
    } else {
      try {
        final payWallResult = await RevenueCatUI.presentPaywallIfNeeded(
            payWall);
        log('Paywall result: $payWallResult');
        Offerings offerings = await Purchases.getOfferings();
        log('Offerings: $offerings');
      } on PlatformException catch (e) {
        log('Error getting Offerings:$e');
      }
    }
  }*/

  void redirectHomeScreen() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PersonalCheckingScreen()));
  }
  }
