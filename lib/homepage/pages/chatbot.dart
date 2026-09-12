import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:connectify/utils/responsive_utils.dart';
import 'package:connectify/theme.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _userInput = TextEditingController();
  late final GenerativeModel model;
  final List<Message> _messages = [];

  Future<void> sendMessage() async {
    final message = _userInput.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages
          .add(Message(isUser: true, message: message, date: DateTime.now()));
    });

    try {
      final content = [Content.text(message)];
      final response = await model.generateContent(content);

      setState(() {
        _messages.add(Message(
            isUser: false, message: response.text ?? "", date: DateTime.now()));
      });
    } catch (e) {
      setState(() {
        _messages.add(Message(
            isUser: false,
            message: "Sorry, I'm having trouble connecting right now. Please try again later.",
            date: DateTime.now()));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
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
    final r = Responsive(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Chatbot"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  padding: EdgeInsets.symmetric(
                    horizontal: r.wp(4).clamp(12.0, 24.0),
                    vertical: 10,
                  ),
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return Messages(
                      isUser: message.isUser,
                      message: message.message,
                      date: DateFormat('HH:mm').format(message.date),
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      width: 1,
                    ),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(8, 8, 8, max(8, bottomInset)),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _userInput,
                        onSubmitted: (_) {
                          if (_userInput.text.trim().isNotEmpty) {
                            sendMessage();
                            _userInput.clear();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Message chatbot...',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppTheme.darkSurfaceVariant
                              : AppTheme.lightSurfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        if (_userInput.text.trim().isNotEmpty) {
                          sendMessage();
                          _userInput.clear();
                        }
                      },
                      icon: const Icon(Icons.send_rounded),
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
    final r = Responsive(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final maxBubbleWidth = min(r.width * 0.78, 550.0);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : (isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isUser
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontSize: r.sp(15),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: TextStyle(
                color: isUser
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                    : theme.colorScheme.onSurfaceVariant,
                fontSize: r.sp(11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
