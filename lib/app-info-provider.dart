import 'dart:typed_data';

import 'channel-wrapper.dart';
import 'models/appinfo.dart';

class AppInfoProvider {
  final channel = ChannelWrapper();

  Future<AppInfo> getAppInfo(AppInfo item) async {
    final results = await Future.wait([_getIcon(item), _getSize(item)]);

    item.image = results[0];
    item.sizeInfo = results[1];

    item.sizeLoading = false;
    item.imageLoading = false;

    return item;
  }

  Future<AppSizeInfo> _getSize(AppInfo info) async {
    return await channel.getSize(info);
  }

  Future<Uint8List> _getIcon(AppInfo info) async {
    return await channel.getIcon(info);
  }
}
