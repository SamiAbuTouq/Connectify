import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

sendEmail(BuildContext context, String subject, String message) async {
  String username = 'samiabuobida2@gmail.com';
  String password = 'cgdo rhef xjut qvfp';
  final smtpServer = gmail(username, password);

  final emailMessage = Message()
    ..from = Address(username, 'Connectify Support')
    ..recipients.add('samiabuobida3@gmail.com')
    ..subject = subject
    ..text = message;

  try {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final sendReport = await send(emailMessage, smtpServer);
    print('Message sent: ' + sendReport.toString());

    // Dismiss the loading indicator
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Mail Sent Successfully")));
  } on MailerException catch (e) {
    // Dismiss the loading indicator if sending fails
    Navigator.of(context).pop();

    print('Message not sent.');
    print(e.message);
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}
