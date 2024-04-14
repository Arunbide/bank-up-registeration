import 'dart:convert';

import 'package:bankup/model/bankInfo.dart';
import 'package:http/http.dart' as http;

final stringUrlPath = "http://reconnect.bankupswiftsol.click:8080/api";

Future<List<BankInfo>> fetchData(String acctType) async {
  // TODO Get ssl certificate
  final url = Uri.parse('$stringUrlPath/getbanks?acctType=$acctType');
  List<dynamic> bankList = [];
  try {
    final response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        bankList = data['banks'];
        return bankList.map((json) => BankInfo.fromJson(json)).toList();
      }
      return bankList.map((json) => BankInfo.fromJson(json)).toList();
  } catch(exce) {
    throw Exception ('Error occurred getting bank info');
  }
}

String removeSpecialCharacters(String phoneNumber) {
  // Use a regular expression to remove non-numeric characters
  return phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
}

Future<void> storeUserData(String uid, String firstName, String lastName,
    String email, String phone) async {
  // TODO Get ssl certificate
  final apiUrl = Uri.parse('$stringUrlPath/users/add');
  try {
    final response = await http.post(
      apiUrl,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'uid': uid,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': removeSpecialCharacters(phone)
      }),
    );

    if (response.statusCode == 200) {
      print('User data stored successfully');
    } else {
      print('Failed to store user data. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    throw Exception ('Error occurred getting User info');
  }
}


Future<void> storeFeedback(String firstName, String lastName,
    String email, String feedback) async {
  // TODO Get ssl certificate
  final apiUrl = Uri.parse('$stringUrlPath/feedback');
  try {
    final response = await http.post(
      apiUrl,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'feedback': feedback,
      }),
    );

    if (response.statusCode == 200) {
      print('Feedback data stored successfully');
    } else {
      print('Failed to store feedback. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    throw Exception ('Error storing feedback');
  }

}

Future<Map<String, dynamic>?> getUserByEmail(String email) async {
  try {
    final response = await http.get(
      // TODO Get ssl certificate
        Uri.parse('$stringUrlPath/users/get_user?email=$email'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
  } catch (e) {
    throw Exception('Failed to load user by Email');
  }
}

Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
  String cleanPhoneNumber = removeSpecialCharacters(phone);
  // TODO Get ssl certificate
  try {
    final response = await http.get(Uri.parse(
        '$stringUrlPath/users/getUserByPhone?phone=$cleanPhoneNumber'));
    if (response.statusCode == 200) {
      if (response.body != '') {
        return json.decode(response.body);
      }
      return null;
    }
  } catch (e) {
    throw Exception('Failed to load user by Phone');
  }
}

Future<Map<String, dynamic>?> getUserByUid(String uid) async {
  // TODO Get ssl certificate
  final response = await http.get(
      Uri.parse('$stringUrlPath/users/getUserById?uid=$uid'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    return null;
  }
}
