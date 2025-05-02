import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'chat_screen.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(GenerativeAiSample(apiKey: dotenv.env['GEMINI_API_KEY']));
}

class GenerativeAiSample extends StatelessWidget {
  const GenerativeAiSample({super.key, this.apiKey});

  final String? apiKey;

  @override
  Widget build(BuildContext context) {
    print(apiKey);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyChatbot',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(255, 171, 222, 244),
        ),
      ),
      home: ChatScreen(apiKey: apiKey, title: 'Gemini AI'),
    );
  }
}
