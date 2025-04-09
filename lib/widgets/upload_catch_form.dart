import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class UploadCatchForm extends StatefulWidget {
  const UploadCatchForm({super.key});

  @override
  State<UploadCatchForm> createState() => _UploadCatchFormState();
}

class _UploadCatchFormState extends State<UploadCatchForm> {
  File? _imageFile;
  String? _rig;
  final _spotController = TextEditingController();
  Position? _position;
  String _timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  final List<String> _rigOptions = ['다운샷', '노싱커', '텍사스리그', '프리리그'];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever) {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _position = position;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _uploadCatch() {
    // 여기에 서버 전송 로직 들어갈 예정
    print('사진: ${_imageFile?.path}');
    print('채비: $_rig');
    print('포인트: ${_spotController.text}');
    print('위치: ${_position?.latitude}, ${_position?.longitude}');
    print('시간: $_timestamp');
    Navigator.of(context).pop(); // 업로드 후 팝업 닫기
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

            Align(
              alignment: Alignment.centerLeft,
              child: _position != null
                  ? Text('위치: ${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}')
                  : const Text('위치 가져오는 중...'),
            ),
            const SizedBox(height: 8),

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
                child: const Text('업로드'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}