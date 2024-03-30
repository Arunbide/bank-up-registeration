import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/firebase_api.dart';

class IntroScreen extends StatelessWidget {
  final getStorage = GetStorage();

  IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: IntroductionScreen(
          globalBackgroundColor: Colors.white,
          scrollPhysics: const BouncingScrollPhysics(),
          pages: [
            PageViewModel(
              titleWidget: const Text(
                "Welcome to BankUP",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              body: "Discover Exclusive Account Opening Bonuses",
              image: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'lib/images/cash-doodles-vector.png',
                      height: 400,
                      width: 400,
                      fit: BoxFit.cover,
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ],
                ),
              ),
            ),
            PageViewModel(
              titleWidget: const Text(
                "Explore Banks Near You",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              body:
                  "Find banks offering bonuses for opening accounts in your location",
              image: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'lib/images/bank-location.png',
                      height: 400,
                      width: 400,
                      fit: BoxFit.cover,
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ],
                ),
              ),
            ),
            PageViewModel(
              titleWidget: const Text(
                "Maximize Your Benefits",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              body: "Easily sort offers from highest to lowest value",
              image: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'lib/images/up-arrow.png',
                      height: 400,
                      width: 400,
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ],
                ),
              ),
            ),
            PageViewModel(
              titleWidget: const Text(
                "Stay Informed",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              body: "Know when offers expire - from earliest to latest",
              image: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'lib/images/calendar.png',
                      height: 400,
                      width: 400,
                      //fit: BoxFit.cover,
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ],
                ),
              ),
            ),
            PageViewModel(
              titleWidget: const Text(
                "Ready to Save? Let's Go!",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              body: "Open accounts with the best bonuses at your fingertips",
              image: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'lib/images/lets-get-started-removebg.png',
                      height: 400,
                      width: 400,
                      fit: BoxFit.cover,
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ],
                ),
              ),
            )
          ],

          // TODO if user is already registered but not subscribed - Move to subscription page
          // TODO if user is already registered and subscribed - Move to landing auth
          // TODO is user is not registered and not subscribed - Register and subscribe
          onDone: () async {
            final prefs = await SharedPreferences.getInstance();
            prefs.setBool('ON_BOARDING', false);
            Navigator.pushNamed(context, "auth");
          },
          onSkip: () async {
            final prefs = await SharedPreferences.getInstance();
            prefs.setBool('ON_BOARDING', false);
            Navigator.pushNamed(context, "auth");
          },
          showSkipButton: true,
          skip: const Text("Skip",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              )),
          back: const Icon(
            Icons.arrow_back,
            color: Colors.green, // Color(0xFF6C63FF)
          ),
          next: const Icon(
            Icons.arrow_forward,
            color: Colors.green, //Color(0xFF6C63FF)
          ),
          done: const Text(
            "Done",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green, //Color(0xFF6C63FF),
            ),
          ),
          dotsDecorator: DotsDecorator(
            size: const Size.square(10.0),
            activeSize: const Size(20.0, 10.0),
            color: Colors.black26,
            activeColor: Colors.green,
            spacing: const EdgeInsets.symmetric(horizontal: 3.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
        ),
      ),
    );
  }
}
