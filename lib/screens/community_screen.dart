import 'package:flutter/material.dart';
import '../widgets/upload_catch_form.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('커뮤니티')),
      body: const Center(
        child: Text('여기에 커뮤니티 게시물 리스트가 들어올 예정'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => const UploadCatchForm(),
          );
        },
        backgroundColor: const Color(0xFF80CBC4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}