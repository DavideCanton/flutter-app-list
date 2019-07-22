import 'dart:async';

import 'app-info-provider.dart';
import 'models/appinfo.dart';

class AppItemBloc {
  AppItemBloc(this._item);

  AppInfo _item;
  final _controller = StreamController<AppInfo>();
  final _provider = AppInfoProvider();

  Stream<AppInfo> get appsStream => _controller.stream;

  void dispose() {
    _controller.close();
  }

  Future<void> loadAppInfo() async {
    if (_item.image != null && _item.sizeInfo != null) {
      _controller.sink.add(_item);
      return;
    }
    _item.imageLoading = true;
    _item.sizeLoading = true;
    _controller.sink.add(_item);

    final result = await _provider.getAppInfo(_item);
    _controller.sink.add(result);
  }
}
