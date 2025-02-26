import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerificationScreen extends StatefulWidget {
  final String email;

  VerificationScreen({required this.email});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  TextEditingController codeController = TextEditingController();
  bool isLoading = false;
  String message = "";

  Future<void> verifyCode() async {
    setState(() {
      isLoading = true;
      message = "";
    });

    final url = Uri.parse("http://127.0.0.1:5000/auth/verify");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": widget.email,
        "code": codeController.text,
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        message = data["message"] ?? "Doğrulama başarılı!";
      });
      // Burada ana sayfaya veya başka bir ekrana yönlendirebilirsin
      // Navigator.pushReplacement(...)
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        message = data["message"] ?? "Doğrulama başarısız!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doğrulama Kodu Gir"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("E-postana gelen 6 haneli kodu gir:"),
            SizedBox(height: 10),
            TextField(
              controller: codeController,
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "123456",
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: verifyCode,
                    child: Text("Doğrula"),
                  ),
            SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}
