import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteSelectionScreen extends StatefulWidget {
  final int userId;

  RouteSelectionScreen({required this.userId});

  @override
  _RouteSelectionScreenState createState() => _RouteSelectionScreenState();
}

class _RouteSelectionScreenState extends State<RouteSelectionScreen> {
  List<String> routes = [];
  List<String> selectedRoutes = [];

  @override
  void initState() {
    super.initState();
    fetchRoutes();
  }

  Future<void> fetchRoutes() async {
    final url = Uri.parse("http://127.0.0.1:5000/routes");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        routes = List<String>.from(data["routes"]);
      });
    }
  }

  Future<void> saveSelectedRoutes() async {
    final url = Uri.parse("http://127.0.0.1:5000/user/select_routes");
    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": widget.userId,
        "selected_routes": selectedRoutes,
      }),
    );

    Navigator.pushReplacementNamed(context, "/home");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hat Seçimi")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: routes.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(routes[index]),
                  value: selectedRoutes.contains(routes[index]),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        selectedRoutes.add(routes[index]);
                      } else {
                        selectedRoutes.remove(routes[index]);
                      }
                    });
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: saveSelectedRoutes,
            child: Text("Kaydet ve Devam Et"),
          ),
        ],
      ),
    );
  }
}
