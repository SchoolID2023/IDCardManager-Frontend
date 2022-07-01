import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/schools_model.dart';

class RemoteServices {
  static var client = http.Client();
  final String baseUrl = 'http://65.0.169.179:3000';

  Future<void> superAdminLogin(String email, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse('${baseUrl}/superAdmin/login'),
      body: {
        'email': email,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      prefs.setString('token', data['token']);
    } else {
      throw Exception(response.statusCode);
    }
  }

  Future<SchoolsModel> getSchools() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${baseUrl}/superAdmin/viewSchools'),
      headers: {
        'Authorization': 'Biatch $token',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SchoolsModel.fromJson(data);
    } else {
      throw Exception(response.statusCode);
    }
  }
}
