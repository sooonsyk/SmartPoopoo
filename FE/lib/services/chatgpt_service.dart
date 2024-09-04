//services/chatgpt_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart' as config;

class ChatGptService {
  // 환경 변수에서 API 키와 BASE URL 가져오기
  final String apiKey = config.APIKEY;

  // 이미지 설명을 가져오는 함수
  Future<String> fetchImageDescription(String imageUrl) async {
    // OpenAI API의 URI
    final uri = Uri.parse(config.URI);

    // 요청에 사용될 헤더
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $apiKey',
    };

    // 요청에 사용될 Body (이미지 URL 포함)
    final body = json.encode({
      'model': 'gpt-4o-mini',
      'messages': [
        {
          'role': 'system',
          'content':
              'You are a helpful assistant for the visually impaired, capable of identifying ANYTHING in images.'
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text':
                  '이 이미지에서 변이 의미하는 건강 상태를 설명해줘. 한국어로만 대답해주고, 배경이나 손가락 등이 아니라 오로지 변에만 집중해줘.'
            },
            {
              'type': 'image_url',
              'image_url': {
                'url':
                    'https://www.nct.org.uk/sites/default/files/3to4.jpg', // Firebase에서 전달된 이미지 URL 사용하는 걸로 바꾸기
              }
            }
          ]
        }
      ],
      'max_tokens': 200,
    });

    // API 요청 보내기
    print("Sending POST request to OpenAI API...");
    var response = await http.post(
      uri,
      headers: headers,
      body: body,
    );

    final decodedResponse = utf8.decode(response.bodyBytes);

    // 요청 결과 처리
    print("Received response with status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = jsonDecode(decodedResponse);
      print("API call successful, parsing response data...");
      return data['choices'][0]['message']['content']; // API 응답에서 설명 가져오기
    } else {
      print("API call failed, status code: ${response.statusCode}");
      throw Exception(
          'Failed to fetch image description. Status code: ${response.statusCode}');
    }
  }
}
