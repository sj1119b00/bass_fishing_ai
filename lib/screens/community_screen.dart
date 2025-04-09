import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/upload_catch_form.dart'; // ✅ 상대경로로 import 수정

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<dynamic> catches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCatches();
  }

  Future<void> fetchCatches() async {
    try {
      final response = await http.get(
        Uri.parse('https://bass-ai-api.onrender.com/catches'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          catches = data['catches'];
          isLoading = false;
        });
      } else {
        throw Exception('불러오기 실패');
      }
    } catch (e) {
      print('오류: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티'),
        backgroundColor: const Color(0xFF80CBC4),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : catches.isEmpty
          ? const Center(child: Text("업로드된 조과가 없습니다."))
          : ListView.builder(
        itemCount: catches.length,
        itemBuilder: (context, index) {
          final item = catches[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    item['image_url'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: Text("이미지 불러오기 실패")),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['spot_name'] ?? '포인트 이름 없음',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("📍 위치: ${item['address'] ?? '주소 없음'}"),
                      const SizedBox(height: 2),
                      Text("🎣 채비: ${item['rig'] ?? '정보 없음'}"),
                      const SizedBox(height: 2),
                      Text("🕓 날짜: ${item['timestamp'] ?? '시간 없음'}",
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // 전체화면처럼 보이게
            backgroundColor: Colors.transparent,
            builder: (context) => DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.9,
              minChildSize: 0.6,
              maxChildSize: 0.95,
              builder: (_, scrollController) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: UploadCatchForm(), // ✅ 그대로 사용
                ),
              ),
            ),
          );
        },
        child: const Icon(Icons.add, size: 28),
        backgroundColor: const Color(0xFF80CBC4),
        foregroundColor: Colors.white,
      ),
    );
  }
}
