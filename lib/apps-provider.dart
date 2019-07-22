import 'channel-wrapper.dart';
import 'models/appinfo.dart';

class AppsInfoProvider {
  final channel = ChannelWrapper();

  Future<List<AppInfo>> getApps() async {
    await channel.grantPermission();
    final infos = await channel.getApps();

    return infos;
  }
}
