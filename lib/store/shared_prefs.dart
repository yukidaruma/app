import 'package:salmon_stats_app/ui/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SharedPrefsKey {
  SALMON_STATS_TOKEN,
}

enum SharedPrefsType {
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
  bool getBool(SharedPrefsKey key, [bool defaultValue]) => _s.getBool(key.toString()) ?? defaultValue ?? false;
  bool getBoolUnsafe(SharedPrefsKey key) => _s.getBool(key.toString());
  double getDouble(SharedPrefsKey key, [double defaultValue]) => _s.getDouble(key.toString()) ?? defaultValue ?? 0.0;
  double getDoubleUnsafe(SharedPrefsKey key) => _s.getDouble(key.toString());
  int getInt(SharedPrefsKey key, [int defaultValue]) => _s.getInt(key.toString()) ?? defaultValue ?? 0;
  int getIntUnsafe(SharedPrefsKey key) => _s.getInt(key.toString());
  String getString(SharedPrefsKey key, [String defaultValue]) => _s.getString(key.toString()) ?? defaultValue ?? '';
  String getStringUnsafe(SharedPrefsKey key) => _s.getString(key.toString());

  Future<bool> setBool(SharedPrefsKey key, bool value) => _s.setBool(key.toString(), value).whenComplete(notifyListeners);
  Future<bool> setDouble(SharedPrefsKey key, double value) => _s.setDouble(key.toString(), value).whenComplete(notifyListeners);
  Future<bool> setInt(SharedPrefsKey key, int value) => _s.setInt(key.toString(), value).whenComplete(notifyListeners);
  Future<bool> setString(SharedPrefsKey key, String value) => _s.setString(key.toString(), value).whenComplete(notifyListeners);

  Future<bool> Function(bool value) _boolSetter(SharedPrefsKey key) => (bool value) => setBool(key, value);
  Future<bool> Function(double value) _doubleSetter(SharedPrefsKey key) => (double value) => setDouble(key, value);
  Future<bool> Function(int value) _intSetter(SharedPrefsKey key) => (int value) => setInt(key, value);
  Future<bool> Function(String value) _stringSetter(SharedPrefsKey key) => (String value) => setString(key, value);

  String get salmonStatsToken => getString(SharedPrefsKey.SALMON_STATS_TOKEN);

  Future<void> devResetAll() {
    return Future.forEach(SharedPrefsKey.values.map((SharedPrefsKey key) => key.toString()), _s.remove);
  }
}
