import 'package:flutter/material.dart';
import '../dialog/loading_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  bool isEmailValid = false;

  Future<void> _showPasswordResetDialog() async {
    final controller = TextEditingController();
    final supabase = Supabase.instance.client;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reset Password"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: "Enter your email"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = controller.text.trim();
                Navigator.pop(context); // close dialog
                LoadingScreen.instance().show(
                  context: context,
                  text: "Sending reset email...",
                );
                try {
                  await supabase.auth.resetPasswordForEmail(
                    email,
                    redirectTo: "https://yourapp.com/reset", // <- update this!
                  );
                  _showSnackBar("Check your inbox to reset your password.");
                } catch (e) {
                  _showSnackBar("Failed to send reset email.");
                } finally {
                  LoadingScreen.instance().hide();
                }
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }

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
    final supabase = Supabase.instance.client;
    setState(() => message = null);

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

    try {
      final authResponse =
          isLogin
              ? await supabase.auth.signInWithPassword(
                email: email,
                password: password,
              )
              : await supabase.auth.signUp(email: email, password: password);

      LoadingScreen.instance().hide();

      if (authResponse.session != null && authResponse.user != null) {
        if (!mounted) return;
        widget.onLoginSuccess?.call();
      } else {
        setState(
          () => message = "Please check your email to verify your account.",
        );
      }
    } on AuthException catch (e) {
      LoadingScreen.instance().hide();
      setState(() => message = e.message);
    } catch (e) {
      LoadingScreen.instance().hide();
      setState(() => message = "Unexpected error: $e");
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
                  onChanged: (value) {
                    setState(() {
                      isEmailValid = isValidEmail(value.trim());
                    });
                  },
                ),
                if (!isLogin &&
                    !isEmailValid &&
                    emailController.text.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      "Please enter a valid email",
                      style: TextStyle(fontSize: 12, color: Colors.redAccent),
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
                if (isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showPasswordResetDialog,
                      child: const Text("Forgot Password?"),
                    ),
                  ),
                if (!isLogin && passwordValidationMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
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
                      isLogin || (isPasswordValid && isEmailValid)
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
