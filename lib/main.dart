import 'package:cookie_jar/cookie_jar.dart';
import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:salmonia_android/generated/l10n.dart';
import 'package:salmonia_android/main.reflectable.dart' show initializeReflectable;
import 'package:salmonia_android/model/all.dart';
import 'package:salmonia_android/store/database/all.dart';
import 'package:salmonia_android/store/global.dart';
import 'package:salmonia_android/store/shared_prefs.dart';
import 'package:salmonia_android/ui/all.dart';
import 'package:salmonia_android/util/all.dart';

Future<void> main() async {
  CookieJar cookieJar;

  WidgetsFlutterBinding.ensureInitialized();

  initializeReflectable();
  await AppSharedPrefs.load();
  await DatabaseProvider.instance.db(); // Ensure Database is initialized

  final UserProfile profile = await UserProfileRepository(DatabaseProvider.instance).findOne(
    <String, dynamic>{'is_active_bool': 1},
  );

  final String iksmSession = profile?.iksmSession;
  if (iksmSession != null) {
    cookieJar = createCookieJar(iksmSession);
  }

  JsonMapper().useAdapter(
    JsonMapperAdapter(
      valueDecorators: {
        typeOf<List<IdEntity>>(): (dynamic value) => value.cast<IdEntity>(),
        typeOf<List<NicknameAndIcon>>(): (dynamic value) => value.cast<NicknameAndIcon>(),
        typeOf<List<ResultDetails>>(): (dynamic value) => value.cast<ResultDetails>(),
        typeOf<List<UploadResult>>(): (dynamic value) => value.cast<UploadResult>(),
      },
    ),
  );

  runApp(
    MultiProvider(
      // ignore: always_specify_types
      providers: [
        ChangeNotifierProvider<GlobalStore>(
          create: (BuildContext context) => GlobalStore(
            cookieJar: cookieJar,
            profile: profile,
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        S.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      title: 'Salmonia',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

@immutable
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController();
  int _destinationPageIndex;

  @override
  void initState() {
    super.initState();

    _destinationPageIndex = _pageController.initialPage;
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<GlobalStore>(context).cookieJar == null) {
      return EnterIksmPage();
    }

    return Scaffold(
      drawer: const PrimaryDrawer(),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (int newPage) => _destinationPageIndex = newPage,
        controller: _pageController,
        children: <Widget>[
          ResultsPage(),
          const SalmonStatsPage(),
        ],
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _pageController,
        builder: (_, __) => BottomNavigationBar(
          currentIndex: _destinationPageIndex,
          onTap: (int newPage) => _pageController.defaultAnimateToPage(newPage),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.list),
              title: Text(S.of(context).navResults),
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.snowflake),
              title: Text(S.of(context).salmonStats),
            ),
          ],
        ),
      ),
    );
  }
}
