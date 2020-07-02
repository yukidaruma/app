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
h1 { font-size: 150%; }
h2 { font-size: 130%; }
h3 { font-size: 115%; }
h4, h5, h6 { font-size: 100%; }

body {
  padding: 1em;
  color: ${context.textTheme.bodyText2.color.toWebColor()};
  background-color: ${context.theme.scaffoldBackgroundColor.toWebColor()};
  line-height: 1.25em;
}

a {
  color: ${linkTextStyle(context).color.toWebColor()};
}

ul {
  margin: 0;
  padding-left: 1em;
}

li:not(:last-child) {
  margin-bottom: .75em;
}

hr {
  border-color: ${context.textTheme.bodyText2.color.withAlpha(32).toWebColor()};
  margin: 2em 0;
}
</style>
</head>
<body>$generatedReleaseNotes</body>
</html>
''';
  }
}
