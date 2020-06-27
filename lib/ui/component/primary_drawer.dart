import 'package:salmonia_android/config.dart';
import 'package:salmonia_android/model/all.dart';
import 'package:salmonia_android/store/global.dart';
import 'package:salmonia_android/ui/all.dart';

class PrimaryDrawer extends StatelessWidget {
  const PrimaryDrawer();

  @override
  Widget build(BuildContext context) {
    final GlobalStore store = context.select((GlobalStore store) => store);
    final UserProfile profile = store.profile;

    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(profile.name, style: boldTextStyle(context)),
            accountEmail: Text(profile.pid, style: weakTextStyle(context)),
            currentAccountPicture: CircleAvatar(
              backgroundImage: MemoryImage(profile.avatar),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(S.of(context).settings),
            onTap: () => PreferencesPage.push(context),
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.snowflake),
            title: Text(S.of(context).openOtherPage(S.of(context).salmonStatsProfile)),
            onTap: () {
              Navigator.pop(context);
              store.getGlobalKey<HomePageState>().currentState.setPage<SalmonStatsPage>();
              return store.getGlobalKey<SalmonStatsPageState>().currentState.showUserPage(profile.pid);
            },
          ),
          if (context.select((GlobalStore store) => store.isInDebugMode)) ..._buildDebugInfo(),
        ],
      ),
    );
  }

  List<Widget> _buildDebugInfo() {
    return <Widget>[
      const Divider(),
      ListTile(
        title: const Text('Debug info'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Salmon Stats API: ${Config.SALMON_STATS_API_ORIGIN}'),
          ],
        ),
      ),
      ListTile(
        title: const Text('.env'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: Config.env.entries
              .map<Widget>(
                (MapEntry<String, dynamic> entry) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(entry.value),
                  ],
                ),
              )
              .gapWith(const Padding(padding: EdgeInsets.only(bottom: 8.0)))
              .toList(),
        ),
      ),
    ];
  }
}
