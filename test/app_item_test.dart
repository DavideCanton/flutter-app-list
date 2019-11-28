// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:app_list_manager/app-item-widget.dart';
import 'package:app_list_manager/models/appinfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestList extends StatelessWidget {
  final infos = <AppInfo>[];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: ListView(
      children: infos.map((i) => AppItemWidget(item: i)).toList(),
    )));
  }
}

void main() {
  testWidgets('App Item test', (WidgetTester tester) async {
    final info = AppInfo();
    info.displayName = 'PROVA';
    info.image = File('test/data/a.png').readAsBytesSync();
    info.sizeInfo = AppSizeInfo.fromData(12, 34, 45);

    final widget = TestList();
    widget.infos.add(info);
    await tester.pumpWidget(widget);

    expect(find.text(info.displayName), findsOneWidget);
    expect(find.byElementType(Image), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });
}
