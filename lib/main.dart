import 'package:flutter/material.dart';

import 'home-widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final swatch = Colors.deepOrange;

    return MaterialApp(
      title: 'Application Stats',
      theme: ThemeData(brightness: Brightness.light, primarySwatch: swatch, primaryColorLight: swatch),
      darkTheme: ThemeData(brightness: Brightness.dark, primarySwatch: swatch, primaryColorDark: swatch),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(title: 'Application Stats [Flutter powered!]'),
    );
  }
}
