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

  final GlobalStore globalStore = GlobalStore(
    cookieJar: cookieJar,
    profile: profile,
  );

  _createGlobalKeys(globalStore);

  runApp(
    MultiProvider(
      // ignore: always_specify_types
      providers: [
        ChangeNotifierProvider<GlobalStore>(
          create: (_) => globalStore,
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
      theme: _makeThemeData(brightness: Brightness.dark),
//      darkTheme: _makeThemeData(brightness: Brightness.dark),
      home: MyHomePage(key: Provider.of<GlobalStore>(context, listen: false).getGlobalKey<MyHomePageState>()),
    );
  }

  ThemeData _makeThemeData({@required Brightness brightness}) {
    return ThemeData(
      brightness: brightness,
      primarySwatch: Colors.orange,
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.deepOrange,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}

@immutable
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController();
  int _destinationPageIndex;
  List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _destinationPageIndex = _pageController.initialPage;

    _pages = <Widget>[
      ResultsPage(),
      SalmonStatsPage(key: context.read<GlobalStore>().getGlobalKey<SalmonStatsPageState>()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<GlobalStore>(context).cookieJar == null) {
      return EnterIksmPage();
    }

    return Scaffold(
      drawer: const PrimaryDrawer(),
      body: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (int newPage) => _destinationPageIndex = newPage,
        controller: _pageController,
        itemCount: _pages.length,
        itemBuilder: (_, int i) => _pages[i],
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

  void setPage<T extends StatefulWidget>() {
    _pageController.jumpToPage(_pages.indexWhere((Widget element) => element.runtimeType == T));
  }
}

void _createGlobalKeys(GlobalStore globalStore) {
  globalStore.createGlobalKey<MyHomePageState>();
  globalStore.createGlobalKey<SalmonStatsPageState>();
}
