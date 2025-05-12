import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import '../dialog/loading_screen.dart';

class LoginSignupView extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginSignupView({super.key, this.onLoginSuccess});

  @override
  State<LoginSignupView> createState() => _LoginSignupViewState();
}

class _LoginSignupViewState extends State<LoginSignupView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLogin = true;
  String? message;
  String? passwordValidationMessage;
  bool isPasswordValid = false;

  String? validatePassword(String password) {
    if (password.length < 8) {
      return "Password must be at least 8 characters";
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "Must include an uppercase letter";
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return "Must include a lowercase letter";
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return "Must include a number";
    }
    return null;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    void onError(String msg) {
      setState(() => message = msg);
    }

    if (!isLogin) {
      final validationMessage = validatePassword(password);
      if (validationMessage != null) {
        setState(() => message = validationMessage);
        return;
      }
    }

    LoadingScreen.instance().show(
      context: context,
      text: isLogin ? 'Logging in...' : 'Signing up...',
    );

    final success =
        isLogin
            ? await loginUser(
              email: email,
              password: password,
              onError: onError,
            )
            : await signUpUser(
              email: email,
              password: password,
              onError: onError,
            );

    LoadingScreen.instance().hide();

    if (success && mounted) {
      setState(() => message = "Success!");
      if (isLogin) {
        widget.onLoginSuccess?.call(); // delegate navigation
      } else {
        _showSnackBar("Please verify email.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              // color: Colors.grey[900],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLogin ? "Welcome Back!" : "Start Tracking!",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    if (!isLogin) {
                      setState(() {
                        passwordValidationMessage = validatePassword(value);
                        isPasswordValid = validatePassword(value) == null;
                      });
                    }
                  },
                ),
                if (!isLogin && passwordValidationMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      passwordValidationMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed:
                      isLogin || isPasswordValid
                          ? submit
                          : null, // disabled if invalid during signup
                  icon: const Icon(Icons.lock_open),
                  label: Text(isLogin ? "Log In" : "Sign Up"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(
                      (MediaQuery.sizeOf(context).width * 0.5),
                      50,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin
                        ? "New here? Sign up"
                        : "Already have an account? Log in",
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                if (message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
