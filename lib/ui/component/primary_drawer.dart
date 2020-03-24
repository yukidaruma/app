import 'package:salmonia_android/ui/all.dart';

class PrimaryDrawer extends StatelessWidget {
  const PrimaryDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text('@Yukinkling', style: boldTextStyle(context)),
            accountEmail: Text('Yuki', style: weakTextStyle(context)),
            currentAccountPicture: CircleAvatar(
              child: Text('❄'),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(S.of(context).settings),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => PreferencesPage()),
            ),
          ),
        ],
      ),
    );
  }
}
