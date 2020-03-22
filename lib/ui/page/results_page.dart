import 'package:flutter/material.dart';
import 'package:salmonia_android/repository/splatnet_repository.dart';
import 'package:salmonia_android/store/global.dart';
import 'package:salmonia_android/ui/all.dart';

class ResultsPage extends StatefulWidget {
  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> with AutomaticKeepAliveClientMixin<ResultsPage> {
  Future<Map<String, dynamic>> _resultsFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _resultsFuture = SplatnetAPIRepository(GlobalStore.cookieJar).fetchResults();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).navResults)),
      body: FutureBuilderWrapper<Map<String, dynamic>>(
        future: _resultsFuture,
        builder: (_, Map<String, dynamic> res) => Text(res.toString()),
        errorBuilder: (_, __) => ErrorText(S.of(context).resultsFetchingError),
      ),
    );
  }
}
