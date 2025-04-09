import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddressSearchPage extends StatefulWidget {
  const AddressSearchPage({super.key});

  @override
  State<AddressSearchPage> createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends State<AddressSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _results = [];

  static const String kakaoApiKey = 'KakaoAK 1540a558d6f6c8c6de661572c7ca8b1c';

  Future<void> _onSearch() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    final url = Uri.parse('https://dapi.kakao.com/v2/local/search/keyword.json?query=$keyword');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': kakaoApiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List documents = data['documents'];

        setState(() {
          _results = documents.map<String>((doc) => doc['address_name'] as String).toList();
        });
      } else {
        print("검색 실패: ${response.statusCode}");
        setState(() => _results = []);
      }
    } catch (e) {
      print("오류: $e");
      setState(() => _results = []);
    }
  }

  void _onAddressSelected(String address) {
    Navigator.of(context).pop(address); // 선택된 주소 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주소 검색'),
        backgroundColor: const Color(0xFF80CBC4),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '장소 또는 주소를 입력하세요',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF80CBC4),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('검색'),
                )
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text("검색 결과가 없습니다."))
                  : ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final address = _results[index];
                  return ListTile(
                    title: Text(address),
                    onTap: () => _onAddressSelected(address),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
