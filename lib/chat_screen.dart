import 'package:flutter/cupertino.dart';

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
    return const Placeholder();
  }
}
