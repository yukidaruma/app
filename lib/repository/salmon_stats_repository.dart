import 'package:dio/dio.dart';
import 'package:salmonia_android/api_provider.dart';
import 'package:salmonia_android/config.dart';

class SalmonStatsRepository {
  final SalmonStatsAPIProvider _provider = SalmonStatsAPIProvider();
  RequestOptions get _options => RequestOptions(
        headers: <String, String>{
          'authorization': 'Bearer ${Config.DEV_SALMON_STATS_API_TOKEN}',
        },
      );

  Future<String> upload(Map<String, dynamic> payload) => _provider.postJson('/api/results', payload, _options);
}
