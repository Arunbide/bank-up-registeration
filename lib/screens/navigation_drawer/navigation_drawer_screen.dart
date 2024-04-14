import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/call_api.dart';
import '../register_screen/delete_account.dart';

class NavDrawer extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;

  const NavDrawer({super.key, required this.firstName, required this.lastName, required this.email});

  @override
  _NavDrawerState createState() => _NavDrawerState();

}

class _NavDrawerState extends State<NavDrawer> {
  bool showFeedbackTextField = false;
  int maxCharacters = 900;
  bool feedbackSent = false;
  final TextEditingController feedbackController = TextEditingController();
  FocusNode feedbackFocusNode = FocusNode();

  Future<String> loadAboutUsContent() async {
    return await rootBundle.loadString('lib/images/about_us.txt');
  }

  Future<String> loadPrivacyPolicy() async {
    return await rootBundle.loadString('lib/images/privacy_policy.txt');
  }

  @override
  Widget build(BuildContext context) {
    String currentRoute = ModalRoute.of(context)!.settings.name ?? '';
    return Drawer(
        child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.green,
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        backgroundImage: AssetImage('lib/images/egghold_removed.png'),
                        backgroundColor: Colors.green,
                        radius: 30,
                        //backgroundColor: Colors.grey,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${widget.firstName} ${widget.lastName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      )
                    ]),
              ),
              ExpansionTile(title: const Text('Category'), children: [
                ListTile(
                  title: const Text('Personal Checking Offers'),
                  onTap: () {
                    if (currentRoute != '/personal_checking_offer') {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/personal_checking_offer');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  selected: currentRoute == '/personal_checking_offer',
                  selectedTileColor: Colors.green.withOpacity(0.3),
                  tileColor: currentRoute == '/personal_checking_offer'
                      ? Colors.green.withOpacity(0.1)
                      : null,
                ),
                ListTile(
                  title: const Text('Business Checking Offers'),
                  onTap: () {
                    if (currentRoute != '/business_checking_offer') {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/business_checking_offer');
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  selected: currentRoute == '/business_checking_offer',
                  selectedTileColor: Colors.green.withOpacity(0.3),
                  tileColor: currentRoute == '/business_checking_offer'
                      ? Colors.green.withOpacity(0.1)
                      : null,
                ),
                /*ListTile(
          title: const Text('Test tokens'),
          onTap: () {
            if (currentRoute != '/business_checking_offer') {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'FirebaseAppCheckExample');
            } else {
              Navigator.pop(context);
            }
          },
          selected: currentRoute == 'FirebaseAppCheckExample',
          selectedTileColor: Colors.green.withOpacity(0.3),
          tileColor: currentRoute == 'FirebaseAppCheckExample'
              ? Colors.green.withOpacity(0.1)
              : null,
        ),*/
                /*ListTile(
          title: const Text('Subscriptions'),
          onTap: () {
            if (currentRoute != 'subscription') {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'subscription');
            } else {
              Navigator.pop(context);
            }
          },
          selected: currentRoute == 'FirebaseAppCheckExample',
          selectedTileColor: Colors.green.withOpacity(0.3),
          tileColor: currentRoute == 'FirebaseAppCheckExample'
              ? Colors.green.withOpacity(0.1)
              : null,
        ),*/
              ]),
              ExpansionTile(title: const Text('App Information'), children: [
                ListTile(
                  title: const Text('About us'),
                  onTap: () {
                    loadAboutUsContent().then((aboutUsContent) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            scrollable: true,
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text(aboutUsContent),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              // Add a close button
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    });
                  },
                ),
                ListTile(
                  title: const Text('Privacy policy'),
                  onTap: () {
                    loadPrivacyPolicy().then((privacyPolicyContent) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            scrollable: true,
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text(privacyPolicyContent),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              // Add a close button
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    });
                  },
                ),
              ]),

              ListTile(
                title: const Text('Feedback'),
                onTap: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return GestureDetector(
                          onTap: () {
                            // Dismiss the keyboard when tapping outside the text field
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          child: SingleChildScrollView(
                            child: Container(
                              // padding: const EdgeInsets.all(16),
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Text(
                                      'Send us your feedback',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Add a text box for typing feedback
                                  TextField(
                                    controller: feedbackController,
                                    focusNode: feedbackFocusNode,
                                    maxLines: 5,
                                    maxLength: 500,
                                    keyboardType: TextInputType.multiline,
                                    decoration: const InputDecoration(
                                      hintText: 'Type your feedback here...',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      feedbackFocusNode.requestFocus();
                                      String feedbackText = feedbackController.text;
                                      sendFeedbackEmail(widget.firstName, widget.lastName, widget.email, feedbackText);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Feedback sent !!',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                      // Close the bottom sheet after a delay
                                      Future.delayed(const Duration(seconds: 1), () {
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    child: const Text('Send Feedback'),
                                  ),
                                ],
                              ),
                            ),
                          )
                      );
                    },
                  );
                },
              ),
              ListTile(
                title: const Text('Account'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeleteAccountScreen(
                        firstName: widget.firstName,
                        lastName: widget.lastName,
                        email: widget.email,
                      ),
                    ),
                  );
                },
              ),

              const ListTile(
                title: Text('Spread the word'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Image.asset('lib/images/insta.png', width: 30, height: 30),
                    onPressed: () {
                      openInBrowser(
                          url: 'https://www.instagram.com/swiftsolservices/',
                          inApp: false);
                    },
                  ),
                  IconButton(
                    icon: Image.asset('lib/images/facebook.png', width: 30, height: 30),
                    onPressed: () {
                      openInBrowser(
                          url: 'https://www.facebook.com/people/Swiftsol-Services/61556573396628/',
                          inApp: false);
                    },
                  ),
                ],
              ), // SizedBox(height: 60),// Add more ListTile widgets as needed
            ]));
  }

  void sendFeedbackEmail(String firstName, String lastName,
      String email, String feedback) async {
    try {
      await storeFeedback(firstName, lastName, email, feedback);
    } catch (e) {
      print('Error saving feedback: $e');
    }
    feedbackController.clear();
    setState(() {
      feedbackSent = true;
    });
    if (feedbackSent) {
      const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          'Feedback sent successfully!',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop(); // Close the bottom sheet
    });

  }

  Future openInBrowser({required String url, bool inApp = false}) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }
}

