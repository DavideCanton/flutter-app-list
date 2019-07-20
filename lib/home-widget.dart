import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'channel-wrapper.dart';
import 'models/appinfo.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _items = <AppInfo>[];
  var _message = '';
  final channel = ChannelWrapper();

  @override
  void initState() {
    super.initState();
    _initApps();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: buildBody(),
      );

  Widget buildBody() => _message.isNotEmpty
      ? Center(child: Text(_message))
      : ListView.separated(
          itemBuilder: (BuildContext ctx, int index) {
            final item = _items[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                  leading: _getImageWidget(item),
                  title: Row(
                    children: <Widget>[
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(item.displayName ?? item.name),
                      )),
                      _getSizeWidget(item)
                    ],
                  )),
            );
          },
          separatorBuilder: (BuildContext ctx, int index) => const Divider(
                height: 1.0,
              ),
          itemCount: _items.length);

  Future<void> _initApps() async {
    try {
      await channel.grantPermission();
      final infos = await channel.getApps();

      setState(() {
        _items.clear();
        _items.addAll(infos);
        _message = '';
      });

      for (final info in infos) {
        await Future.wait<dynamic>(<Future<dynamic>>[_getIcon(info), _getSize(info)]);
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

  Future<void> _getSize(AppInfo info) async {
    try {
      setState(() {
        info.sizeLoading = true;
      });

      final bs = await channel.getSize(info);

      setState(() {
        info.sizeInfo = bs;
        info.sizeLoading = false;
      });
    } on Exception {
      setState(() {
        info.sizeLoading = false;
      });
    }
  }

  Future<void> _getIcon(AppInfo info) async {
    try {
      setState(() {
        info.imageLoading = true;
      });

      final bs = await channel.getIcon(info);

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

  Widget _getImageWidget(AppInfo item) {
    if (item.imageLoading)
      return Image.asset('assets/loading.gif');

    if (item.imageError.isNotEmpty)
      return const Text('E');

    if (item.image != null)
      return Image.memory(
        item.image,
        fit: BoxFit.scaleDown,
      );

    return const Text('');
  }

  Widget _getSizeWidget(AppInfo item) {
    if (item.sizeLoading)
      return Image.asset('assets/loading.gif');

    if (item.sizeInfo == null)
      return const SizedBox.shrink();

    return Table(
      columnWidths: const {
        0: FixedColumnWidth(50),
        1: FixedColumnWidth(5),
        2: FixedColumnWidth(70),
      },
      children: <TableRow>[
        makeTableRow('Apk: ', _humanReadableByteCount(item.sizeInfo.apkSize)),
        makeTableRow('Cache: ', _humanReadableByteCount(item.sizeInfo.cache)),
        makeTableRow('Data: ', _humanReadableByteCount(item.sizeInfo.data)),
        makeTableRow('Total: ', _humanReadableByteCount(item.sizeInfo.totalSize)),
      ],
    );
  }

  String _humanReadableByteCount(int bytes) {
    const int unit = 1024;

    if (bytes < unit)
      return bytes.toString() + ' B';

    final exp = log(bytes) ~/ log(unit);
    final pre = 'KMGTPE'[exp - 1];
    final size = bytes / pow(unit, exp);
    return '${size.toStringAsFixed(1)} ${pre}B';
  }

  TableRow makeTableRow(String s, String b) => TableRow(children: <TableCell>[
        TableCell(
          child: Text(s, textAlign: TextAlign.right),
        ),
        const TableCell(child: SizedBox.shrink()),
        TableCell(
          child: Text(b),
        ),
      ]
  );
}
