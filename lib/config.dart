// ignore_for_file: non_constant_identifier_names

// ignore: avoid_classes_with_only_static_members
class Config {
  static String _stringField(String key) => env[key] as String;
  static num _numericField(String key) => env[key] as num;
  static bool _boolField(String key) => env[key] as bool ?? false;

  static Map<String, dynamic> env;

  static String get DEV_IKSM_SESSION => _stringField('DEV_IKSM_SESSION');
  static String get DEV_SALMON_STATS_API_TOKEN => _stringField('DEV_SALMON_STATS_API_TOKEN');
  static bool get DEV_OBSCURE_IKSM_SESSION => _boolField('DEV_OBSCURE_IKSM_SESSION');

  static String get SALMON_STATS_API_ORIGIN => _stringField('SALMON_STATS_API_ORIGIN');
  static String get SALMON_STATS_URL => _stringField('SALMON_STATS_URL');
  static const String SALMON_IMAGE_BASE_PATH = 'https://splatoon-stats-api.yuki.games/static/images';

  static bool get HIDE_DEBUG_LABEL => _boolField('HIDE_DEBUG_LABEL');

  // Splatnet related configurations
  static const String SPLATNET_ORIGIN = 'https://app.splatoon2.nintendo.net';
  static const String SPLATNET_API_ORIGIN = '$SPLATNET_ORIGIN/api';
  static const String SPLATNET_USER_AGENT = 'OnlineLounge/1.6.1.2 NASDKAPI Android';
}
