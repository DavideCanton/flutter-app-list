import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

class ChoiceItem {
  ChoiceItem(this.text, this.fn);

  String text;
  Comparator<AppInfo> fn;
}

class _MyHomePageState extends State<MyHomePage> {
  final channel = ChannelWrapper();
  final bloc = AppsBloc();
  final _scrollController = ScrollController();

  final _choices = <ChoiceItem>[
    ChoiceItem('Ordina per dimensione decrescente', AppInfo.byTotalSizeDesc()),
    ChoiceItem('Ordina per nome crescente', AppInfo.byName()),
  ];

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  @override
  void initState() {
    super.initState();
    bloc.loadApps();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            PopupMenuButton<ChoiceItem>(
              onSelected: (ChoiceItem v) {
                if(!bloc.canSort)
                  {
                    Fluttertoast.showToast(
                        msg: 'Can\'t sort, wait for info to be retrieved',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM
                    );
                    return;
                  }

                setState(() {
                  bloc.sortValues(v.fn);
                  _scrollController.jumpTo(0);
                });
              },
              itemBuilder: (BuildContext context) {
                return _choices
                    .map((ChoiceItem c) => PopupMenuItem<ChoiceItem>(
                          value: c,
                          child: Text(c.text),
                        ))
                    .toList(growable: false);
              },
            ),
          ],
        ),
        body: buildBody(),
      );

  Widget buildBody() {
    return StreamBuilder<AppsBlocModel>(
        stream: bloc.appsStream,
        builder: (BuildContext context, AsyncSnapshot<AppsBlocModel> snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics (),
                itemBuilder: (BuildContext ctx, int index) =>
                    AppItemWidget(item: snapshot.data.infos[index]),
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
