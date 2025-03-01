import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({
    super.key,
    required this.userId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool hasSelectedRoutes = false;
  List<dynamic> userRoutes = [];

  @override
  void initState() {
    super.initState();
    _checkRouteSelection();
  }

  Future<void> _checkRouteSelection() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/user/${widget.userId}/routes'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          hasSelectedRoutes = data['has_selected_routes'];
          userRoutes = data['routes'];
        });
        
        if (!hasSelectedRoutes) {
          _showRouteSelectionPrompt();
        }
      }
    } catch (e) {
      print('Error checking route selection: $e');
    }
  }

  void _showRouteSelectionPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Rotalarınızı Seçin'),
        content: const Text('Sizin için en uygun rotaları seçerek başlayalım.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToRouteSelection();
            },
            child: const Text('Şimdi Seç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Sonra'),
          ),
        ],
      ),
    );
  }

  void _navigateToRouteSelection() {
    // You'll implement this navigation later
    print('Navigate to route selection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navibu'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hoş Geldiniz (ID: ${widget.userId})',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.search, color: Color(0xFF1976D2)),
                title: const Text('Rota Ara'),
                subtitle: const Text('İstediğiniz rotayı bulun'),
                onTap: () {
                  // Navigation will be handled later
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.favorite, color: Color(0xFF1976D2)),
                title: const Text('Favori Rotalar'),
                subtitle: Text(hasSelectedRoutes 
                  ? '${userRoutes.length} seçili rota' 
                  : 'Henüz rota seçilmedi'),
                onTap: _navigateToRouteSelection,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.history, color: Color(0xFF1976D2)),
                title: const Text('Son Görüntülenenler'),
                subtitle: const Text('En son baktığınız rotalar'),
                onTap: () {
                  // Navigation will be handled later
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Popüler Rotalar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 160,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 100,
                            color: const Color(0xFF1976D2),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.route,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rota ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  '10 durak',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 2) { // Profile tab
            _navigateToRouteSelection();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.route),
            label: 'Rotalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
} 