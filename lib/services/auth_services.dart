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
      await prefs.setString('user_email', email);
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
    } else if (response.statusCode == 422) {
      final data = json.decode(response.body);
      final detail = data['detail'];
      if (detail is List && detail.isNotEmpty && detail[0]['msg'] != null) {
        final fullMsg = detail[0]['msg'].toString();
        final cleanedMsg =
            fullMsg.contains(', ')
                ? fullMsg
                    .split(', ')
                    .last // take just the user-defined part
                : fullMsg;

        debugPrint("Signup validation failed: $cleanedMsg");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onError?.call(cleanedMsg);
        });
      } else {
        debugPrint("Signup 422 error but no clear message: $data");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onError?.call("Signup validation failed. Please check your inputs.");
        });
      }
      return false;
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
  await prefs.remove('user_email');
}

Future<String?> getAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

Future<String?> getRefreshToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('refresh_token');
}

Future<bool> refreshAuthToken({void Function(String)? onError}) async {
  try {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse('$apiBaseUrl/refresh_token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final authToken = data['access_token'];
      final newRefreshToken = data['refresh_token'] ?? refreshToken;

      if (authToken == null) {
        debugPrint(
          "Missing access_token after refresh. refresh_token=${data['refresh_token']}",
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onError?.call("Token refresh succeeded but access token missing.");
        });
        return false;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', authToken);
      await prefs.setString('refresh_token', newRefreshToken);
      return true;
    } else {
      final err = 'Refresh token failed: ${response.statusCode}';
      debugPrint(err);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onError?.call(err);
      });
      return false;
    }
  } catch (e) {
    debugPrint("Refresh error: $e");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onError?.call("An error occurred while refreshing token.");
    });
    return false;
  }
}

Future<bool> isUserLoggedIn() async {
  final token = await getAuthToken();

  if (token != null && token.isNotEmpty) {
    // Try making a lightweight API call or refresh the token silently
    final refreshed = await refreshAuthToken(
      onError: (_) {}, // optional, you can suppress error here
    );

    if (refreshed) {
      return true;
    } else {
      // Clear invalid session
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_email');
    }
  }

  return false;
}
