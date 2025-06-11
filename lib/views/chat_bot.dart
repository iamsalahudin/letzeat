import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:letzeat/utils/constant.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
  }

  Future<String> _fetchGeminiResponse(String prompt) async {
    final apiKey = dotenv.env['GEMINI_API_KEY']!;
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'text':
                  'You are a friendly, expert chef guiding home cooks through recipes, ingredients, techniques, and kitchen tips. Respond with warmth, clarity, and confidence—like a seasoned chef mentoring someone in their kitchen. Share helpful tricks, suggest ingredient swaps when needed, and explain cooking steps in simple, encouraging terms. When asked, recommend recipes, meal ideas, or adjustments for dietary needs, always with a chef\'s insight and creativity. Reply me focusing on the prompt after this (shortly/detailed/etc) ${prompt}',
            },
          ],
        },
      ],
    });
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final text = candidates[0]['content']['parts'][0]['text'];
          return text ?? "Sorry, I didn't understand that.";
        } else {
          return "Sorry, I didn't understand that.";
        }
      } else {
        print('Gemini API error: ${response.body}');
        return 'Error: ${response.body}';
      }
    } catch (e) {
      print('HTTP Exception: $e');
      return 'Error: $e';
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _controller.clear();
    });

    final reply = await _fetchGeminiResponse(text);
    setState(() {
      _messages.add({'sender': 'bot', 'text': reply});
    });
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    bool isUser = message['sender'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? kBannerColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child:
            isUser
                ? Text(message['text'], style: TextStyle(color: Colors.white))
                : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: MarkdownBody(
                    data: message['text'],
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        color: Colors.black87,
                        fontFamily: 'monospace',
                        fontSize: 15,
                      ),
                      code: TextStyle(
                        backgroundColor: Colors.grey.shade200,
                        fontFamily: 'monospace',
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: Text("Let's Eat AI"),
          backgroundColor: kPrimaryColor,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[_messages.length - 1 - index];
                  return _buildMessage(message);
                },
              ),
            ),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: _sendMessage,
                        decoration: InputDecoration(
                          hintText: "Ask for recipe ideas...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: kPrimaryColor),
                      onPressed: () => _sendMessage(_controller.text),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
