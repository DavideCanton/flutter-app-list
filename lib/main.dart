import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
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
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: _getImage(item),
              title: Text(item.displayName ?? item.name),
            ),
          );
        },
        separatorBuilder: (BuildContext ctx, int index) => Divider(
          height: 1.0,
        ),
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
          infos.add(info);
        }
      }

      setState(() {
        _items.clear();
        _items.addAll(infos);
        _items.sort((a, b) => (a.displayName ?? a.name).compareTo(b.displayName ?? b.name));
        _message = "";
      });

      for(var info in infos) {
        await this._getIcon(info);
      }

    } on PlatformException catch (e) {
      setState(() {
        _items.clear();
        _message = e.message;
      });
    }
  }

  _getIcon(AppInfo info) async {
    try {
      setState(() {
        info.imageLoading = true;
      });

      final result = await _platform.invokeMethod('getIcon', {"name": info.packageName});
      var prefix = "data:image/png;base64,";
      var bStr = result.substring(prefix.length).replaceAll("\n", "");
      var bs = Base64Codec().decode(bStr);

      setState(() {
        info.image = bs;
        info.imageLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        info.imageError = e.toString();
        info.imageLoading = false;
      });
    }
  }

  _getImage(AppInfo item) {
    if(item.imageLoading) {
      return Image.asset("assets/loading.gif");
    }

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

  bool imageLoading = false;
  String displayName;
  String imageError = "";
  String className;
  String dataDir;
  String name;
  String packageName;
}
