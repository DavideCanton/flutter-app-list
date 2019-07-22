import 'dart:math';

import 'package:flutter/material.dart';

import 'app-item-bloc.dart';
import 'models/appinfo.dart';

class AppItemWidget extends StatefulWidget {
  const AppItemWidget(this.item);

  final AppInfo item;

  @override
  State<StatefulWidget> createState() {
    return _AppItemWidgetState();
  }
}

class _AppItemWidgetState extends State<AppItemWidget> {
  AppItemBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = AppItemBloc(widget.item);
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bloc.loadAppInfo();

    return StreamBuilder<AppInfo>(
      stream: bloc.appsStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
                leading: _getImageWidget(snapshot.data),
                title: Row(
                  children: <Widget>[
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child:
                          Text(snapshot.data.displayName ?? snapshot.data.name),
                    )),
                    _getSizeWidget(snapshot.data)
                  ],
                )),
          );
        }

        if (snapshot.hasError) return ListTile(title: const Text('Errore!'));

        return ListTile(title: const Text('Loading...'));
      },
    );
  }

  Widget _getImageWidget(AppInfo item) {
    if (item.imageError.isNotEmpty) return const Text('E');

    if (item.image != null)
      return Image.memory(
        item.image,
        fit: BoxFit.scaleDown,
      );

    return const Text('');
  }

  Widget _getSizeWidget(AppInfo item) {
    if (item.sizeInfo == null) return const SizedBox.shrink();

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
        makeTableRow(
            'Total: ', _humanReadableByteCount(item.sizeInfo.totalSize)),
      ],
    );
  }

  String _humanReadableByteCount(int bytes) {
    const int unit = 1024;

    if (bytes < unit) return bytes.toString() + ' B';

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
      ]);
}
