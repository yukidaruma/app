import 'package:salmon_stats_app/config.dart';
import 'package:salmon_stats_app/model/all.dart';
import 'package:salmon_stats_app/store/database/all.dart';
import 'package:salmon_stats_app/store/global.dart';
import 'package:salmon_stats_app/ui/all.dart';

class PrimaryDrawer extends StatefulWidget {
  const PrimaryDrawer();

  @override
  _PrimaryDrawerState createState() => _PrimaryDrawerState();
}

class _PrimaryDrawerState extends State<PrimaryDrawer> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final GlobalStore store = context.select((GlobalStore store) => store);
    final UserProfile profile = store.profile;
    final List<UserProfile> otherProfiles = store.otherProfiles.take(2).toList();

    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            onDetailsPressed: () => setState(() => _showDetails = !_showDetails),
            otherAccountsPictures: <Widget>[
              for (final UserProfile p in otherProfiles)
                InkWell(
                  onTap: () => _switchAccount(p),
                  child: CircleAvatar(
                    backgroundImage: MemoryImage(p.avatar),
                  ),
                ),
            ],
            accountName: Text(profile.name, style: boldTextStyle(context)),
            accountEmail: Text(profile.pid, style: weakTextStyle(context)),
            currentAccountPicture: CircleAvatar(
              backgroundImage: MemoryImage(profile.avatar),
            ),
          ),
          ...(_showDetails ? _buildDetails : _buildDrawerItems)(context),
        ],
      ),
    );
  }

  List<Widget> _buildDetails(BuildContext context) {
    final GlobalStore store = context.watch<GlobalStore>();

    return <Widget>[
      for (final UserProfile p in store.otherProfiles)
        ListTile(
          contentPadding: const EdgeInsets.only(left: 16.0),
          onTap: () => _switchAccount(p),
          leading: CircleAvatar(
            backgroundImage: MemoryImage(p.avatar),
          ),
          title: Text(p.name),
          trailing: IconButton(
            constraints: BoxConstraints.tight(const Size.square(56.0)),
            icon: const Icon(Icons.close),
            onPressed: () => _removeAccount(p),
            splashRadius: 24.0,
            highlightColor: Colors.transparent,
          ),
        ),
      ListTile(
        onTap: () => _onTapAddAccount(context),
        leading: SizedBox.fromSize(
          child: const Icon(Icons.add),
          size: const Size.square(40.0),
        ),
        title: Text(S.of(context).addAccount),
      ),
    ];
  }

  List<Widget> _buildDrawerItems(BuildContext context) {
    final GlobalStore store = context.watch<GlobalStore>();
    final UserProfile profile = store.profile;

    return <Widget>[
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
      ListTile(
        leading: const Icon(FontAwesomeIcons.fileAlt),
        title: Text(S.of(context).releaseNotes),
        onTap: () => ReleaseNotesPage.push(context),
      ),
      ListTile(
        leading: const Icon(FontAwesomeIcons.infoCircle),
        title: Text(S.of(context).aboutThisApp),
        onTap: () => AboutThisAppPage.push(context),
      ),
      if (context.select((GlobalStore store) => store.isInDebugMode)) ..._buildDebugInfo(),
    ];
  }

  List<Widget> _buildDebugInfo() {
    return <Widget>[
      const Divider(),
      const ListTile(
        title: Text('Debug info'),
      ),
      ListTile(
        title: const Text('Restart app'),
        onTap: () => context.read<GlobalStore>().restartApp(),
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
                    if (entry.value is String)
                      Text(
                        Config.DEV_OBSCURE_IKSM_SESSION && entry.key == 'DEV_IKSM_SESSION' ? ('*' * (entry.value as String).length) : entry.value as String,
                      )
                    else
                      Text('${entry.value} (${entry.value.runtimeType})'),
                  ],
                ),
              )
              .gapWith(const Padding(padding: EdgeInsets.only(bottom: 8.0)))
              .toList(),
        ),
      ),
    ];
  }

  Future<void> _onTapAddAccount(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const EnterIksmPage(type: EnterIksmPageType.addAccount),
      ),
    );
  }

  Future<void> _switchAccount(UserProfile profile) async {
    final GlobalStore store = context.read<GlobalStore>();
    return store.switchProfile(profile);
  }

  Future<void> _removeAccount(UserProfile p) async {
    final bool confirmation = await showConfirmationDialog(
          context: context,
          message: S.of(context).confirmRemoveAccount(p.name),
        ) ??
        false;

    if (confirmation) {
      final GlobalStore store = context.read<GlobalStore>();
      await UserProfileRepository(DatabaseProvider.instance).deleteById(p.pid);
      await store.loadProfiles();
    }
  }
}
