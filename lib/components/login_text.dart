import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const LoginTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      required TextInputType keyboardType,
      required InputDecoration decoration,
      required Null Function(dynamic text) onChanged});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                fillColor: Colors.grey.shade300,
                filled: true,
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[800]))));
  }
}
