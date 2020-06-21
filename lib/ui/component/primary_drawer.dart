import 'package:salmonia_android/model/all.dart';
import 'package:salmonia_android/store/global.dart';
import 'package:salmonia_android/ui/all.dart';

class PrimaryDrawer extends StatelessWidget {
  const PrimaryDrawer();

  @override
  Widget build(BuildContext context) {
    final UserProfile profile = context.select<GlobalStore, UserProfile>((GlobalStore store) => store.profile);

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
            leading: Icon(Icons.settings),
            title: Text(S.of(context).settings),
            onTap: () => PreferencesPage.push(context),
          ),
        ],
      ),
    );
  }
}
