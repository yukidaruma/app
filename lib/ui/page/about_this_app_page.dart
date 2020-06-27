import 'package:salmonia_android/ui/all.dart';

class AboutThisAppPage extends StatelessWidget implements PushablePage<AboutThisAppPage> {
  const AboutThisAppPage();

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const AboutThisAppPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).aboutThisApp)),
      body: Text('wall of text'),
    );
  }
}
