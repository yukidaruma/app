import 'package:salmon_stats_app/store/global.dart';
import 'package:salmon_stats_app/ui/all.dart';

@immutable
class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // Workaround to preload second page. https://github.com/flutter/flutter/issues/31191
  final PageController _pageController = PageController(viewportFraction: 0.99);
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

    final Widget scaffold = Scaffold(
      drawer: const PrimaryDrawer(),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (int newPage) => _destinationPageIndex = newPage,
        controller: _pageController,
        children: _pages,
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _pageController,
        builder: (_, __) => BottomNavigationBar(
          currentIndex: _destinationPageIndex,
          onTap: (int newPage) => _pageController.defaultAnimateToPage(newPage),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(FontAwesomeIcons.list),
              title: Text(S.of(context).navResults),
            ),
            BottomNavigationBarItem(
              icon: const Icon(FontAwesomeIcons.snowflake),
              title: Text(S.of(context).salmonStats),
            ),
          ],
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () {
        if (_destinationPageIndex == 0) {
          return Future<bool>.value(true);
        }

        if (_pages[_destinationPageIndex] is SalmonStatsPage) {
          return context.read<GlobalStore>().getGlobalKey<SalmonStatsPageState>().currentState.requestGoBack().then((bool didGoBack) {
            if (!didGoBack) {
              _pageController.defaultAnimateToPage(0);
            }
          }).then((_) => false);
        }

        _pageController.defaultAnimateToPage(0);
        return Future<bool>.value(false);
      },
      child: scaffold,
    );
  }

  void setPage<T extends StatefulWidget>() {
    _pageController.defaultAnimateToPage(_pages.indexWhere((Widget element) => element.runtimeType == T));
  }
}
