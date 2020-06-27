import 'package:salmon_stats_app/api.dart';
import 'package:salmon_stats_app/model/all.dart';
import 'package:salmon_stats_app/store/global.dart';
import 'package:salmon_stats_app/ui/all.dart';

class ResultPage extends StatefulWidget {
  const ResultPage(this.summary);

  final SalmonResult summary;

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  Future<SalmonResult> _resultFuture;

  @override
  void initState() {
    super.initState();

    _resultFuture = SplatnetAPIRepository(context.read<GlobalStore>().cookieJar).fetchResult(widget.summary.jobId);
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = FutureBuilderWrapper<SalmonResult>(
      future: _resultFuture,
      initialData: widget.summary,
      builder: (_, SalmonResult result) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Text(JsonMapper.serialize(result)),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(),
      body: PagePadding(child: Text(S.of(context).resultPageUnderConstruction)),
    );
  }
}
