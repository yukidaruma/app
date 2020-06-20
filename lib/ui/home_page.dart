import 'package:salmonia_android/store/global.dart';
import 'package:salmonia_android/ui/all.dart';

@immutable
class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
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
