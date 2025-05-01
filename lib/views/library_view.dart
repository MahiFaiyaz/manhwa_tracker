import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import 'login_signup_view.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final loggedIn = await isUserLoggedIn();
    setState(() => _isLoggedIn = loggedIn);
  }

  void handleLogout() async {
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.person),
            padding: EdgeInsets.zero, // Remove default padding
            offset: const Offset(0, 36), // Optional: adjust dropdown position
            onSelected: (value) {
              if (value == 'logout') handleLogout();
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem<String>(
                    height: 20, // ⬅️ forces a shorter height
                    value: 'logout',
                    child: Text('Log Out'),
                  ),
                ],
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
