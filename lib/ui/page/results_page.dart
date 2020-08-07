import 'package:salmon_stats_app/api.dart';
import 'package:salmon_stats_app/model/all.dart';
import 'package:salmon_stats_app/store/database/all.dart';
import 'package:salmon_stats_app/store/database/salmon_result.dart';
import 'package:salmon_stats_app/store/global.dart';
import 'package:salmon_stats_app/ui/all.dart';

class _ResultsStore with ChangeNotifier {
  _ResultsStore(this._context, this.pid);

  final BuildContext _context;
  final String pid;
  final List<SalmonResult> _results = <SalmonResult>[];
  bool hasLoaded = false;
  bool _isLoadingFromDB = false;
  Object error;

  bool get hasError => error != null;

  Future<void> fetchResults() async {
    try {
      final SalmonResults results = await SplatnetAPIRepository(_context.read<GlobalStore>().cookieJar).fetchResults();
      error = null;
      _results.addAll(results.results);
    } catch (e) {
      error = e;
    }

    hasLoaded = true;
    notifyListeners();
  }

  Future<void> loadFromDB([int loadedUntil]) async {
    if (_isLoadingFromDB) {
      return;
    }

    _isLoadingFromDB = true;

    try {
      final List<InternalSalmonResult> results = await SalmonResultRepository(
        DatabaseProvider.instance,
        pid,
      ).paginate(loadedUntil, paginationItemCount);
      _results.addAll(results.map((InternalSalmonResult result) => result.toSalmonResult()));
    } catch (e) {
      error = e;
    } finally {
      _isLoadingFromDB = false;

      notifyListeners();
    }
  }
}

class ResultsPage extends StatefulWidget {
  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> with AutomaticKeepAliveClientMixin<ResultsPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ChangeNotifierProvider<_ResultsStore>(
      create: (BuildContext context) => _ResultsStore(context)..fetchResults(),
      child: _ResultsList(_refreshIndicatorKey),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList(this._refreshIndicatorKey);

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;

  @override
  Widget build(BuildContext context) {
    return FutureBuilderWrapper<bool>(
      future: context.select((GlobalStore store) => store.iksmValidityFuture),
      builder: (BuildContext context, bool isIksmValid) {
        if (!isIksmValid) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ErrorText(S.of(context).iksmExpirationMessage),
                const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                RaisedButton(
                  child: Text(S.of(context).iksmExpirationUpdateButtonLabel),
                  onPressed: () => const EnterIksmPage(type: EnterIksmPageType.sessionTimeOut).push(context),
                ),
              ],
            ),
          );
        }

        return _buildContent(context);
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    Widget makeRefreshable(Widget child) {
      return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          return context.read<_ResultsStore>().fetchResults();
        },
        child: child,
      );
    }

    final _ResultsStore store = context.watch<_ResultsStore>();
    final List<SalmonResult> results = store._results;

    final bool isEmpty = results.isEmpty;
    final int latestUploadedJobId = context.select((GlobalStore store) => store.profile.jobId) ?? 0;
    final int latestJobId = isEmpty ? 0 : results?.first?.jobId ?? 0;
    final int oldestJobId = isEmpty ? 0 : results?.last?.jobId ?? 0;

    Widget body;
    if (store.hasError) {
      body = makeRefreshable(Center(child: ErrorText(S.of(context).resultsFetchingError)));
    } else if (store.hasLoaded) {
      body = isEmpty
          ? makeRefreshable(
              PagePadding(
                child: ScrollColumnExpandable(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(S.of(context).noResultsFound),
                    const Padding(padding: EdgeInsets.only(bottom: 16.0)),
                    RaisedButton(
                      onPressed: () => _refreshIndicatorKey.currentState.show(),
                      child: Text(S.of(context).refresh),
                    ),
                  ],
                ),
              ),
            )
          : makeRefreshable(_buildListView(context, results, latestUploadedJobId));
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
  }

  Widget _buildListView(BuildContext context, List<SalmonResult> results, int latestUploadedJobId) {
    final Widget listView = ListView.builder(
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
                  onPressed: () => _openInSalmonStats(context, result),
                )
              : IconButton(icon: const Icon(Icons.file_upload), disabledColor: Theme.of(context).iconTheme.color, onPressed: null),
        );
      },
      itemCount: results.length,
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 100) {
          context.read<_ResultsStore>().loadFromDB(results.last.jobId);
        }

        return true;
      },
      child: listView,
    );
  }

  Future<void> _openInSalmonStats(BuildContext context, SalmonResult result) async {
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
