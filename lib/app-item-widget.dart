import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import 'models/appinfo.dart';

class AppItemWidget extends StatelessWidget {
  const AppItemWidget({Key key, this.item}) : super(key: key);

  final AppInfo item;

  double get cardHeight => 120.0;

  double get cardPadding => 8.0;

  double get stroke => 8;

  double get cardInnerHeight => cardHeight - 2 * cardPadding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        splashColor: Colors.orange.withAlpha(30),
        child: Container(
          padding: EdgeInsets.all(cardPadding),
          height: cardHeight,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _getImageWidget(item),
                    Container(
                      width: 200,
                      child: Padding(
                        padding: EdgeInsets.all(cardPadding),
                        child: Text(
                          item.displayName,
                          textScaleFactor: 1.0,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    _getSizeWidget(item),
                  ],
                )
              ],
            ),
            Column(
              children: [buildChart()],
            )
          ]),
        ),
      ),
    );
  }

  Widget buildChart() {
    final size = cardInnerHeight - stroke * 2;
    Widget child;

    if (item.sizeInfo.apkSize + item.sizeInfo.cache + item.sizeInfo.data == 0)
      child = Text('Empty!');
    else
      child = PieChart(
        dataMap: {
          'apk': item.sizeInfo.apkSize.toDouble(),
          'cache': item.sizeInfo.cache.toDouble(),
          'data': item.sizeInfo.data.toDouble()
        },
        legendOptions: const LegendOptions(showLegends: false),
        chartValuesOptions: const ChartValuesOptions(showChartValues: false),
        animationDuration: const Duration(milliseconds: 800),
        chartRadius: size,
        colorList: const [Colors.orange, Colors.blue, Colors.red],
        initialAngleInDegree: -90,
        chartType: ChartType.ring,
        ringStrokeWidth: stroke,
      );

    return Container(
      child: Center(child: child),
      width: cardInnerHeight,
      height: cardInnerHeight,
    );
  }

  Widget _getImageWidget(AppInfo item) {
    if (item.imageError.isNotEmpty) return const Text('E');

    if (item.image != null)
      return Image.memory(
        item.image,
        fit: BoxFit.scaleDown,
        height: cardInnerHeight / 2,
      );

    return const Text('');
  }

  Widget _getSizeWidget(AppInfo item) {
    if (item.sizeInfo == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: cardPadding),
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(120),
        children: <TableRow>[
          TableRow(children: [
            makeTableCell('Apk: ', _humanReadableByteCount(item.sizeInfo.apkSize), Colors.orange),
            makeTableCell('Cache: ', _humanReadableByteCount(item.sizeInfo.cache), Colors.blue)
          ]),
          TableRow(children: [
            makeTableCell('Data: ', _humanReadableByteCount(item.sizeInfo.data), Colors.red),
            makeTableCell('Total: ', _humanReadableByteCount(item.sizeInfo.totalSize), Colors.transparent)
          ])
        ],
      ),
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

  TableCell makeTableCell(String s, String b, Color c) => TableCell(
          child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Container(
              color: c,
              width: 10,
              height: 10,
            ),
            Container(
              width: 5,
            ),
            Text(
              s + b,
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ));
}
