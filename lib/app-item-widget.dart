import 'dart:math';

import 'package:flutter/material.dart';

import 'models/appinfo.dart';

class AppItemWidget extends StatelessWidget {
  const AppItemWidget({Key key, this.item}) : super(key: key);

  final AppInfo item;

  @override
  Widget build(BuildContext context) {
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
