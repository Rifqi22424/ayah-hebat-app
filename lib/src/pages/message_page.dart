import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  final RemoteMessage message;

  const MessagePage({Key? key, required this.message}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  Map<String, dynamic> payload = {};

  @override
  Widget build(BuildContext context) {
    final data = widget.message;
    // for background and terminated state
    if (data.notification != null) {
      payload = data.data;
    }
    // for foreground state
    if (data.notification == null && data.data.isNotEmpty) {
      payload = jsonDecode(data.data['payload']);
    }
    return Scaffold(
      appBar: AppBar(title: Text("Your Message")),
      body: Center(
        child: Column(
          children: [
            Text(payload.toString()),
            Text(payload['hello'])
          ],
        ),
      ),
    );
  }
}
