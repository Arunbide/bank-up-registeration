import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:us_states/us_states.dart';
import 'package:animations/animations.dart';

import '../../model/bankInfo.dart';
import '../../services/call_api.dart';
import '../../services/firebase_api.dart';
import '../navigation_drawer/navigation_drawer_screen.dart';
import '../register_screen/register_screen_phone.dart';
import 'personal_checking_screen.dart';

class PersonalCheckingScreenState extends State<PersonalCheckingScreen> {
  String firstName = "User";
  String lastName = "Name";
  String email = "";
  Future<List<BankInfo>> data = Future<List<BankInfo>>.value([]);
  List<String> allStates = USStates.getAllAbbreviations();
  Future<Position?>? locationFuture;
  int currentSortOption = 3; // Default to Sort by expiringIn ascending
  final user = FirebaseAuth.instance.currentUser;

  String selectedState = "All";
  Position? userLocation;

  @override
  void initState() {
    super.initState();
    locationFuture = getUserLocation();
    loadUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadUserData() async {
    try {
      final phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber;
      if (phoneNumber != null && phoneNumber != "") {
        final userData = await getUserByPhone(phoneNumber);

        if (userData != null) {
          setState(() {
            firstName = userData['firstName'] ?? 'User';
            lastName = userData['lastName'] ?? 'Name';
            email = userData['email'] ?? 'Email';
          });
          print('setState completed:');
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<Position?> getUserLocation() async {
    // Check and request location permissions
    var status = await Permission.location.request();
    //if (await Permission.location.serviceStatus.isEnabled) {
      if (status == PermissionStatus.granted) {
        try {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          String state = placemarks.first.administrativeArea ?? 'Unknown';
          String? stateAbbreviation =
              (state.length != 2) ? USStates.getAbbreviation(state) : state;

          setState(() {
            userLocation = position;
            selectedState = stateAbbreviation!;
          });

          return position;
        } catch (e) {
          print('Error getting location: $e');
        }
      } else {
        // Handle case when permissions are denied
        print('Location permissions denied');
        return null;
      }
    //}
  }

  Future<void> signUserOut() async {
    FirebaseAuth.instance.signOut();
    GoogleSignIn().signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreenPhone()),
    );
  }

  String capitalize(String s) {
    return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  }

  Future openInBrowser({required String url, bool inApp = false}) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    List<BankInfo> newData = await fetchData('fetchData');
    setState(() {
      data = Future<List<BankInfo>>.value(newData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: FutureBuilder(
            future: locationFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  color: Colors.white,
                  child: const Center(
                    child: SpinKitThreeInOut(
                      size: 40,
                      color: Colors.green,
                    ),
                  ),
                );
                /*CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ));*/
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Theme(
                    data: ThemeData(
                      primarySwatch: Colors.green,
                      appBarTheme: const AppBarTheme(
                        backgroundColor: Colors.green,
                      ),
                      elevatedButtonTheme: ElevatedButtonThemeData(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                        ),
                      ),
                    ),
                    child: Scaffold(
                        drawer: NavDrawer(
                            firstName: firstName,
                            lastName: lastName,
                            email: email),
                        appBar: AppBar(
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${capitalize(firstName)}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Lato'),
                              ),
                              const Text(
                                'Personal Checking Offers',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Lato',
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ],
                          ),
                          automaticallyImplyLeading: true,
                          elevation: 5,
                        ),
                        body: RefreshIndicator(
                            onRefresh: _refreshData,
                            child: FutureBuilder<List<BankInfo>>(
                                future: fetchData('personal'),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: SpinKitThreeInOut(
                                        size: 40,
                                        color: Colors.green,
                                      )
                                      /*CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.green)*/
                                      ,
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    List<BankInfo> data = snapshot.data!;
                                    List<BankInfo> filteredData =
                                        selectedState == "All"
                                            ? List.from(data)
                                            : data
                                                .where((bankInfo) =>
                                                    bankInfo.states.contains(
                                                        selectedState) ||
                                                    bankInfo.states
                                                        .contains("All"))
                                                .toList();

                                    // Sorting logic based on currentSortOption
                                    switch (currentSortOption) {
                                      case 1: // Sort by offerVal descending
                                        filteredData.sort((a, b) =>
                                            (b.offerVal ?? '')
                                                .compareTo(a.offerVal ?? ''));
                                        break;
                                      case 2: // Sort by offerVal ascending
                                        filteredData.sort((a, b) =>
                                            (a.offerVal ?? '')
                                                .compareTo(b.offerVal ?? ''));
                                        break;
                                      case 3: // Sort by expiringIn descending
                                        filteredData.sort((a, b) =>
                                            (b.expiringInDays ?? '').compareTo(
                                                a.expiringInDays ?? ''));
                                        break;
                                      case 4: // Sort by expiringIn ascending (default)
                                      default:
                                        filteredData.sort((a, b) =>
                                            (a.expiringInDays ?? '').compareTo(
                                                b.expiringInDays ?? ''));
                                        break;
                                    }
                                    // Divider between filter and extended ListView
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // State filter dropdown
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: const Text('State: '),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(1.0),
                                              // Add state filter dropdown
                                              child: DropdownButton<String>(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                elevation: 16,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                underline: Container(
                                                  height: 2,
                                                  color: Colors.green,
                                                ),
                                                value: selectedState,
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    selectedState = newValue!;
                                                  });
                                                },
                                                items: <String>[
                                                  'All',
                                                  ...allStates
                                                ].map<DropdownMenuItem<String>>(
                                                    (String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              child: const Text('Sort: '),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: DropdownButton<int>(
                                                value: currentSortOption,
                                                onChanged: (int? newValue) {
                                                  setState(() {
                                                    currentSortOption =
                                                        newValue!;
                                                  });
                                                },
                                                items: const [
                                                  DropdownMenuItem<int>(
                                                    value: 1,
                                                    child: Text(
                                                        'Offer value high to low'),
                                                  ),
                                                  DropdownMenuItem<int>(
                                                    value: 2,
                                                    child: Text(
                                                        'Offer value low to high'),
                                                  ),
                                                  DropdownMenuItem<int>(
                                                    value: 3,
                                                    child:
                                                        Text('Latest Expiring'),
                                                  ),
                                                  DropdownMenuItem<int>(
                                                    value: 4,
                                                    child: Text(
                                                        'Earliest Expiring'),
                                                  ),
                                                ],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                underline: Container(
                                                  height: 2,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 8.0),
                                        // divider,
                                        // Display sorted and filtered cards
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: filteredData.length,
                                            itemBuilder: (context, index) {
                                              return OpenContainer(
                                                  transitionType:
                                                      ContainerTransitionType
                                                          .fadeThrough,
                                                  closedBuilder:
                                                      (BuildContext context,
                                                          VoidCallback
                                                              openContainer) {
                                                    return Card(
                                                      elevation: 5,
                                                      shadowColor: Colors.green,
                                                      child: ExpansionTile(
                                                        title: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            CircleAvatar(
                                                              maxRadius: 30,
                                                              backgroundColor:
                                                                  Colors.grey[
                                                                      200],
                                                              child: Image.asset(
                                                                  'lib/images/${filteredData[index].bankIcon}'),
                                                            ),
                                                            Text(filteredData[
                                                                    index]
                                                                .bankName),
                                                            Text(filteredData[
                                                                        index]
                                                                    .offerVal ??
                                                                'No Offer'),
                                                          ],
                                                        ),
                                                        children: [
                                                          ListTile(
                                                            title: Text(
                                                              'Account Type: ${filteredData[index].accountType}',
                                                            ),
                                                            subtitle: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Required direct deposit: ${filteredData[index].directDepositAmt}',
                                                                ),
                                                                Text(
                                                                  'Expiring in ${filteredData[index].expiringInDays} days',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            trailing:
                                                                GestureDetector(
                                                                  //onTap: openContainer,
                                                              onTap: () async {
                                                                if (filteredData[
                                                                            index]
                                                                        .offerLink !=
                                                                    null) {
                                                                  openInBrowser(
                                                                      url: filteredData[
                                                                              index]
                                                                          .offerLink!,
                                                                      inApp:
                                                                          false);
                                                                }
                                                              },
                                                              child: const Icon(
                                                                Icons
                                                                    .arrow_forward,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                openBuilder: (BuildContext context, VoidCallback _) {
                                                  return Theme(
                                                      data: ThemeData(
                                                        primarySwatch: Colors.green,
                                                        appBarTheme: const AppBarTheme(
                                                          backgroundColor: Colors.green,
                                                        ),
                                                        elevatedButtonTheme: ElevatedButtonThemeData(
                                                          style: ButtonStyle(
                                                            backgroundColor:
                                                            MaterialStateProperty.all<Color>(Colors.green),
                                                          ),
                                                        ),
                                                      ),
                                                  child: Scaffold(
                                                    appBar: AppBar(
                                                      title: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            '${filteredData[index].bankName} Bank',
                                                            style: const TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 20,
                                                                fontWeight: FontWeight.bold,
                                                                fontFamily: 'Lato'),
                                                          ),
                                                          const Text(
                                                            'Personal Checking Offer',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontStyle: FontStyle.normal,
                                                              fontWeight: FontWeight.bold,
                                                              fontFamily: 'Lato',
                                                              color: Colors.white,
                                                            ),
                                                            textAlign: TextAlign.end,
                                                          ),
                                                        ],
                                                      ),
                                                      // title: Text(filteredData[index].bankName),
                                                      leading: IconButton(
                                                        icon: Icon(Icons.arrow_back),
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                      ),
                                                    ),
                                                    body: Padding(
                                                      padding: const EdgeInsets.all(16.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          CircleAvatar(
                                                            maxRadius: 30,
                                                            backgroundColor: Colors.grey[200],
                                                            child: Image.asset(
                                                              'lib/images/${filteredData[index].bankIcon}',
                                                            ),
                                                          ),
                                                          Text('Account Type: ${filteredData[index].accountType}'),
                                                          Text('Required direct deposit: ${filteredData[index].directDepositAmt}'),
                                                          Text(
                                                            'Expiring in ${filteredData[index].expiringInDays} days',
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          // Add other details you want to display
                                                          SizedBox(height: 16),
                                                          // Add social media sharing buttons or links here
                                                          Row(
                                                            children: [
                                                              IconButton(
                                                                icon: Icon(Icons.share),
                                                                onPressed: () {
                                                                  // Implement sharing logic here
                                                                },
                                                              ),
                                                              // Add other social media sharing buttons or links
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ));
                                                },
                                                onClosed:(_) {
                                                // Handle any cleanup or updates when the details page is closed
                                              },
                                                transitionDuration: const Duration(milliseconds: 500),
                                                // curve: Curves.easeInOut,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                }))));
              }
            }));
  }
}
