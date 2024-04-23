import 'dart:developer';
import 'dart:io' as io;
import 'dart:io';
import 'package:bankup/screens/ad_screen/PromotionalAdScreen.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';


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
    super.initState();
    // Call checkUserSubscription to verify subscription status first
    checkUserSubscription();
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
        } else {
          showSubscriptionPopup();
        }
      } on PlatformException catch (e) {
        log('Error getting Offerings:$e');
      }
    }
  }

  Future<void> showSubscriptionPopup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            showSubscriptionPopup();
            return false;
          },
          child: AlertDialog(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Subscription Required',
                style: TextStyle(color: Colors.black, fontSize: 22.0),
              ),
            ),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      'You need a subscription to access this feature.',
                      style: TextStyle(color: Colors.black, fontSize: 17.0),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF243407)),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                child: const Text('Exit Without Subscribing'),
                onPressed: () {
                  Navigator.of(context).pop();
                  exit(1);
                },
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF243407)),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                child: const Text('Subscribe'),
                onPressed: () {
                  Navigator.of(context).pop();
                  displayPayWall();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> displayPayWall() async {
    try {
      await RevenueCatUI.presentPaywallIfNeeded(
          payWall);

      checkUserSubscription();
    } on PlatformException catch (e) {
      log('Error getting Offerings:$e');
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

  void redirectHomeScreen() async {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PromotionalAdScreen()));
  }

  Future<void> checkUserSubscription() async {
    await _configureRevenueCatSDK(); // Call configuration
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      EntitlementInfo? entitlement = customerInfo.entitlements.all[payWall];
      if(entitlement?.isActive ?? false) {
        redirectHomeScreen();
      } else {
        showSubscriptionPopup();
      }
    });
  }
}
