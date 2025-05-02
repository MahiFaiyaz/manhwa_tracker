import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import 'login_signup_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  bool? _isLoggedIn;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    loadUserEmail();
  }

  Future<void> checkLoginStatus() async {
    final loggedIn = await isUserLoggedIn();
    setState(() => _isLoggedIn = loggedIn);
  }

  Future<void> loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('user_email');
    });
  }

  void handleLogout() async {
    print(userEmail);
    await logoutUser();
    setState(() => _isLoggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isLoggedIn!) {
      return LoginSignupView(
        onLoginSuccess: () {
          setState(() => _isLoggedIn = true);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              // icon: const Icon(Icons.person),
              offset: const Offset(0, 44), // Optional: adjust dropdown position
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      Colors.deepPurple.shade300, // match your ElevatedButton
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              onSelected: (value) {
                if (value == 'logout') handleLogout();
              },
              itemBuilder:
                  (context) => [
                    if (userEmail != null)
                      PopupMenuItem<String>(
                        height: 16, // ⬅️ forces a shorter height
                        enabled: false,
                        child: Text(
                          userEmail!,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    const PopupMenuItem<String>(
                      enabled: false,
                      height: 1,
                      padding: EdgeInsets.zero,
                      child: Divider(thickness: 2),
                    ),
                    const PopupMenuItem<String>(
                      height: 16, // ⬅️ forces a shorter height
                      value: 'logout',
                      child: Text('Log Out'),
                    ),
                  ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          '📚 Welcome to your Library!',
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
      ),
    );
  }
}
