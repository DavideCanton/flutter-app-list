import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _items = List<AppInfo>();
  var _message = "";
  static const _platform = const MethodChannel("com.mdcc.app_list_manager/apps");

  @override
  void initState() {
    super.initState();
    this._initApps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (_message.isNotEmpty) return Center(child: Text(_message));

    return ListView.separated(
        itemBuilder: (BuildContext ctx, int index) {
          final item = _items[index];
          return ListTile(
            leading: _getImage(item),
            title: Text(item.displayName ?? item.name),
          );
        },
        separatorBuilder: (BuildContext ctx, int index) => Divider(),
        itemCount: _items.length);
  }

  Future<void> _initApps() async {
    try {
      final result = await _platform.invokeMethod('getApps');
      final infos = List<AppInfo>();

      for (var itemX in result) {
        var item = Map<String, dynamic>.from(itemX);
        if (item["packageName"] != null) {
          var info = AppInfo(item["className"], item["dataDir"], item["name"], item["packageName"]);
          info.displayName = item["displayName"];

          try {
            var prefix = "data:image/png;base64,";
            var bStr = item["image"].substring(prefix.length).replaceAll("\n", "");
            var bs = Base64Codec().decode(bStr);
            info.image = bs;
          } on Exception catch (e) {
            info.imageError = e.toString();
          }

          infos.add(info);
        }
      }

      setState(() {
        _items.clear();
        _items.addAll(infos);
        _items.sort((a, b) => (a.displayName ?? a.name).compareTo(b.displayName ?? b.name));
        _message = "";
      });
    } on PlatformException catch (e) {
      setState(() {
        _items.clear();
        _message = e.message;
      });
    }
  }

  _getImage(AppInfo item) {
    if (item.imageError.isNotEmpty) return Text("E");

    if (item.image != null)
      return Image.memory(
        item.image,
        fit: BoxFit.scaleDown,
      );

    return Text("");
  }
}

class AppInfo {
  AppInfo(this.className, this.dataDir, this.name, this.packageName);

  Uint8List image;

  String displayName;
  String imageError = "";
  String className;
  String dataDir;
  String name;
  String packageName;
}
