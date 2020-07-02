import 'package:flutter/material.dart';
import 'package:salmon_stats_app/ui/constants.dart';

extension CustomPageController on PageController {
  Future<void> defaultAnimateToPage(int page) {
    return animateToPage(
      page,
      duration: NAVIGATION_ANIMATE_DURATION,
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }
}

extension BuildContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
}

extension ColorExtension on Color {
  String toWebColor() => '#' + red.toRadixString(16) + green.toRadixString(16) + blue.toRadixString(16) + alpha.toRadixString(16);
}
