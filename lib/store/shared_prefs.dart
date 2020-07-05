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

class AppSharedPrefs {
  factory AppSharedPrefs() {
    return _instance;
  }
  AppSharedPrefs._();

  static final AppSharedPrefs _instance = AppSharedPrefs._();
  static SharedPreferences _s;

  static Future<void> load() async {
    _s = await SharedPreferences.getInstance();
  }

  bool getBool(SharedPrefsKeys key) => _s.getBool(key.toString());
  double getDouble(SharedPrefsKeys key) => _s.getDouble(key.toString());
  int getInt(SharedPrefsKeys key) => _s.getInt(key.toString());
  String getString(SharedPrefsKeys key) => _s.getString(key.toString());

  Future<bool> setBool(SharedPrefsKeys key, bool value) => _s.setBool(key.toString(), value);
  Future<bool> setDouble(SharedPrefsKeys key, double value) => _s.setDouble(key.toString(), value);
  Future<bool> setInt(SharedPrefsKeys key, int value) => _s.setInt(key.toString(), value);
  Future<bool> setString(SharedPrefsKeys key, String value) => _s.setString(key.toString(), value);

  Future<bool> Function(bool value) _boolSetter(SharedPrefsKeys key) => (bool value) => setBool(key, value);
  Future<bool> Function(double value) _doubleSetter(SharedPrefsKeys key) => (double value) => setDouble(key, value);
  Future<bool> Function(int value) _intSetter(SharedPrefsKeys key) => (int value) => setInt(key, value);
  Future<bool> Function(String value) _stringSetter(SharedPrefsKeys key) => (String value) => setString(key, value);

  String get salmonStatsToken => getString(SharedPrefsKeys.SALMON_STATS_TOKEN);

  Future<void> devResetAll() {
    return Future.forEach(SharedPrefsKeys.values.map((SharedPrefsKeys key) => key.toString()), _s.remove);
  }
}
