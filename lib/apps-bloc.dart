import 'dart:async';

import 'apps-provider.dart';
import 'models/appinfo.dart';

class AppsBloc {
  final _controller = StreamController<AppsBlocModel>();
  final _provider = AppsInfoProvider();
  AppsBlocModel _lastValue;

  Stream<AppsBlocModel> get appsStream => _controller.stream;

  void dispose() {
    _controller.close();
  }

  Future<void> loadApps() async {
    final result = await _provider.getApps();
    final model = AppsBlocModel();
    model.infos.addAll(result);
    _lastValue = model;
    _controller.sink.add(model);
  }

  void sortValues(Comparator<AppInfo> comparator) {
    if (_lastValue != null) {
      _lastValue.infos.sort(comparator);
      _controller.sink.add(_lastValue);
    }
  }
}

class AppsBlocModel {
  List<AppInfo> infos = <AppInfo>[];
}
