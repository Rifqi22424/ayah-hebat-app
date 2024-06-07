// import 'dart:async';
import 'package:ayahhebat/main.dart';
import 'package:ayahhebat/src/widgets/no_glow_behavior.dart';
import 'package:flutter/material.dart';

import 'routes/route_generator.dart';
// import 'package:uni_links/uni_links.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // StreamSubscription? _sub;
  // late AppLinks _appLinks;

  // @override
  // void initState() {
  //   super.initState();
  //   _appLinks = AppLinks();

  //   _appLinks.uriLinkStream.listen((Uri? uri) {
  //     if (uri != null) {
  //       _handleIncomingLink(uri);
  //     }
  //   });
  //   initUniLinks();
  // }

  // void _handleIncomingLink(Uri uri) {
  //   String path = uri.path;
  //   String? data = uri.queryParameters['data'];

  //   if (path == '/forgot' && data != null) {
  //     Navigator.pushNamed(context, '/forgot', arguments: data);
  //   }
  //   print("masuk");
  // }

  // Future<void> initUniLinks() async {
  //   // ... check initialLink
  //   final initialLink = await getInitialLink();
  //   // Attach a listener to the stream
  //   _sub = linkStream.listen((String? link) {
  //     // Parse the link and warn the user, if it is not correct
  //     print("$link masuk ini");
  //   }, onError: (err) {
  //     // Handle exception by warning the user their action did not succeed
  //     print("gamasuk");
  //   });

  //   // NOTE: Don't forget to call _sub.cancel() in dispose()
  // }
  // StreamSubscription? _sub;

  // @override
  // void initState() {
  //   super.initState();
  //   initUniLinks();
  // }

  // Future<void> initUniLinks() async {
  //   _sub = uriLinkStream.listen((Uri? uri) {
  //     print("MASUK");
  //   }, onError: (err) {
  //     print("ERROR");
  //     // Handle error
  //   });
  // }

  // @override
  // void dispose() {
  //   _sub?.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: NoGlowBehavior(),
          child: child!,
        );
      },
      theme: ThemeData(useMaterial3: false, fontFamily: 'Lato'),
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RouteGenerator.generateRoute,
      navigatorKey: navigatorKey,
    );
  }
}
