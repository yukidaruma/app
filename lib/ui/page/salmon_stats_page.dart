import 'package:salmonia_android/config.dart';
import 'package:salmonia_android/ui/all.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SalmonStatsPage extends StatefulWidget {
  const SalmonStatsPage({Key key}) : super(key: key);

  @override
  SalmonStatsPageState createState() => SalmonStatsPageState();
}

class SalmonStatsPageState extends State<SalmonStatsPage> with AutomaticKeepAliveClientMixin<SalmonStatsPage> {
  WebViewController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: WebView(
        onWebViewCreated: (WebViewController controller) => _controller = controller,
        initialUrl: Config.SALMON_STATS_URL,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }

  Future<bool> requestGoBack() {
    final Future<bool> didGoBack = _controller.canGoBack();
    _controller.goBack();

    return didGoBack;
  }

  Future<void> showUserPage(String pid) {
    return _controller.loadUrl('${Config.SALMON_STATS_URL}/players/$pid');
  }

  Future<void> showResult(int id) {
    return _controller.loadUrl('${Config.SALMON_STATS_URL}/results/$id');
  }
}
