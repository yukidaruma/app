import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:salmonia_android/model/user_profile.dart';
import 'package:salmonia_android/ui/all.dart';

// ignore: avoid_classes_with_only_static_members
class GlobalStore with ChangeNotifier {
  GlobalStore({CookieJar cookieJar, UserProfile profile})
      : _cookieJar = cookieJar,
        _profile = profile;

  CookieJar _cookieJar;
  CookieJar get cookieJar => _cookieJar;
  set cookieJar(CookieJar value) {
    _cookieJar = value;
    notifyListeners();
  }

  UserProfile _profile;
  UserProfile get profile => _profile;
  set profile(UserProfile value) {
    _profile = value;
    notifyListeners();
  }

  // TODO: make it const so tree-shaking can work.
  bool isInDebugMode = !kReleaseMode;
}
