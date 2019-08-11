import 'dart:async';

import 'package:executor/executor.dart';

import 'apps-provider.dart';
import 'models/appinfo.dart';

class AppsBloc {
  final _controller = StreamController<AppsBlocModel>();
  final _provider = AppsInfoProvider();
  AppsBlocModel _lastValue;

  Stream<AppsBlocModel> get appsStream => _controller.stream;

  bool get canSort => _lastValue.infos.every((item) => !item.needsLoad);

  void dispose() {
    _controller.close();
  }

  Future<void> loadApps() async {
    final result = await _provider.getApps();
    final model = AppsBlocModel();
    model.infos.addAll(result);
    _lastValue = model;
    _controller.sink.add(model);

    final scheduler = Executor(concurrency: 3);

    scheduler.onChange.listen((dynamic _) {
      if (scheduler.scheduledCount % 3 == 0) _controller.sink.add(model);
    });

    for (var item in model.infos) {
      await scheduler.scheduleTask(() => loadAppsInfo(item));
    }

    await scheduler.join(withWaiting: true);
    _controller.sink.add(model);
  }

  Future<void> loadAppsInfo(AppInfo item) async {
    print('Loading info for ${item.displayName}');

    item.imageLoading = true;
    item.sizeLoading = true;

    try {
      item.image = await _provider.getIcon(item);
    } catch (e) {
      item.imageError = e.toString();
    } finally {
      item.imageLoading = false;
    }

    try {
      item.sizeInfo = await _provider.getSize(item);
    } catch (e) {
      item.sizeLoadError = e.toString();
    } finally {
      item.sizeLoading = false;
    }
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
