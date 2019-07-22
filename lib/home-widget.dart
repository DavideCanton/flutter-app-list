import 'package:flutter/material.dart';

import 'app-item-widget.dart';
import 'apps-bloc.dart';
import 'channel-wrapper.dart';
import 'models/appinfo.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final channel = ChannelWrapper();
  final bloc = AppsBloc();

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            PopupMenuButton<int>(
              onSelected: (int v) {
                setState(() {
                  bloc.sortValues(
                      v == 0 ? AppInfo.byTotalSizeDesc() : AppInfo.byName());
                });
              },
              itemBuilder: (BuildContext context) {
                return [0, 1].map((int choice) {
                  return PopupMenuItem<int>(
                    value: choice,
                    child: Text(choice == 0
                        ? 'Ordina per dimensione decrescente'
                        : 'Ordina per nome crescente'),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: buildBody(),
      );

  Widget buildBody() {
    bloc.loadApps();
    return StreamBuilder<AppsBlocModel>(
        stream: bloc.appsStream,
        builder: (BuildContext context, AsyncSnapshot<AppsBlocModel> snapshot) {
          if (snapshot.hasData) {
            print('FIRST APPS ${snapshot.data.infos[0].displayName} ${snapshot.data.infos[1].displayName} ${snapshot.data.infos[2].displayName}');
            return ListView.separated(
                itemBuilder: (BuildContext ctx, int index) =>
                    AppItemWidget(snapshot.data.infos[index]),
                separatorBuilder: (BuildContext ctx, int index) =>
                    const Divider(
                      height: 1.0,
                    ),
                itemCount: snapshot.data.infos.length);
          }

          if (snapshot.hasError)
            return Center(child: Text(snapshot.error.toString()));

          return Center(child: Image.asset('assets/loading.gif'));
        });
  }
}
