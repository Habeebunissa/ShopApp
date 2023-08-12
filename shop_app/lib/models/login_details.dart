import 'package:shared_preferences/shared_preferences.dart';

class UserLoginSharedPreferences {
  static const String _userLoginKey = 'userLoggedIn';

  static Future<void> saveUserLoginStatus({required bool isLoggedIn}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_userLoginKey, isLoggedIn);
  }

  static Future<bool> getUserLoginStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_userLoginKey) ?? false;
    } catch (e) {
      // Handle the error (e.g., log it, return a default value, etc.)
      print('Error getting user login status: $e');
      return false;
    }
  }
}
