import 'package:flutter/material.dart';
import 'package:flutter_youtube_simple_gemini/widget/message_widget.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class ChatWidget extends StatefulWidget {
  final String? apiKey;
  const ChatWidget({super.key, required this.apiKey});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  bool _loading = false;

  final ScrollController _scrollController = ScrollController();

  final FocusNode _textFiledFocus = FocusNode();
  final TextEditingController _textController = TextEditingController();
  final List<({Image? image, String? text, bool fromUser})> _generatedContent = [];
  
  @override
  void initState() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: widget.apiKey ?? ''
    );

    _chat = _model.startChat();
    super.initState();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(microseconds: 750),
        curve: Curves.easeInOutCirc
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: widget.apiKey?.isNotEmpty ?? false ?
            ListView.builder(
              controller: _scrollController,
              itemCount: _generatedContent.length,
              itemBuilder: (context, index) {
                final content = _generatedContent[index];
                return MessageWidget(
                  text: content.text,
                  image: content.image,
                  isFromUser: content.fromUser,
                );
              },
            ):
            ListView(
              children: const[
                Text('No API Key found. Please get it from Google AI Studio.'),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onSubmitted: _sendMessage,
                  autofocus: true,
                  focusNode: _textFiledFocus,
                  controller: _textController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(15.0),
                    hintText: 'Enter something ...',
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox.square(
                dimension: 15,
              ),
              IconButton(
                onPressed: (){
                  // to pick the image
                  _pickImage();
                },
                icon: Icon(
                  Icons.image,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              if (!_loading)
                IconButton(
                onPressed: () {
                  // send Gemini
                  _sendMessage(_textController.text);
                },
                icon: Icon(
                  Icons.send,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
              else
                const CircularProgressIndicator()
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _loading = true;
    });

    try {
      _generatedContent.add((image: null, text: message, fromUser: true));

      final response = await _chat.sendMessage(
        Content.text(message)
      );

      final text = response.text;

      _generatedContent.add((image: null, text: text, fromUser: false));
      
      if(text == null) {
        showError('No response from Gemini');
        return;
      } else {
        setState(() {
          _loading = false;
          _scrollDown();
        });
      }
    } catch (e){
      showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      _textFiledFocus.requestFocus();
    }
  }

  Future<dynamic> showError(String message) {
    return showDialog(context: context, builder: (context) {
         return _showErrorMessage(message, context);
      });
  }

  AlertDialog _showErrorMessage(String message, BuildContext context) {
    return AlertDialog(
      title: Text('Something went wrong'),
      content: SingleChildScrollView(
        child: SelectableText(message),
      ),
      actions: [
        TextButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            child: Text('OK')),
      ],
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _loading = true;
      });

      try {
        final bytes = await image.readAsBytes();
        final content = [
          Content.multi([
            TextPart(_textController.text),
            DataPart('image.jpeg', bytes)
          ])
        ];

        _generatedContent.add((
          text: _textController.text,
          image: Image.memory(bytes),
          fromUser: true,
        ));

        var response = await _model.generateContent(content);
        var text = response.text;

        _generatedContent.add((image: null, text: text, fromUser: false));

        if(text == null) {
          showError('No response from Gemini');
          return;
        } else {
          setState(() {
            _loading = false;
            _scrollDown();
          });
        }
      } catch (e){
        showError(e.toString());
        setState(() {
          _loading = false;
        });
      } finally {
        _textController.clear();
        setState(() {
          _loading = false;
        });
        _textFiledFocus.requestFocus();
      }
    }
  }


}
