import 'package:salmonia_android/api.dart';
import 'package:salmonia_android/model/all.dart';
import 'package:salmonia_android/store/global.dart';
import 'package:salmonia_android/ui/all.dart';

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
    final Widget body = SafeArea(
      child: FutureBuilderWrapper<SalmonResult>(
        future: _resultFuture,
        initialData: widget.summary,
        builder: (_, SalmonResult result) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Text(JsonMapper.serialize(result)),
          );
        },
      ),
    );

    return Scaffold(
      body: PagePadding(child: body),
    );
  }
}
