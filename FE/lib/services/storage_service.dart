// services/storage_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 이미지 업로드 함수
  Future<String> uploadImage(File image) async {
    try {
      String filePath = 'images/${DateTime.now()}.png';
      final ref = _storage.ref().child(filePath);
      await ref.putFile(image);
      return await ref.getDownloadURL(); // 업로드한 파일의 URL 반환
    } catch (e) {
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  // Firebase에 저장된 이미지 URL 리스트 불러오기
  Future<List<String>> getImages() async {
    try {
      // Firebase Storage의 'images/' 폴더 내에 있는 모든 파일의 참조를 가져오기
      final ListResult result = await FirebaseStorage.instance.ref().listAll();
      List<String> urls = [];

      // 각 파일의 다운로드 URL을 가져오기
      for (var ref in result.items) {
        String url = await ref.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      logger.e('Failed to load images: $e');
      return [];
    }
  }
}
