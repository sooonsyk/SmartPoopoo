//main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_smartpoo/screens/image_picker_screen.dart';
import 'package:firebase_smartpoo/screens/image_description_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await FirebaseAppCheck.instance.activate(
  //   appleProvider: AppleProvider.debug,
  //   androidProvider: AndroidProvider.debug,
  //  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData(
        primaryColor: const Color(0xFF445DF6),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? selectedImageUrl;
  String defaultImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/fir-smartpoo-c7613.appspot.com/o/1.jpg?alt=media&token=66104d6b-57cf-4b21-a06b-16a5b9780851'; // 기본 이미지 URL

  @override
  void initState() {
    super.initState();
    // 기본적으로 선택된 이미지 URL을 초기화
    selectedImageUrl = defaultImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          title: const Text(
            '스마트푸푸',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuButton(context, "다이어리", () {}, "다이어리 버튼"),
                  _buildMenuButton(context, "firebase", () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ImagePickerScreen(),
                      ),
                    );

                    if (result != null && result is Map) {
                      setState(() {
                        selectedImageUrl = result['imageUrl']; // 선택된 이미지로 업데이트
                      });

                      // 이미지 설명 화면으로 이동 (기본 이미지 혹은 선택된 이미지 사용)
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageDescriptionScreen(
                                imageUrl: selectedImageUrl ??
                                    defaultImageUrl, // 선택되지 않으면 기본 이미지 사용
                              ),
                            ),
                          );
                        }
                      });
                    }
                  }, "Firebase 버튼"),
                  _buildMenuButton(context, "요약통계", () {}, "요약통계 버튼"),
                  _buildMenuButton(context, "마이페이지", () {}, "마이페이지 버튼"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title,
      VoidCallback onPressed, String semanticsLabel) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF445DF6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(20),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
