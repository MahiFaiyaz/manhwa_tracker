import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/config.dart';
import 'package:flutter/widgets.dart';

Future<bool> loginUser({
  required String email,
  required String password,
  void Function(String)? onError,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final authToken = data['access_token'];
      final refreshToken = data['refresh_token'];

      if (authToken == null || refreshToken == null) {
        debugPrint(
          "Login response missing tokens: access_token=$authToken, refresh_token=$refreshToken",
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onError?.call("Login succeeded but access/refresh token missing.");
        });
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', authToken);
      await prefs.setString('refresh_token', refreshToken);
      return true;
    } else {
      final err = 'Login failed: ${response.statusCode}';
      debugPrint(err);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onError?.call(err);
      });
      return false;
    }
  } catch (e) {
    debugPrint("Login error: $e");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onError?.call("An error occurred while logging in.");
    });
    return false;
  }
}

Future<bool> signUpUser({
  required String email,
  required String password,
  void Function(String)? onError,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final err = 'Signup failed: ${response.statusCode}';
      debugPrint(err);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onError?.call(err);
      });
      return false;
    }
  } catch (e) {
    debugPrint("Signup error: $e");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onError?.call("An error occurred while signing up.");
    });
    return false;
  }
}

Future<void> logoutUser() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
  await prefs.remove('refresh_token');
}

Future<String?> getAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

Future<void> refreshAuthToken({void Function(String)? onError}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null) return;

    final response = await http.post(
      Uri.parse('$apiBaseUrl/refresh_token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final authToken = data['access_token'];
      final newRefreshToken = data['refresh_token'];

      if (authToken == null || newRefreshToken == null) {
        debugPrint(
          "Missing token(s): access_token=$authToken, refresh_token=$newRefreshToken",
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onError?.call(
            "Token refresh succeeded but access/refresh token missing.",
          );
        });
        return;
      }

      await prefs.setString('auth_token', authToken);
      await prefs.setString('refresh_token', newRefreshToken);
    } else {
      final err = 'Refresh token failed: ${response.statusCode}';
      debugPrint(err);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onError?.call(err);
      });
    }
  } catch (e) {
    debugPrint("Refresh error: $e");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onError?.call("An error occurred while refreshing token.");
    });
  }
}
