import 'package:flutter/material.dart';
import '../services/auth_services.dart';

class TestAuthPage extends StatefulWidget {
  const TestAuthPage({super.key});

  @override
  State<TestAuthPage> createState() => _TestAuthPageState();
}

class _TestAuthPageState extends State<TestAuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = '';

  void _showMessage(String msg) {
    setState(() => _message = msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Auth Tester")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final success = await loginUser(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                      onError: _showMessage,
                    );
                    if (success) _showMessage("Login success!");
                  },
                  child: const Text("Login"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    final success = await signUpUser(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                      onError: _showMessage,
                    );
                    if (success) _showMessage("Signup success!");
                  },
                  child: const Text("Sign Up"),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await refreshAuthToken(onError: _showMessage);
                _showMessage("Token refreshed (check console for errors)");
              },
              child: const Text("Refresh Token"),
            ),
            ElevatedButton(
              onPressed: () async {
                final token = await getAuthToken();
                _showMessage("Token: $token");
              },
              child: const Text("Show Token"),
            ),
            ElevatedButton(
              onPressed: () async {
                await logoutUser();
                _showMessage("Logged out!");
              },
              child: const Text("Logout"),
            ),
            const SizedBox(height: 24),
            Text(_message, style: const TextStyle(color: Colors.purple)),
          ],
        ),
      ),
    );
  }
}
