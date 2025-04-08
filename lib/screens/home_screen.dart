import 'package:flutter/material.dart';
import 'point_recommend_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const PointRecommendScreen(),
    Center(child: Text('채비 추천')),
    Center(child: Text('패턴 분석')),
    Center(child: Text('사진 인식')),
    Center(child: Text('커뮤니티')),
  ];

  final List<String> _titles = [
    '포인트 추천',
    '채비 추천',
    '패턴 분석',
    '사진 인식',
    '커뮤니티',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '포인트'),
          BottomNavigationBarItem(icon: Icon(Icons.construction), label: '채비'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: '패턴'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: '사진'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: '커뮤니티'),
        ],
      ),
    );
  }
}
