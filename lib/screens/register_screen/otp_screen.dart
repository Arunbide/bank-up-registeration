import 'dart:async';

import 'package:bankup/screens/register_screen/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/custom_button.dart';
import '../../services/call_api.dart';
import '../personal_checking_screen/personal_checking_screen.dart';
import '../subscription_screen/subscription_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late String phoneNumber;
  late String verificationId;
  String? otpCode;

  SpinKitRotatingCircle spinkit = SpinKitRotatingCircle(
    color: Colors.white,
    size: 50.0,
  );


  @override
  void initState() {
    _getFromLocal();
    super.initState();
  }

  Future<void> _getFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPhoneNumber = prefs.getString('phoneNumber');
    String? storedVerificationId = prefs.getString('verificationId');
    if (storedPhoneNumber != null && storedVerificationId != null) {
      setState(() {
        phoneNumber = storedPhoneNumber;
        verificationId = storedVerificationId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
            child: SingleChildScrollView(
                child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back),
                  ),
                ),
                Container(
                  width: 200,
                  height: 200,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.shade50,
                  ),
                  child: Image.asset(
                    "lib/images/image2.png",
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Verification",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Enter the OTP send to your phone number",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black38,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Pinput(
                  length: 6,
                  showCursor: true,
                  defaultPinTheme: PinTheme(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.green.shade200,
                      ),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onCompleted: (value) {
                    setState(() {
                      otpCode = value;
                    });
                  },
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: CustomButton(
                    text: "Verify",
                    onPressed: () {
                      if (otpCode != null) {
                        _showLoadingDialog();
                        verifyOtp();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Please enter 6 digit OTP you received")));
                      }
                    },
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Didn't receive any code?",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Resend New Code",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            )),
          ),
        ),
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center (
          child: SpinKitThreeInOut(
            size: 40,
            color: Colors.green,
          ),
        );
      },
    );
  }

  void verifyOtp() async {
    try {
      // Create a PhoneAuthCredential using the verification ID and the entered OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode!,
      );
      // Sign in the user with the credential
      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((credential) async {
        final Map<String, dynamic>? userData;
        if (phoneNumber != "") {
          userData = await getUserByPhone(phoneNumber);
          print('userData: $userData');

          if (null != userData) {
            // User exists, navigate to the home screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (localContext) => SubscriptionPage()),
            );
          } else {
            // User doesn't exist, navigate to the register screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (localContext) => const RegisterScreen(),
              ),
            );
          }
        }
      });
    } catch (e) {
      print('Error verifying OTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error verifying OTP. Please try again.")));
    }
  }
}
