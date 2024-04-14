import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class FirebaseAppCheckExample extends StatefulWidget {
  FirebaseAppCheckExample({Key? key}) : super(key: key);


  @override
  _FirebaseAppCheck createState() => _FirebaseAppCheck();
}

class _FirebaseAppCheck extends State<FirebaseAppCheckExample> {
  final appCheck = FirebaseAppCheck.instance;

  String _message = '';
  String _eventToken = 'not yet';

  @override
  void initState() {
    appCheck.onTokenChange.listen(setEventToken);
    super.initState();
  }

  void setMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  void setEventToken(String? token) {
    setState(() {
      _eventToken = token ?? 'not yet';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Testing"),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                // Use this button to check whether the request was validated on the Firebase console
                // Gets first document in collection
                final result = await FirebaseFirestore.instance
                    .collection('flutter-tests')
                    .limit(1)
                    .get();

                if (result.docs.isNotEmpty) {
                  setMessage('Document found');
                } else {
                  setMessage(
                    'Document not found, please add a document to the collection',
                  );
                }
              },
              child: const Text('Test App Check validates requests'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (kIsWeb) {
                  print(
                    'Pass in your "webRecaptchaSiteKey" key found on you Firebase Console to activate if using on the web platform.',
                  );
                }
                await appCheck.activate(
                  webProvider: ReCaptchaV3Provider(kWebRecaptchaSiteKey),
                );
                setMessage('activated!!');
              },
              child: const Text('activate()'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Token will be passed to `onTokenChange()` event handler
                await appCheck.getToken(true);
              },
              child: const Text('getToken()'),
            ),
            ElevatedButton(
              onPressed: () async {
                await appCheck.setTokenAutoRefreshEnabled(true);
                setMessage('successfully set auto token refresh!!');
              },
              child: const Text('setTokenAutoRefreshEnabled()'),
            ),
            const SizedBox(height: 20),
            Text(
              _message, //#007bff
              style: const TextStyle(
                color: Color.fromRGBO(47, 79, 79, 1),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Token received from tokenChanges() API: $_eventToken', //#007bff
              style: const TextStyle(
                color: Color.fromRGBO(128, 0, 128, 1),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}