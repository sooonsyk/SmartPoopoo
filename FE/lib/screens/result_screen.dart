//screens/result_screen.dart

import 'package:flutter/material.dart';
import '../services/chatgpt_service.dart';

class ResultScreen extends StatefulWidget {
  final String imageUrl;

  const ResultScreen({super.key, required this.imageUrl});

  @override
  ResultScreenState createState() => ResultScreenState();
}

class ResultScreenState extends State<ResultScreen> {
  String? description;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDescription();
  }

  Future<void> _fetchDescription() async {
    final chatGptService = ChatGptService();
    try {
      final result =
          await chatGptService.fetchImageDescription(widget.imageUrl);
      setState(() {
        description = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        description = 'Failed to fetch description';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Description'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.network(widget.imageUrl),
                  const SizedBox(height: 20),
                  Text(description ?? 'No description available',
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
    );
  }
}
