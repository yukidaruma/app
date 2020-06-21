import 'package:dio/dio.dart';
import 'package:salmonia_android/api_provider.dart';
import 'package:salmonia_android/config.dart';
import 'package:salmonia_android/store/shared_prefs.dart';

String get salmonStatsAPIToken => (AppSharedPrefs().salmonStatsToken?.isEmpty ?? true) ? Config.DEV_SALMON_STATS_API_TOKEN : AppSharedPrefs().salmonStatsToken;

class SalmonStatsRepository {
  final SalmonStatsAPIProvider _provider = SalmonStatsAPIProvider();
  RequestOptions get _options {
    final String token = salmonStatsAPIToken;

    return defaultRequestOptions.merge(
      headers: <String, String>{
        'authorization': 'Bearer $token',
      },
    );
  }

  Future<String> upload(Map<String, dynamic> payload) => _provider.postJson('/api/results?mode=object', payload, _options);
}
