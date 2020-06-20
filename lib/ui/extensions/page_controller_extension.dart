import 'package:flutter/widgets.dart';
import 'package:salmonia_android/ui/constants.dart';

extension CustomPageController on PageController {
  Future<void> defaultAnimateToPage(int page) {
    return animateToPage(
      page,
      duration: NAVIGATION_ANIMATE_DURATION,
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }
}
