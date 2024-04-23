import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../personal_checking_screen/personal_checking_screen.dart';

class PromotionalAdScreen extends StatefulWidget {
  @override
  _PromotionalAdScreenState createState() => _PromotionalAdScreenState();
}

class _PromotionalAdScreenState extends State<PromotionalAdScreen> {
  String adImageUrl = '';
  String adClickUrl = '';
  bool _isLoading = true;
  bool _adDataFetched = false;

  @override
  void initState() {
    super.initState();
    fetchAdData();
  }

  Future<void> fetchAdData() async {
    final CollectionReference adsCollection =
    FirebaseFirestore.instance.collection('ads');

    try {
      final snapshot = await adsCollection.doc('ad_data').get();
      if (snapshot.exists) {
        final adData = snapshot.data() as Map<String, dynamic>;
        setState(() {
          adImageUrl = adData['imageUrl'] as String;
          adClickUrl = adData['clickUrl'] as String;
          _adDataFetched = true;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PersonalCheckingScreen()),
        );
      }
    } catch (e) {
      // Handle error
      print('Error fetching ad data: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PersonalCheckingScreen()),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (_isLoading)
            const Center(
              child: SpinKitThreeInOut(
                color: Colors.green,
                size: 40,
              ),
            )
          else if (_adDataFetched)
            Center(
              child: GestureDetector(
                onTap: () {
                  launch(adClickUrl);
                },
                child: CachedNetworkImage(
                  imageUrl: adImageUrl,
                  fit: BoxFit.fill,

                ),
              ),
            ),
          if (_adDataFetched)
            Positioned(
              top: 50,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PersonalCheckingScreen(),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
