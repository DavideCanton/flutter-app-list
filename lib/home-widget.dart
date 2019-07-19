import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'channel-wrapper.dart';
import 'models/appinfo.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _items = List<AppInfo>();
  var _message = "";
  final channel = ChannelWrapper();

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
                title: Row(
                  children: <Widget>[Expanded(child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(item.displayName ?? item.name),
                  )), _getSizes(item)],
                )),
          );
        },
        separatorBuilder: (BuildContext ctx, int index) => Divider(
              height: 1.0,
            ),
        itemCount: _items.length);
  }

  Future<void> _initApps() async {
    try {
      await channel.grantPermission();
      final infos = await channel.getApps();

      setState(() {
        _items.clear();
        _items.addAll(infos);
        _message = "";
      });

      for (var info in infos) {
        await Future.wait(<Future>[this._getIcon(info), this._getSize(info)]);
      }

      setState(() {
        _items.sort(AppInfo.byTotalSizeDesc());
      });
    } on PlatformException catch (e) {
      setState(() {
        _items.clear();
        _message = e.message;
      });
    }
  }

  _getSize(AppInfo info) async {
    try {
      setState(() {
        info.sizeLoading = true;
      });

      var bs = await channel.getSize(info);

      setState(() {
        info.sizeInfo = bs;
        info.sizeLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        info.sizeLoading = false;
      });
    }
  }

  _getIcon(AppInfo info) async {
    try {
      setState(() {
        info.imageLoading = true;
      });

      var bs = await channel.getIcon(info);

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
    if (item.imageLoading) {
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

  _getSizes(AppInfo item) {
    if (item.sizeLoading) {
      return Image.asset("assets/loading.gif");
    }

    if (item.sizeInfo == null) return SizedBox.shrink();

    return Table(
      columnWidths: {
        0: FixedColumnWidth(50),
        1: FixedColumnWidth(5),
        2: FixedColumnWidth(70),
      },
      children: <TableRow>[
        makeTableRow("Apk: ", humanReadableByteCount(item.sizeInfo.apkSize)),
        makeTableRow("Cache: ", humanReadableByteCount(item.sizeInfo.cache)),
        makeTableRow("Data: ", humanReadableByteCount(item.sizeInfo.data)),
        makeTableRow("Total: ", humanReadableByteCount(item.sizeInfo.totalSize)),
      ],
    );
  }

  String humanReadableByteCount(int bytes) {
    var unit = 1024;
    if (bytes < unit) return bytes.toString() + " B";
    int exp = log(bytes) ~/ log(unit);
    String pre = "KMGTPE"[exp - 1];
    var size = bytes / pow(unit, exp);
    return "${size.toStringAsFixed(1)} ${pre}B";
  }

  TableRow makeTableRow(String s, String b) {
    return TableRow(children: <TableCell>[
      TableCell(
        child: Text(s, textAlign: TextAlign.right),
      ),
      TableCell(child: SizedBox.shrink()),
      TableCell(
        child: Text(b),
      ),
    ]);
  }
}
