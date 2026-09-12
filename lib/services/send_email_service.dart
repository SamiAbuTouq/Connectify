import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:connectify/widgets/circular_progress_indicator.dart';

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
      builder: (context) => const Center(child: SplachScreenLoader()),
    );

    final sendReport = await send(emailMessage, smtpServer);
    debugPrint('Message sent: $sendReport');

    // Dismiss the loading indicator
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Mail Sent Successfully")));
    }
  } on MailerException catch (e) {
    // Dismiss the loading indicator if sending fails
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to send email: ${e.message}")));
    }

    debugPrint('Message not sent: ${e.message}');
    for (var p in e.problems) {
      debugPrint('Problem: ${p.code}: ${p.msg}');
    }
  }
}
