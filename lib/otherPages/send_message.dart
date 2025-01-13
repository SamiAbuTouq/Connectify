import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SendMessagePage extends StatefulWidget {
  const SendMessagePage({super.key});

  @override
  _SendMessagePageState createState() => _SendMessagePageState();
}

class _SendMessagePageState extends State<SendMessagePage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();

  Future<void> _sendMessage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated");
      }

      // Call Firebase Function
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('sendEmail');
      final result = await callable.call({
        'message': _messageController.text.trim(),
        'recipientEmail': _recipientController.text.trim(),
      });

      if (result.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message sent successfully')),
        );
      } else {
        throw Exception("Error sending email");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Send Message')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _recipientController,
              decoration: InputDecoration(
                labelText: 'Recipient Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendMessage,
              child: Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }
}
