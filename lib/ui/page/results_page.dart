import 'package:salmon_stats_app/api.dart';
import 'package:salmon_stats_app/model/all.dart';
import 'package:salmon_stats_app/store/database/all.dart';
import 'package:salmon_stats_app/store/database/salmon_result.dart';
import 'package:salmon_stats_app/store/global.dart';
import 'package:salmon_stats_app/ui/all.dart';

class ResultsPage extends StatefulWidget {
  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> with AutomaticKeepAliveClientMixin<ResultsPage> {
  Future<SalmonResults> _resultsFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _resultsFuture = _fetchResults();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget makeRefreshable(Widget child) {
      return RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _resultsFuture = _fetchResults();
          });

          return _resultsFuture;
        },
        child: child,
      );
    }

    return FutureBuilder<SalmonResults>(
      future: _resultsFuture,
      builder: (BuildContext context, AsyncSnapshot<SalmonResults> snapshot) {
        final List<SalmonResult> results = snapshot.data?.results;
        final int latestUploadedJobId = context.select((GlobalStore store) => store.profile.jobId) ?? 0;
        final int latestJobId = results?.first?.jobId ?? 0;
        final int oldestJobId = results?.last?.jobId ?? 0;

        Widget body;
        if (snapshot.hasError) {
          body = makeRefreshable(
            PagePadding(
              child: ScrollColumnExpandable(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ErrorText(S.of(context).resultsFetchingError),
                ],
              ),
            ),
          );
        } else if (snapshot.hasData) {
          body = makeRefreshable(_buildListView(context, results, latestUploadedJobId));
        } else {
          body = const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).navResults),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.file_upload),
                onPressed: latestUploadedJobId >= latestJobId
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => UploadResultsPage(
                              sinceId: oldestJobId > latestUploadedJobId ? oldestJobId : latestUploadedJobId + 1,
                              untilId: latestJobId,
                            ),
                          ),
                        );
                      },
              ),
            ],
          ),
          body: body,
        );
      },
    );
  }

  Widget _buildListView(BuildContext context, List<SalmonResult> results, int latestUploadedJobId) {
    return ListView.builder(
      padding: listTopPadding,
      itemBuilder: (_, int i) {
        final SalmonResult result = results[i];
        final bool hasUploaded = latestUploadedJobId >= result.jobId;

        return ListTile(
          contentPadding: const EdgeInsets.only(left: 8.0),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ResultPage(result),
            ),
          ),
          leading: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (result.jobResult.isClear)
                  Text(
                    S.of(context).clear,
                    style: successTextStyle,
                  )
                else
                  Text(
                    S.of(context).fail,
                    style: failTextStyle,
                  ),
                Text(result.jobId.toString()),
              ],
            ),
          ),
          title: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  SpecialWeapon(result.myResult.special.id),
                  const Padding(padding: EdgeInsets.only(right: 8.0)),
                  ...result.myResult.weaponList.map((IdEntity i) => MainWeapon(i.id)),
                ],
              ),
              Row(
                children: <Widget>[
                  ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 30.0),
                    child: Text('${result.gradePoint}'),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 20.0),
                    child: Text(result.myResult.goldenIkuraNum.toString(), style: const TextStyle(color: SalmonStatsColors.goldEgg)),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 40.0),
                    child: Text(result.myResult.ikuraNum.toString(), style: const TextStyle(color: SalmonStatsColors.powerEgg)),
                  ),
                ].gapWith(const Padding(padding: EdgeInsets.only(right: 8.0))),
              ),
            ],
          ),
          trailing: hasUploaded
              ? IconButton(
                  icon: const Icon(FontAwesomeIcons.snowflake),
                  onPressed: () => _openInSalmonStats(result),
                )
              : IconButton(icon: const Icon(Icons.file_upload), disabledColor: Theme.of(context).iconTheme.color, onPressed: null),
        );
      },
      itemCount: results.length,
    );
  }

  Future<void> _fetchResults() {
    return SplatnetAPIRepository(context.read<GlobalStore>().cookieJar).fetchResults();
  }

  Future<void> _openInSalmonStats(SalmonResult result) async {
    final GlobalStore store = context.read<GlobalStore>();
    final SalmonResultRepository repository = SalmonResultRepository(DatabaseProvider.instance);
    final int salmonStatsId = (await repository.findOneOrFail(<String, dynamic>{
      'id': result.jobId,
      'pid': store.profile.pid,
    }))
        .salmonStatsId;

    store.getGlobalKey<HomePageState>().currentState.setPage<SalmonStatsPage>();
    store.getGlobalKey<SalmonStatsPageState>().currentState.showResult(salmonStatsId);
  }
}
