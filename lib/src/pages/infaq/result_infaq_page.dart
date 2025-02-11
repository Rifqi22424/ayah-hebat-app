import 'dart:convert';
import 'package:ayahhebat/src/widgets/app_bar_builder.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ResultInfaqPage extends StatefulWidget {
  final RemoteMessage message;

  const ResultInfaqPage({Key? key, required this.message}) : super(key: key);

  @override
  State<ResultInfaqPage> createState() => _ResultInfaqPageState();
}

class _ResultInfaqPageState extends State<ResultInfaqPage> {
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
      appBar: AppBarBuilder(title: ""),
      body: Center(
        child: Column(
          children: [
            Text(payload.toString()),
            Text(payload['status'])
          ],
        ),
      ),
    );
  }
}
