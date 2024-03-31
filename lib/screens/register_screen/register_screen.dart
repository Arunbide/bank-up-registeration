import 'package:bankup/screens/register_screen/register_screen_phone.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/call_api.dart';
import '../personal_checking_screen/personal_checking_screen.dart';
import '../subscription_screen/subscription_screen.dart';

final _formKey = GlobalKey<FormState>();

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late String phoneNumber = '0000000000';
  late String verificationId;

  bool isFirstNameValid = false;
  bool isLastNameValid = false;
  bool isEmailValid = false;
  bool isPhoneNumberValid = false;

  bool get isFormValid =>
      isFirstNameValid && isLastNameValid && isEmailValid && isPhoneNumberValid;

  @override
  void initState() {
    super.initState();
    // Get phoneNumber from local storage when the screen is initialized
    _getFromLocal();
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

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordMatchController = TextEditingController();
  final TextEditingController fnController = TextEditingController();
  final TextEditingController lnController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  void dispose() {
    fnController.dispose();
    lnController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  void validateName(String text, {bool isFirstName = true}) {
    setState(() {
      if (isFirstName) {
        isFirstNameValid = text.isNotEmpty;
      } else {
        isLastNameValid = text.isNotEmpty;
      }
    });
  }

  void validatePhoneNumber(String text) {
    setState(() {
      isPhoneNumberValid = text.length == 10; // Assuming phone number length is 10
    });
  }

  void redirectHomeScreen() async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => SubscriptionPage()),
          (route) => false,
    );
  }

  void registerUser() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: SpinKitThreeInOut(
            size: 40,
            color: Colors.green,
          ),
          /*CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green)),*/
        );
      },
    );

    // Request location permission before sign-up
    var status = await Permission.location.request();
    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      // Permission denied, handle accordingly
      Navigator.pop(context); // Dismiss loading dialog
      return;
    }

    try {
      // Store first name and last name in the database or call an API
      await saveUserData(
        fnController.text,
        lnController.text,
        emailController.text,
        phoneNumberController.text,
      );
      redirectHomeScreen();
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
    }
  }

  Future<void> saveUserData(
      String firstName,
      String lastName,
      String email,
      String phone,
      ) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await storeUserData(uid, firstName, lastName, email, phone);
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  String? validateEmail(String value) {
    // Regular expression for a simple email validation
    // This regex is a basic one and may not cover all edge cases
    // It checks for the presence of an @ symbol and a dot (.) after it
    final emailRegex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
    );

    if (value.isEmpty) {
      return 'Email is required';
    } else if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  void emailAlreadyRegisteredMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Email already registered'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              maxRadius: 20,
              backgroundColor: Colors.green,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Image.asset('lib/images/bankUP-Icon-App-20x20@3x.png', width: 40, height: 40),
            )
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      obscureText: false,
                      autofocus: true,
                      controller: fnController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'First name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length < 2) {
                          return 'Enter a valid first name';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (text) {
                        validateName(text, isFirstName: true);
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      obscureText: false,
                      autofocus: true,
                      controller: lnController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'Last name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length < 2) {
                          return 'Enter a valid last name';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (text) {
                        validateName(text, isFirstName: false);
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      obscureText: false,
                      autofocus: true,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: (value) => validateEmail(value ?? ''),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      obscureText: false,
                      autofocus: true,
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length != 10) {
                          return 'Enter a valid 10 digit phone number';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (text) {
                        validatePhoneNumber(text);
                      },
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          registerUser();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 100,
                          vertical: 20,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      child: const Text("Sign Up"),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already a member?',
                          style: TextStyle(color: Colors.green),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            // Navigate to another screen here
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterScreenPhone()),
                            );
                          },
                          child: const Text(
                            'Sign in now',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
