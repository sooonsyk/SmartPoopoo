// screens/image_description_screen.dart
import 'package:flutter/material.dart';
import '../services/chatgpt_service.dart';

class ImageDescriptionScreen extends StatefulWidget {
  final String imageUrl;

  const ImageDescriptionScreen({
    required this.imageUrl,
    super.key,
  });

  @override
  ImageDescriptionScreenState createState() => ImageDescriptionScreenState();
}

class ImageDescriptionScreenState extends State<ImageDescriptionScreen> {
  final ChatGptService _chatGptService = ChatGptService();
  String? description;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDescription(); // 설명을 API를 통해 가져오기
  }

  Future<void> _fetchDescription() async {
    try {
      final result =
          await _chatGptService.fetchImageDescription(widget.imageUrl);
      setState(() {
        description = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        description = '설명을 가져오는데 실패했습니다: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이미지 설명'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(widget.imageUrl),
                  const SizedBox(height: 20),
                  Text(
                    description ?? '설명이 없습니다.',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}
