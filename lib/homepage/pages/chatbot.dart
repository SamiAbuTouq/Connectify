import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _userInput = TextEditingController();
  static const apiKey = "AIzaSyCpBfTq1I0sT7Ia-mnWTccyIVc9Mx2rP1k";
  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  final List<Message> _messages = [];

  Future<void> sendMessage() async {
    final message = _userInput.text;
    setState(() {
      _messages
          .add(Message(isUser: true, message: message, date: DateTime.now()));
    });

    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    setState(() {
      _messages.add(Message(
          isUser: false, message: response.text ?? "", date: DateTime.now()));
    });
  }

  @override
  void initState() {
    super.initState();
    _messages.add(
      Message(
        isUser: false,
        message: '''Welcome to Connectify! 

I'm your AI assistant here to help with:
- Finding and connecting with service providers for your needs.
- Managing your subscriptions and getting the best out of Connectify.

How can I assist you today?''',
        date: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chatbot",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "F1",
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return Container(
                      margin: EdgeInsets.only(
                        top: index == 0 ? 10 : 0,
                        bottom: 10,
                        left: message.isUser ? 50 : 0,
                        right: message.isUser ? 0 : 50,
                      ),
                      child: Messages(
                        isUser: message.isUser,
                        message: message.message,
                        date: DateFormat('HH:mm').format(message.date),
                      ),
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 35),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _userInput,
                        decoration: InputDecoration(
                          hintText: 'Message chatbot',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        if (_userInput.text.isNotEmpty) {
                          sendMessage();
                          _userInput.clear();
                        }
                      },
                      icon: const Icon(Icons.send_rounded),
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;

  Message({required this.isUser, required this.message, required this.date});
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;

  const Messages({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 10,
        left: isUser ? 50 : 0,
        right: isUser ? 0 : 50,
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue : Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: isUser
                        ? Colors.white
                        : const Color.fromARGB(255, 56, 86, 139),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: isUser ? Colors.white70 : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
