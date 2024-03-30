import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../main.dart';
import '../introduction_screen/splash_gif_screen.dart';
import '../personal_checking_screen/personal_checking_screen.dart';

class UpdateAppScreen extends StatelessWidget {
  final String latestVersion;

  const UpdateAppScreen({super.key, required this.latestVersion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'A new version ($latestVersion) of the app is available!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Open the app store or your app download link
                // for the user to update the app
              },
              child: const Text('Update Now'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> checkForAppUpdate(BuildContext context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String currentVersion = packageInfo.version;

  // Replace with the actual latest version retrieved from your server or app store
  String latestVersion = '2.0.0';

  if (currentVersion != latestVersion) {
    // Show the update screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateAppScreen(latestVersion: latestVersion),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
