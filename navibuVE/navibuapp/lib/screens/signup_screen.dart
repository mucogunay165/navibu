import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:navibuapp/screens/verification_screen.dart';
import 'package:navibuapp/screens/login_screen.dart'; 

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String message = "";

  Future<void> signUpUser() async {
    setState(() {
      isLoading = true;
      message = "";
    });

    final url = Uri.parse("http://127.0.0.1:5000/auth/register");
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

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      setState(() {
        message = data["message"] ?? "Kayıt başarılı!";
      });
      // Kullanıcıyı doğrulama ekranına yönlendir
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(email: emailController.text),
        ),
      );
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        message = data["message"] ?? "Kayıt başarısız!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kayıt Ol"),
      ),
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
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: signUpUser,
                    child: Text("Kayıt Ol"),
                  ),
            SizedBox(height: 20),
            Text(message, style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(), // Burada login ekranını açıyoruz
                  ),
                );
              },
              child: Text(
                "Zaten hesabın var mı? Giriş Yap",
                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
