import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../auth.dart';
import '../register_screen/fireBaseAppCheck.dart';
import 'introduction_screen.dart';

class SplashGifScreen extends StatefulWidget {
  const SplashGifScreen({super.key});

  @override
  State<SplashGifScreen> createState() => _SplashGifScreenState();
}

class _SplashGifScreenState extends State<SplashGifScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Lottie.asset("lib/images/green_white_lottie.json")),
            ],
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () async {
      if (await getSharedpreferences()) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => IntroScreen(),
        ));
      } else {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const Auth(),
        ));
      }
    });
  }

  Future<bool> getSharedpreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('ON_BOARDING') ?? true;
  }
}
