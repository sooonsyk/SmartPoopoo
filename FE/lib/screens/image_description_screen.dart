import 'package:flutter/material.dart';
import 'package:SmartPoopoo/services/chatgpt_service.dart';

class ImageDescriptionScreen extends StatefulWidget {
  final String imageUrl;

  const ImageDescriptionScreen({required this.imageUrl, super.key});

  @override
  _ImageDescriptionScreenState createState() => _ImageDescriptionScreenState();
}

class _ImageDescriptionScreenState extends State<ImageDescriptionScreen> {
  String description = '이미지 설명을 불러오는 중...';
  final ChatGptService chatGptService = ChatGptService(); // 서비스 인스턴스 생성

  @override
  void initState() {
    super.initState();
    fetchDescription();
  }

  Future<void> fetchDescription() async {
    try {
      // ChatGptService에서 이미지 설명을 가져옵니다.
      String result =
          await chatGptService.fetchImageDescription(widget.imageUrl);
      setState(() {
        description = result;
      });
    } catch (e) {
      setState(() {
        description = '설명을 불러오지 못했습니다: $e';
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: '이미지 설명: $description',
              child: Image.network(widget.imageUrl),
            ),
            const SizedBox(height: 20),
            Semantics(
              label: description,
              child: Text(
                description,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
