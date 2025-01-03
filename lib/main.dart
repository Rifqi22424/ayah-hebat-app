import 'dart:convert';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'src/my_app.dart';
import 'src/providers/book_category_provider.dart';
import 'src/providers/book_detail_provider.dart';
import 'src/providers/book_provider.dart';
import 'src/providers/borrow_book_provider.dart';
import 'src/providers/borrow_books_provider.dart';
import 'src/providers/comment_provider.dart';
import 'src/providers/donation_book_provider.dart';
import 'src/providers/donation_books_provider.dart';
import 'src/providers/office_address_provider.dart';
import 'src/providers/post_provider.dart';
import 'src/services/notification_service.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// const serverPath = "https://dhrqldvp-3000.asse.devtunnels.ms";
const serverPath = "https://backend.ayahhebat.mangcoding.com";

final navigatorKey = GlobalKey<NavigatorState>();

Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Some notification Received in background...");
  }
}

// to handle notification on foreground on web platform
void showNotification({required String title, required String body}) {
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Ok"))
      ],
    ),
  );
}

main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // initialize firebase messaging
  await PushNotifications.init();

  await PushNotifications.getDeviceToken();

  // initialize local notifications
  // dont use local notifications for web platform
  if (!kIsWeb) {
    await PushNotifications.localNotiInit();
  }

  // Listen to background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // on background notification tapped
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("Background Notification Tapped");
      navigatorKey.currentState!.pushNamed("/message", arguments: message);
    }
  });

// to handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print("Got a message in foreground");
    if (message.notification != null) {
      if (kIsWeb) {
        showNotification(
            title: message.notification!.title!,
            body: message.notification!.body!);
      } else {
        PushNotifications.showSimpleNotification(
            title: message.notification!.title!,
            body: message.notification!.body!,
            payload: payloadData);
      }
    }
  });

  // for handling in terminated state
  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {
    print("Launched from terminated state");
    Future.delayed(Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed("/message", arguments: message);
    });
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => BookCategoryProvider()),
        ChangeNotifierProvider(create: (_) => BookDetailProvider()),
        ChangeNotifierProvider(create: (_) => BorrowBooksProvider()),
        ChangeNotifierProvider(create: (_) => BorrowBookProvider()),
        ChangeNotifierProvider(create: (_) => DonationBooksProvider()),
        ChangeNotifierProvider(create: (_) => DonationBookProvider()),
        ChangeNotifierProvider(create: (_) => OfficeAddressProvider()),
      ],
      child: DevicePreview(
        enabled: true,
        tools: const [
          ...DevicePreview.defaultTools,
        ],
        builder: (context) => const MyApp(),
      ),
    ),
  );

  FlutterNativeSplash.remove();
}
