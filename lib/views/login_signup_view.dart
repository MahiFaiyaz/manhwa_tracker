import 'package:flutter/material.dart';
import '../services/auth_services.dart';

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
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: submit,
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
