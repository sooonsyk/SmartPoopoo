// screens/image_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:SmartPoopoo/services/chatgpt_service.dart';

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  final ChatGptService _chatGptService = ChatGptService();
  List<String> imageUrls = [
    'https://www.nct.org.uk/sites/default/files/3to4.jpg',
    'https://assets.babycenter.com/ims/2009/09sep/poo01_424x302.jpg'
  ];
  String? selectedImageUrl;
  String? imageDescription;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchImageDescription(String imageUrl) async {
    try {
      final description = await _chatGptService.fetchImageDescription(imageUrl);
      setState(() {
        imageDescription = description;
      });
    } catch (e) {
      print('Failed to fetch image description: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이미지 선택'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                final imageUrl = imageUrls[index];
                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      selectedImageUrl = imageUrl;
                      imageDescription = null; // 설명 초기화
                    });
                    await _fetchImageDescription(imageUrl);
                  },
                  child: Image.network(imageUrl),
                );
              },
            ),
          ),
          if (imageDescription != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                imageDescription!,
                style: const TextStyle(fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}
