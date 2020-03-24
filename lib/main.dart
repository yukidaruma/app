import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:salmonia_android/config.dart';
import 'package:salmonia_android/generated/l10n.dart';
import 'package:salmonia_android/main.reflectable.dart' show initializeReflectable;
import 'package:salmonia_android/model/all.dart';
import 'package:salmonia_android/store/global.dart';
import 'package:salmonia_android/ui/all.dart';

Future<void> main() async {
  initializeReflectable();

  GlobalStore.cookieJar = await _loadCookieJar();

  JsonMapper().useAdapter(
    JsonMapperAdapter(
      valueDecorators: {
        typeOf<List<IdEntity>>(): (dynamic value) => value.cast<IdEntity>(),
      },
    ),
  );

  runApp(MyApp());
}

Future<CookieJar> _loadCookieJar() async {
  // TODO: load from persistent storage

  final CookieJar cookieJar = CookieJar();
  cookieJar.saveFromResponse(Uri.parse(Config.SPLATNET_API_ORIGIN), <Cookie>[
    Cookie('iksm_session', Config.DEV_IKSM_SESSION),
  ]);

  return cookieJar;
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
