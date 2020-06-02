const int IKSM_SESSION_LENGTH = 40;
const Duration NAVIGATION_ANIMATE_DURATION = Duration(milliseconds: 500);

final RegExp validIksmPattern = RegExp('^[a-fA-F\\d]{$IKSM_SESSION_LENGTH}\$');
