import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String message = "";
  bool rememberMe = false; // "Beni Hatırla" seçeneği

  @override
  void initState() {
    super.initState();
    loadSavedUser(); // Önceden kaydedilen kullanıcıyı kontrol et
  }

  // SharedPreferences'tan kullanıcı verisini al
  Future<void> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false;
      if (rememberMe) {
        emailController.text = prefs.getString('email') ?? "";
        passwordController.text = prefs.getString('password') ?? "";
      }
    });
  }

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
      message = "";
    });

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
      setState(() {
        message = data["message"] ?? "Giriş başarılı!";
      });

      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('rememberMe', true);
        await prefs.setString('email', emailController.text);
        await prefs.setString('password', passwordController.text);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('rememberMe');
        await prefs.remove('email');
        await prefs.remove('password');
      }

      Navigator.pushReplacementNamed(context, "/home");
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        message = data["message"] ?? "Giriş başarısız!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Giriş Yap")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "E-posta"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Şifre"),
              obscureText: true,
            ),
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (bool? value) {
                    setState(() {
                      rememberMe = value ?? false;
                    });
                  },
                ),
                Text("Beni Hatırla"),
              ],
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: loginUser,
                    child: Text("Giriş Yap"),
                  ),
            SizedBox(height: 20),
            Text(message),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: Text("Hesabın yok mu? Kayıt Ol"),
            ),
          ],
        ),
      ),
    );
  }
}
