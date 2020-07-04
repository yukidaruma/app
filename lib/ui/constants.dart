import 'package:salmon_stats_app/ui/all.dart';

const int IKSM_SESSION_LENGTH = 40;
const Duration NAVIGATION_ANIMATE_DURATION = Duration(milliseconds: 500);

final RegExp validIksmPattern = RegExp('^[a-fA-F\\d]{$IKSM_SESSION_LENGTH}\$');

const EdgeInsets listTopPadding = EdgeInsets.only(top: 8.0);

const int paginationItemCount = 50;
