import 'dart:developer';

import 'package:bankup/screens/register_screen/otp_screen.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';
import '../personal_checking_screen/personal_checking_screen.dart';
import '../subscription_screen/subscription_screen.dart';

class RegisterScreenPhone extends StatefulWidget {
  const RegisterScreenPhone({super.key});

  @override
  State<RegisterScreenPhone> createState() => _RegisterScreenPhoneState();
}

class _RegisterScreenPhoneState extends State<RegisterScreenPhone> {
  final TextEditingController phoneController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;
  bool isButtonEnabled = false;
  Country selectedCountry = Country(
    phoneCode: "1",
    countryCode: "US",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "US",
    example: "USA",
    displayName: "USA",
    displayNameNoCountryCode: "USA",
    e164Key: "",
  );

  @override
  Widget build(BuildContext context) {
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: phoneController.text.length,
      ),
    );
    return WillPopScope(
        onWillPop: () async {
          // Show an exit confirmation dialog
          bool exitConfirmed = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Do you wish to exit?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Stay in HomeScreen
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Exit the app
                  },
                  child: const Text('Yes'),
                ),
              ],
            ),
          );
          return exitConfirmed;
        },
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
                  child: Column(
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.shade50,
                        ),
                        child: Image.asset(
                          "lib/images/signup.png",
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Login/Register",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Add your phone number. We'll send you a verification code",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black38,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        cursorColor: Colors.green,
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        onChanged: (value) {
                          setState(() {
                            phoneController.text = value;
                            isButtonEnabled = value.length == 10;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Enter phone number",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.green),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.green),
                          ),
                          prefixIcon: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                showCountryPicker(
                                    context: context,
                                    countryListTheme:
                                        const CountryListThemeData(
                                      bottomSheetHeight: 550,
                                    ),
                                    onSelect: (value) {
                                      setState(() {
                                        selectedCountry = value;
                                      });
                                    });
                              },
                              child: Text(
                                "${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          suffixIcon: phoneController.text.length > 9
                              ? Container(
                                  height: 30,
                                  width: 30,
                                  margin: const EdgeInsets.all(10.0),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                  child: const Icon(
                                    Icons.done,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              isButtonEnabled ? () => signInWithPhone(
                                  "+${selectedCountry.phoneCode}${phoneController.text.trim()}"
                              ) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isButtonEnabled ? Colors.green : Colors.grey,
                          ),
                          child: const Text("Login/Register"),
                        ),
                      ),
                      isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SpinKitThreeInOut(
                                size: 40,
                                color: Colors.green,
                              )
                              /*CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.green)),*/
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Future<void> _saveToLocal(String phoneNumber, String verificationId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', phoneNumber);
    await prefs.setString('verificationId', verificationId);
  }

  Future<String> getToken() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final appCheck = await Firebase.initializeApp();
    return appCheck.options.apiKey;
  }


  Future<void> signInWithPhone(String phoneNumber) async {
    setState(() {
      isLoading = true;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          setState(() {
            isLoading = false;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SubscriptionPage()),
          );
        },
        verificationFailed: (FirebaseAuthException error) {
          log('Verification failed: $error');
          // throw Exception(error.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          _saveToLocal(phoneNumber,verificationId);
          // Navigate to the verification code screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OtpScreen(),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          log('Auto-retrieval timed out: $verificationId');
        },
      );
    } catch (e) {
      log('Error: $e');
    }
  }
}
