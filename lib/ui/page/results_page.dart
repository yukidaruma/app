import 'package:salmonia_android/api.dart';
import 'package:salmonia_android/model/all.dart';
import 'package:salmonia_android/store/database/all.dart';
import 'package:salmonia_android/store/database/salmon_result.dart';
import 'package:salmonia_android/store/global.dart';
import 'package:salmonia_android/ui/all.dart';

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

    _resultsFuture = SplatnetAPIRepository(context.read<GlobalStore>().cookieJar).fetchResults();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<SalmonResults>(
      future: _resultsFuture,
      builder: (BuildContext context, AsyncSnapshot<SalmonResults> snapshot) {
        final List<SalmonResult> results = snapshot.data?.results;
        final int latestUploadedJobId = context.select((GlobalStore store) => store.profile.jobId) ?? 0;
        final int latestJobId = results?.first?.jobId ?? 0;
        final int oldestJobId = results?.last?.jobId ?? 0;

        Widget body;
        if (snapshot.hasError) {
          body = ErrorText(S.of(context).resultsFetchingError);
        } else if (snapshot.hasData) {
          body = _buildListView(context, results, latestUploadedJobId);
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
      itemBuilder: (_, int i) {
        final SalmonResult result = results[i];
        final bool hasUploaded = latestUploadedJobId >= result.jobId;

        return ListTile(
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
          trailing: hasUploaded
              ? IconButton(
                  icon: const Icon(FontAwesomeIcons.snowflake),
                  onPressed: () => _openInSalmonStats(result),
                )
              : const Icon(Icons.file_upload),
        );
      },
      itemCount: results.length,
    );
  }

  Future<void> _openInSalmonStats(SalmonResult result) async {
    // TODO
    final int salmonStatsId = result.salmonStatsId ?? await SalmonResultRepository(DatabaseProvider.instance).getOrFail(result.jobId);
    print(salmonStatsId);
  }
}
