import 'package:ayahhebat/src/widgets/no_glow_behavior.dart';
import 'package:flutter/material.dart';

import 'routes/route_generator.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
    );
  }
}
