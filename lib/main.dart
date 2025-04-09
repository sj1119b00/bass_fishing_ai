import 'package:flutter/material.dart';
import 'package:bass_fishing_ai_clean_start/screens/point_recommend_screen.dart';
import 'screens/community_screen.dart'; // 추가

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '배스낚시 AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF80CBC4)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2;

  final List<Widget> _pages = [
    const Center(child: Text("지도", style: TextStyle(fontSize: 20))),
    const CommunityScreen(), // ← 여기!
    const PointRecommendScreen(),
    const Center(child: Text("쇼핑", style: TextStyle(fontSize: 20))),
    const Center(child: Text("설정", style: TextStyle(fontSize: 20))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
        backgroundColor: Color(0xFF80CBC4),
        foregroundColor: Color(0xFF212121),
        shape: const CircleBorder(),
        child: const Icon(Icons.explore, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xFF6C5CE7),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.map), label: '지도'),
            BottomNavigationBarItem(icon: Icon(Icons.forum), label: '커뮤니티'),
            BottomNavigationBarItem(icon: Icon(Icons.circle, color: Colors.transparent), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: '쇼핑'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
          ],
        ),
      ),
    );
  }
}
