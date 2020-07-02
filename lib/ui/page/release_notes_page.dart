import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:salmon_stats_app/ui/all.dart';

class ReleaseNotesPage extends StatefulWidget implements PushablePage<ReleaseNotesPage> {
  const ReleaseNotesPage();

  @override
  _ReleaseNotesPageState createState() => _ReleaseNotesPageState();

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const ReleaseNotesPage()),
    );
  }
}

class _ReleaseNotesPageState extends State<ReleaseNotesPage> {
  final Future<String> _releaseNotesFuture = rootBundle.loadString('assets/release_notes.html');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).releaseNotes)),
      body: FutureBuilderWrapper<String>(
        future: _releaseNotesFuture,
        builder: (_, String releaseNotes) {
          return WebView(
            initialUrl: _toDataUri(_buildReleaseNotesHTML(releaseNotes)),
            // Always open in external browser
            navigationDelegate: (NavigationRequest n) {
              launch(n.url);

              return NavigationDecision.prevent;
            },
          );
        },
      ),
    );
  }

  String _toDataUri(String html) {
    return 'data:text/html;base64,' + base64Encode(utf8.encode(html));
  }

  String _buildReleaseNotesHTML(String generatedReleaseNotes) {
    return '''
<html><head>
<style>
body {
  color: ${context.textTheme.bodyText2.color.toWebColor()};
  background-color: ${context.theme.scaffoldBackgroundColor.toWebColor()};
}

a {
  color: ${linkTextStyle(context).color.toWebColor()};
}
</style>
</head>
<body>$generatedReleaseNotes</body>
</html>
''';
  }
}
