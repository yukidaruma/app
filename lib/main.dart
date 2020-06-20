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
      home: HomePage(key: Provider.of<GlobalStore>(context, listen: false).getGlobalKey<HomePageState>()),
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
      textTheme: const TextTheme(
        subtitle1: TextStyle(fontSize: 14.0),
      ),
    );
  }
}

void _createGlobalKeys(GlobalStore globalStore) {
  globalStore.createGlobalKey<HomePageState>();
  globalStore.createGlobalKey<SalmonStatsPageState>();
}
