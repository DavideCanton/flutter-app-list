import 'dart:typed_data';

class AppInfo {
  AppInfo(this.className, this.dataDir, this.name, this.packageName);

  Uint8List image;

  bool imageLoading = false;
  bool sizeLoading = false;
  String displayName;
  String imageError = "";
  String className;
  String dataDir;
  String name;
  String packageName;
  AppSizeInfo sizeInfo;

  static Comparator<AppInfo> byName() {
    return (a, b) => (a.displayName ?? a.name).compareTo(b.displayName ?? b.name);
  }

  static Comparator<AppInfo> byTotalSize() {
    return (a, b) => (a.sizeInfo?.totalSize ?? 0).compareTo(b.sizeInfo?.totalSize ?? 0);
  }

  static Comparator<AppInfo> byNameDescending() {
    var fn = AppInfo.byName();
    return (a, b) => -fn(a, b);
  }

  static Comparator<AppInfo> byTotalSizeDesc() {
    var fn = AppInfo.byTotalSize();
    return (a, b) => -fn(a, b);
  }
}

class AppSizeInfo {
  int cache;
  int data;
  int apkSize;

  int get totalSize {
    return data + cache + apkSize;
  }
}
