import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../screens/address_search_page.dart';

class UploadCatchForm extends StatefulWidget {
  const UploadCatchForm({super.key});

  @override
  State<UploadCatchForm> createState() => _UploadCatchFormState();
}

class _UploadCatchFormState extends State<UploadCatchForm> {
  File? _imageFile;
  String? _rig;
  final _spotController = TextEditingController();
  final _addressController = TextEditingController();
  String _timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  final List<String> _rigOptions = ['다운샷', '노싱커', '텍사스리그', '프리리그'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _uploadCatch() async {
    if (_imageFile == null ||
        _rig == null ||
        _spotController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 항목을 입력해주세요.")),
      );
      return;
    }

    //final uri = Uri.parse("http://127.0.0.1:8000/upload_catch");
    final uri = Uri.parse("https://bass-ai-api.onrender.com/upload_catch");

    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('photo', _imageFile!.path));
    request.fields['address'] = _addressController.text;
    request.fields['timestamp'] = _timestamp;
    request.fields['temp'] = "0";
    request.fields['condition'] = "미확인";
    request.fields['rig'] = _rig!;
    request.fields['spot_name'] = _spotController.text;

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("업로드 완료!")),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("업로드 실패: ${response.statusCode}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '조과 업로드',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                )
                    : const Center(child: Text('사진을 선택하세요')),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _rig,
              hint: const Text('채비를 선택하세요'),
              items: _rigOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => _rig = value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _spotController,
              decoration: const InputDecoration(
                labelText: '포인트 이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: '주소',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddressSearchPage()),
                    );
                    if (result != null) {
                      setState(() {
                        _addressController.text = result;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF80CBC4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  ),
                  child: const Text('검색'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerLeft,
              child: Text('시간: $_timestamp'),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _uploadCatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF80CBC4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Icon(Icons.send), // 간단한 업로드 아이콘
              ),
            ),
          ],
        ),
      ),
    );
  }
}
