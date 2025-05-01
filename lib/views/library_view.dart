import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import 'login_signup_view.dart'; // You'll create this next

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
          setState(
            () => _isLoggedIn = true,
          ); // Reload this widget as "logged in"
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
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
