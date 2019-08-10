import 'dart:typed_data';

class AppInfo {
  Uint8List image;

  bool imageLoading = false;
  bool sizeLoading = false;
  String displayName;
  String imageError = '';
  String className;
  String dataDir;
  String name;
  String packageName;
  String sizeLoadError = '';
  AppSizeInfo sizeInfo;

  bool get needsLoad =>
      !isLoading && !hasError && (sizeInfo == null || image == null);

  bool get hasError => sizeLoadError != '' || imageError != '';

  bool get isLoading => sizeLoading || imageLoading;

  static Comparator<AppInfo> byName() {
    return (a, b) {
      final aName = (a.displayName ?? a.name ?? '').toUpperCase();
      final bName = (b.displayName ?? b.name ?? '').toUpperCase();
      return aName.compareTo(bName);
    };
  }

  static Comparator<AppInfo> byTotalSize() {
    return (a, b) =>
        (a.sizeInfo?.totalSize ?? 0).compareTo(b.sizeInfo?.totalSize ?? 0);
  }

  static Comparator<AppInfo> byNameDescending() => _reverse(AppInfo.byName());

  static Comparator<AppInfo> byTotalSizeDesc() =>
      _reverse(AppInfo.byTotalSize());

  static Comparator<AppInfo> _reverse(Comparator<AppInfo> c) =>
      (a, b) => -c(a, b);
}

class AppSizeInfo {
  AppSizeInfo.fromData(this.cache, this.data, this.apkSize);

  int cache;
  int data;
  int apkSize;

  int get totalSize {
    return data + cache + apkSize;
  }
}
