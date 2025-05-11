import 'package:flutter/material.dart';
import 'package:flutter_youtube_simple_gemini/widget/chat_widget.dart';

class ChatScreen extends StatefulWidget {
  final String title;
  final String? apiKey;
  const ChatScreen({super.key, required this.apiKey, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
      ),
      body: ChatWidget(
        apiKey: widget.apiKey,
      ),
    );
  }
}
