import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:salmonia_android/api_provider.dart';
import 'package:salmonia_android/config.dart';

final RequestOptions _options = RequestOptions(
  headers: <String, String>{
    'Host': 'app.splatoon2.nintendo.net',
    'x-requested-with': 'XMLHttpRequest',
    'User-Agent': Config.SPLATNET_USER_AGENT,
    'Accept': '*/*',
    'Referer': 'https://app.splatoon2.nintendo.net/home',
    'Accept-Encoding': 'gzip, deflate',
    // TODO
    // 'x-timezone-offset': app_timezone_offset,
    // 'Accept-Language': USER_LANG,
  },
);

class SplatnetAPIRepository {
  SplatnetAPIRepository(CookieJar cookieJar) : _provider = SplatnetAPIProvider(cookieJar);

  final SplatnetAPIProvider _provider;

  Future<Map<String, dynamic>> fetchResults() => _provider.get('/coop_results', _options);
  Future<Map<String, dynamic>> fetchResult(int resultId) => _provider.get('/coop_results/$resultId', _options);
}
