import 'package:bankup/screens/personal_checking_screen/personal_checking_screen.dart';
import 'package:bankup/screens/register_screen/register_screen.dart';
import 'package:bankup/screens/register_screen/register_screen_phone.dart';
import 'package:bankup/screens/subscription_screen/subscription_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/call_api.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  late String storedPhoneNumber = "";
  dynamic userData;

  @override
  void initState() {
    super.initState();
    checkStoredData();
  }

  Future<void> checkStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    storedPhoneNumber = prefs.getString('phoneNumber') ?? "";

    if (storedPhoneNumber.isNotEmpty) {
      userData = await getUserByPhone(storedPhoneNumber);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (storedPhoneNumber.isEmpty || userData == null) {
            return const RegisterScreen();
          } else {
            return SubscriptionPage();
          }
        },
      ),
    );
  }
}
