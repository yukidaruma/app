import 'package:salmonia_android/ui/all.dart';

const List<String> contributorTwitterScreenNames = <String>[
  'barley_ural',
  'tkgling',
];

const List<List<String>> repositories = <List<String>>[
  <String>['Website', 'salmon-stats/web'],
  <String>['API server', 'salmon-stats/api'],
  <String>['This app', 'salmon-stats/app'],
];

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
    Widget heading(IconData icon, String heading) => _buildHeading(context, icon, heading);

    final Widget body = ListView(
      padding: const EdgeInsets.only(top: 32.0),
      children: <Widget>[
        const Text(
          'Salmon Stats is an open-source Salmon Run statistics website.',
          textScaleFactor: 1.1,
        ),
        const Divider(height: 32.0),
        heading(FontAwesomeIcons.github, 'Source codes (GitHub)'),
        for (final List<String> repo in repositories)
          _buildLink(
            onTap: () => launch('https://github.com/${repo[1]}'),
            child: Text(
              repo[0],
              style: linkTextStyle(context),
            ),
          ),
        const Padding(padding: EdgeInsets.only(bottom: 32.0)),
        heading(FontAwesomeIcons.lightbulb, 'Contributors'),
        for (final String screenName in contributorTwitterScreenNames)
          _buildLink(
            onTap: () => _launchTwitter(screenName),
            child: Text('@$screenName', style: linkTextStyle(context)),
          ),
        const Padding(padding: EdgeInsets.only(bottom: 32.0)),
        heading(FontAwesomeIcons.fileAlt, 'OSS Licenses'),
        GestureDetector(
          child: Text('View Open Source licenses', style: linkTextStyle(context)),
          onTap: () => showLicensePage(context: context),
        ),
        const Divider(height: 60.0),
        _buildLink(
          onTap: () => _launchTwitter('Yukinkling'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Made with ❄ by '),
              Text('@Yukinkling', style: linkTextStyle(context)),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).aboutThisApp)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: body,
      ),
    );
  }

  Widget _buildHeading(BuildContext context, IconData icon, String heading) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: context.textTheme.headline6.fontSize),
          const Padding(padding: EdgeInsets.only(right: 4.0)),
          Text(
            heading,
            style: context.textTheme.headline6,
          ),
        ],
      ),
    );
  }

  Widget _buildLink({@required GestureTapCallback onTap, @required Widget child}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: child,
      ),
    );
  }
}

Future<void> _launchTwitter(String screenName) => launch('https://twitter.com/$screenName');
