import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:salmon_stats_app/main.dart';
import 'package:salmon_stats_app/model/all.dart';
import 'package:salmon_stats_app/model/user_profile.dart';
import 'package:salmon_stats_app/store/database/all.dart';
import 'package:salmon_stats_app/ui/all.dart';
import 'package:salmon_stats_app/util/all.dart';

// ignore: avoid_classes_with_only_static_members
class GlobalStore with ChangeNotifier {
  GlobalStore({CookieJar cookieJar, List<UserProfile> profiles})
      : _cookieJar = cookieJar,
        _profiles = profiles;

  final Map<Type, GlobalKey> _globalKeys = <Type, GlobalKey>{};

  GlobalKey<T> getGlobalKey<T extends State<StatefulWidget>>() {
    return _globalKeys[typeOf<T>()] as GlobalKey<T>;
  }

  void createGlobalKey<T extends State<StatefulWidget>>() {
    _globalKeys[T] = GlobalKey<T>(debugLabel: T.toString());
  }

  CookieJar _cookieJar;
  CookieJar get cookieJar => _cookieJar;
  set cookieJar(CookieJar value) {
    _cookieJar = value;
    notifyListeners();
  }

  UserProfile get profile => _profiles.firstWhere((UserProfile p) => p.isActiveBool);
  // Updates current profile.
  set profile(UserProfile value) {
    final int index = _profiles.indexWhere((UserProfile p) => p.pid == value.pid);
    _profiles[index] = profile;

    notifyListeners();
  }

  List<UserProfile> get otherProfiles => _profiles.where((UserProfile p) => p != profile).toList();

  List<UserProfile> _profiles;
  List<UserProfile> get profiles => _profiles;
  set profiles(List<UserProfile> value) {
    _profiles = value;
    notifyListeners();
  }

  void addProfile(UserProfile profile) {
    _profiles.add(profile);
  }

  Future<void> loadProfiles({bool shouldNotifyListeners = true}) async {
    final UserProfileRepository repository = UserProfileRepository(DatabaseProvider.instance);
    profiles = await repository.all();

    if (shouldNotifyListeners) {
      notifyListeners();
    }
  }

  void restartApp() {
    getGlobalKey<RestartableState>().currentState.restart();
  }

  Future<void> switchProfile(UserProfile newProfile) async {
    final UserProfile oldProfile = profile;

    if (oldProfile != null) {
      oldProfile.isActiveBool = false;
    }
    newProfile.isActiveBool = true;

    // TODO: Use transaction
    final UserProfileRepository repository = UserProfileRepository(DatabaseProvider.instance);

    for (final UserProfile profile in <UserProfile>[
      if (oldProfile != null) oldProfile,
      newProfile,
    ]) {
      await repository.save(profile);
    }

    await loadProfiles(shouldNotifyListeners: false);
    cookieJar = createCookieJar(profile.iksmSession);

    restartApp();
  }

  // TODO: make it const so tree-shaking can work.
  bool isInDebugMode = !kReleaseMode;
}
