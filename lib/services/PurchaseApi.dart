import 'dart:developer';
import 'dart:io' as IO;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class PurchaseApi {
  static const _googleApiKey = 'goog_BQDXDfOtcvwAjuzIVzXpqyEcMBl';
  static const _appleApiKey = 'appl_rFlJFgxiICitcRdMaXfBVzgPjiF';

  static bool isAndroid = IO.Platform.isAndroid;

  static Future init() async {
    await Purchases.setLogLevel(LogLevel.info);
    PurchasesConfiguration? configuration;
try {
  if (IO.Platform.isAndroid) {
    configuration = PurchasesConfiguration(_googleApiKey);
  } else {
    configuration = PurchasesConfiguration(_appleApiKey);
  }

  if (configuration != null) {
    await Purchases.configure(configuration);
    /*final payWallResult = await RevenueCatUI.presentPaywallIfNeeded(
        "bank-up-pro");
    log('Paywall result: $payWallResult');*/
  }
} catch (e) {
  log('error:$e');
}
  }


  static Future<List<Offering>> fetchOffers() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      return current == null ? [] : [current];
    } on PlatformException catch (e) {
      return [];
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    try{
      await Purchases.purchasePackage(package);
      return true;
    } catch (e) {
      return false;
    }
  }
}