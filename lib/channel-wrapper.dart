import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'models/appinfo.dart';

class ChannelWrapper {
  static const _platform = const MethodChannel("com.mdcc.app_list_manager/apps");

  Future<void> grantPermission() async {
    await _platform.invokeMethod("grantPermission");
  }

  Future<List<AppInfo>> getApps() async {
    final result = await _platform.invokeMethod("getApps");
    final infos = List<AppInfo>();

    for (var itemX in result) {
      var item = Map<String, dynamic>.from(itemX);
      if (item["packageName"] != null) {
        var info = AppInfo(item["className"], item["dataDir"], item["name"], item["packageName"]);
        info.displayName = item["displayName"];
        infos.add(info);
      }
    }

    return infos;
  }

  Future<Uint8List> getIcon(AppInfo info) async {
    final result = await _platform.invokeMethod('getIcon', {"name": info.packageName});
    var prefix = "data:image/png;base64,";
    var bStr = result.substring(prefix.length).replaceAll("\n", "");
    var bs = Base64Codec().decode(bStr);
    return bs;
  }


  Future<AppSizeInfo> getSize(AppInfo info) async {
    final result = await _platform.invokeMethod('getSize', {"name": info.packageName});
    var appSize = AppSizeInfo();
    appSize.apkSize = result["apkSize"];
    appSize.cache = result["cache"];
    appSize.data = result["data"];
    return appSize;
  }
}