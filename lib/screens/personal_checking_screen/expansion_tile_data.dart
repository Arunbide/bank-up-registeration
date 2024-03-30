import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/bankInfo.dart';

class ExpansionTileData extends StatelessWidget {
  final BankInfo bankInfo;

  const ExpansionTileData(this.bankInfo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shadowColor: Colors.green,
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              maxRadius: 30,
              backgroundColor: Colors.grey[200],
              child: Image.asset('lib/images/${bankInfo.bankIcon}'),
            ),
            Text(bankInfo.bankName),
            Text(bankInfo.offerVal ?? 'No Offer'),
          ],
        ),
        children: [
          ListTile(
            title: const Text(
              'Additional information or content goes here',
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Additional information or content goes here',
                ),
                Text(
                  'Expiring in ${bankInfo.expiringInDays} days',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                // Add more widgets as needed
              ],
            ),
            trailing: GestureDetector(
              onTap: () async {
                if (bankInfo.offerLink != null) {
                  openInBrowser(url: bankInfo.offerLink!, inApp: false);
                }
              },
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future openInBrowser({required String url, bool inApp = false}) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }
}
