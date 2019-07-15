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
  static const _platform =
      const MethodChannel("com.mdcc.app_list_manager/apps");

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
            title: Text("${item.name}"),
          );
        },
        separatorBuilder: (BuildContext ctx, int index) => Divider(),
        itemCount: _items.length);
  }

  Future<void> _initApps() async {
    try {
      final result = await _platform.invokeMethod('getApps');
      setState(() async {
        _items.clear();

        for (var itemX in result) {
          var item = Map<String, dynamic>.from(itemX);
          var info = AppInfo(item["className"], item["dataDir"], item["name"],
              item["packageName"]);
          _items.add(info);

          var img = await _platform
              .invokeMethod('getIcon', {"name": info.packageName});

          var prefix = "data:image/png;base64,";
          var bStr = img.substring(prefix.length);
          var bs = Base64Codec().decode(bStr.codeUnits);

          info.image = bs;
        }

        _message = "";
      });
    } on PlatformException catch (e) {
      setState(() {
        _items.clear();
        _message = e.message;
      });
    }
  }
}

class AppInfo {
  AppInfo(this.className, this.dataDir, this.name, this.packageName);

  Uint8List image;
  String className;
  String dataDir;
  String name;
  String packageName;
}
