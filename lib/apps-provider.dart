import 'dart:typed_data';

import 'channel-wrapper.dart';
import 'models/appinfo.dart';

class AppsInfoProvider {
  final channel = ChannelWrapper();

  Future<List<AppInfo>> getApps() async {
    await channel.grantPermission();
    final infos = await channel.getApps();

    return infos;
  }

  Future<AppSizeInfo> getSize(AppInfo info) async {
    return await channel.getSize(info);
  }

  Future<Uint8List> getIcon(AppInfo info) async {
    return await channel.getIcon(info);
  }
}
