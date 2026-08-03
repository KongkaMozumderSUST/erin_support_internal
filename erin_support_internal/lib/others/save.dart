import 'dart:convert';
import 'package:erin_support_internal/models/CustomerModel.dart'; // Update import to your main model file
import 'package:shared_preferences/shared_preferences.dart';

class Save {
  static const String _key = 'customer_data';

  // Save the entire ApiResponse
  static Future<void> saveUser(ApiResponse customer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(customer.toMap()));
  }


  // Retrieve the saved ApiResponse
  static Future<ApiResponse?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      return ApiResponse.fromMap(json.decode(jsonString));
    }
    return null;
  }

  // Clear saved data on logout
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
  static Future<bool> hasUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key);
  }
}