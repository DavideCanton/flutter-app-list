import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'models/appinfo.dart';

class ChannelWrapper {
  static const _platform = MethodChannel('com.mdcc.app_list_manager/apps');
  static const _GET_APPS_METHOD = 'getApps';
  static const _GET_ICON_METHOD = 'getIcon';
  static const _GET_SIZE_METHOD = 'getSize';

  Future<void> grantPermission() async {
    await _platform.invokeMethod<void>('grantPermission');
  }

  Future<List<AppInfo>> getApps() async {
    final result = await _platform.invokeMethod<List<dynamic>>(_GET_APPS_METHOD);
    final infos = <AppInfo>[];

    for (var itemX in result) {
      final item = Map<String, dynamic>.from(itemX);

      if (item['packageName'] != null) {
        final info = AppInfo();

        info.className = item['className'];
        info.dataDir = item['dataDir'];
        info.name = item['name'];
        info.packageName = item['packageName'];
        info.displayName = item['displayName'];

        infos.add(info);
      }
    }

    return infos;
  }

  Future<Uint8List> getIcon(AppInfo info) async {
    final result = await _platform.invokeMethod<String>(_GET_ICON_METHOD, _getArguments(info));
    const prefix = 'data:image/png;base64,';
    final bStr = result.substring(prefix.length).replaceAll('\n', '');
    return const Base64Codec().decode(bStr);
  }

  Future<AppSizeInfo> getSize(AppInfo info) async {
    print('Getting info for ${info.displayName}...');

    final result = await _platform.invokeMethod<Map<dynamic, dynamic>>(_GET_SIZE_METHOD, _getArguments(info));
    return AppSizeInfo.fromData(result['cache'], result['data'], result['apkSize']);
  }

  Map<String, String> _getArguments(AppInfo info) => {'name': info.packageName};
}
