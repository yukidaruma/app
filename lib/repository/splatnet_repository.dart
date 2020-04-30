import 'package:cookie_jar/cookie_jar.dart';
import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:dio/dio.dart';
import 'package:salmonia_android/api_provider.dart';
import 'package:salmonia_android/config.dart';
import 'package:salmonia_android/model/all.dart';

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

  Future<SalmonResults> fetchResults() async {
    final String response = await _provider.get('/coop_results', _options);
    return JsonMapper.deserialize<SalmonResults>(response, DEFAULT_SERIALIZE_OPTIONS);
  }

  Future<String> fetchResultAsString(int jobId) async {
    final String response = await _provider.get('/coop_results/$jobId', _options);
    return response;
  }

  Future<SalmonResult> fetchResult(int jobId) async {
    final String response = await fetchResultAsString(jobId);
    return JsonMapper.deserialize<SalmonResult>(response, DEFAULT_SERIALIZE_OPTIONS);
  }
}
