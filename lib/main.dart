import 'package:flutter/material.dart';

import 'home-widget.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Application Stats',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        textTheme: Theme.of(context).textTheme.apply(
          fontSizeFactor: 0.9
        )
      ),
      home: const MyHomePage(title: 'Application Stats [Flutter powered!]'),
    );
}
