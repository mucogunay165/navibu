// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:navibuapp/widgets/navibu_logo.dart';
import 'package:navibuapp/screens/signup_screen.dart';
import 'package:navibuapp/screens/home_screen.dart';
import 'package:navibuapp/screens/route_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String message = "";

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
      message = "";
    });

    try {
      // Replace with your computer's actual IP address
      final url = Uri.parse("http://127.0.0.1:5000/auth/login");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text,
          "password": passwordController.text,
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userId = data["user_id"];
        
        // Check if user has selected routes
        final checkUrl = Uri.parse("http://127.0.0.1:5000/user/check_route_selection/$userId");
        final checkResponse = await http.get(checkUrl);
        
        if (checkResponse.statusCode == 200) {
          final checkData = jsonDecode(checkResponse.body);
          
          if (checkData['has_selected_routes']) {
            // User has already selected routes, go to home screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(userId: userId),
              ),
            );
          } else {
            // User needs to select routes first
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RouteSelectionScreen(userId: userId),
              ),
            );
          }
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          message = data["error"] ?? "Giriş başarısız!";
        });
      }
    } catch (e) {
      setState(() {
        message = "Bağlantı hatası: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo
                const Center(child: NavibuLogo()),
                const SizedBox(height: 40),
                // Title
                Text(
                  "Navibu'ya Hoş Geldiniz",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                // Email field
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "E-posta",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                // Password field
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: "Şifre",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : loginUser,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Giriş Yap"),
                  ),
                ),
                const SizedBox(height: 16),
                // Error message
                if (message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Hesabınız yok mu?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text("Kayıt Ol"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}