import 'package:flutter/material.dart';

class ImageDescriptionScreen extends StatelessWidget {
  final String imageUrl;

  const ImageDescriptionScreen({required this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이미지 설명'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(imageUrl),
            const SizedBox(height: 20),
            const Text(
              '여기에 GPT에서 가져온 이미지 설명이 표시됩니다.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
