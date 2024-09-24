import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:SmartPoopoo/services/config.dart' as config;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatBotScreen extends StatefulWidget {
  final String analysisResult;
  const ChatBotScreen({super.key, required this.analysisResult});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  late String initialAnalysis;
  final _openAI = OpenAI.instance.build(
    token: config.apiKey,
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 5),
    ),
    enableLog: true,
  );

  final ChatUser _user =
      ChatUser(id: '1', firstName: "Giseon", lastName: "Park");

  final ChatUser _gptChatUser =
      ChatUser(id: '2', firstName: "Chat", lastName: "GPT");

  final List<ChatMessage> _messages = <ChatMessage>[];
  final List<ChatUser> _typingUsers = <ChatUser>[];

  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _text = "";

  @override
  void initState() {
    super.initState();
    initialAnalysis = widget.analysisResult;
    /*_messages.add(
      ChatMessage(
        text: 'Hey!',
        user: _user,
        createdAt: DateTime.now(),
      ),
    );*/
  }

  void _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speechToText.listen(onResult: (val) {
        setState(() {
          _text = val.recognizedWords;
          if (!_speechToText.isListening) {
            _sendMessageFromVoice();
          }
        });
      });
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _speechToText.stop();
  }

  void _sendMessageFromVoice() {
    if (_text.isNotEmpty) {
      ChatMessage message = ChatMessage(
        text: _text,
        user: _user,
        createdAt: DateTime.now(),
      );
      getChatResponse(message); // DashChat에 메시지 추가
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(68, 93, 246, 1),
        title: const Text(
          '푸푸챗',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: DashChat(
                  currentUser: _user,
                  messageOptions: const MessageOptions(
                    currentUserContainerColor: Color.fromARGB(255, 255, 168, 7),
                    containerColor: Color.fromRGBO(68, 93, 246, 1),
                    textColor: Colors.white,
                  ),
                  onSend: (ChatMessage m) {
                    getChatResponse(m);
                  },
                  messages: _messages,
                  typingUsers: _typingUsers,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Semantics(
                label: _isListening ? '음성 입력 중' : '음성 입력 시작',
                hint: '이 버튼을 눌러 음성 입력을 시작하거나 중지할 수 있습니다.',
                child: GestureDetector(
                  onTap: _isListening ? _stopListening : _startListening,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUsers.add(_gptChatUser);
    });

    List<Map<String, dynamic>> messageHistory = [
      Messages(role: Role.system, content: initialAnalysis).toJson(),
      ..._messages.reversed.toList().map((m) {
        if (m.user == _user) {
          return Messages(role: Role.user, content: m.text).toJson();
        } else {
          return Messages(role: Role.assistant, content: m.text).toJson();
        }
      }),
    ];

    final request = ChatCompleteText(
      model: Gpt4OChatModel(),
      messages: messageHistory,
      maxToken: 200,
    );
    final response = await _openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _messages.insert(
              0,
              ChatMessage(
                  user: _gptChatUser,
                  createdAt: DateTime.now(),
                  text: element.message!.content));
        });
      }
    }
    setState(() {
      _typingUsers.remove(_gptChatUser);
    });
  }
}
