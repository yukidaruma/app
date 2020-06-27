import 'package:salmon_stats_app/ui/all.dart';

class PagePadding extends StatelessWidget {
  const PagePadding({this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: child,
    );
  }
}
