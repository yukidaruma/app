import 'package:salmonia_android/config.dart';
import 'package:salmonia_android/ui/all.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SalmonStatsPage extends StatefulWidget {
  const SalmonStatsPage();

  @override
  _SalmonStatsPageState createState() => _SalmonStatsPageState();
}

class _SalmonStatsPageState extends State<SalmonStatsPage> with AutomaticKeepAliveClientMixin<SalmonStatsPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: WebView(
        initialUrl: Config.SALMON_STATS_URL,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
