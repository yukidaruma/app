import 'package:salmon_stats_app/ui/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SharedPrefsKeys {
  SALMON_STATS_TOKEN,
}

enum SharedPrefsTypes {
  bool,
  double,
  int,
  string,
}

/// [AppSharedPrefs] supports 2 ways to access.
/// 1. Use `AppSharedPrefs().salmonStatsToken` if you don't need to listen to changes.
/// 2. Use provider API (e.g. `context.select((AppSharedPrefs store) => store.checkForUpdates)`) to
///    listen to updates.
class AppSharedPrefs with ChangeNotifier {
  factory AppSharedPrefs() {
    return _instance;
  }
  AppSharedPrefs._();

  static final AppSharedPrefs _instance = AppSharedPrefs._();
  static SharedPreferences _s;

  static Future<void> load() async {
    _s = await SharedPreferences.getInstance();
  }

  /// Use methods ending with "Unsafe" only when you need to tell whether the value is set (non-null) or unset (null).
  bool getBool(SharedPrefsKeys key) => _s.getBool(key.toString()) ?? false;
  bool getBoolUnsafe(SharedPrefsKeys key) => _s.getBool(key.toString());
  double getDouble(SharedPrefsKeys key) => _s.getDouble(key.toString()) ?? 0.0;
  double getDoubleUnsafe(SharedPrefsKeys key) => _s.getDouble(key.toString());
  int getInt(SharedPrefsKeys key) => _s.getInt(key.toString()) ?? 0;
  int getIntUnsafe(SharedPrefsKeys key) => _s.getInt(key.toString());
  String getString(SharedPrefsKeys key) => _s.getString(key.toString()) ?? '';
  String getStringUnsafe(SharedPrefsKeys key) => _s.getString(key.toString());

  Future<bool> setBool(SharedPrefsKeys key, bool value) => _s.setBool(key.toString(), value).whenComplete(notifyListeners);
  Future<bool> setDouble(SharedPrefsKeys key, double value) => _s.setDouble(key.toString(), value).whenComplete(notifyListeners);
  Future<bool> setInt(SharedPrefsKeys key, int value) => _s.setInt(key.toString(), value).whenComplete(notifyListeners);
  Future<bool> setString(SharedPrefsKeys key, String value) => _s.setString(key.toString(), value).whenComplete(notifyListeners);

  Future<bool> Function(bool value) _boolSetter(SharedPrefsKeys key) => (bool value) => setBool(key, value);
  Future<bool> Function(double value) _doubleSetter(SharedPrefsKeys key) => (double value) => setDouble(key, value);
  Future<bool> Function(int value) _intSetter(SharedPrefsKeys key) => (int value) => setInt(key, value);
  Future<bool> Function(String value) _stringSetter(SharedPrefsKeys key) => (String value) => setString(key, value);

  String get salmonStatsToken => getString(SharedPrefsKeys.SALMON_STATS_TOKEN);

  Future<void> devResetAll() {
    return Future.forEach(SharedPrefsKeys.values.map((SharedPrefsKeys key) => key.toString()), _s.remove);
  }
}
