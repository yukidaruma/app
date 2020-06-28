import 'package:dio/dio.dart';
import 'package:salmon_stats_app/api_provider.dart';
import 'package:salmon_stats_app/config.dart';
import 'package:salmon_stats_app/store/shared_prefs.dart';

String get salmonStatsAPIToken => (AppSharedPrefs().salmonStatsToken?.isEmpty ?? true) ? Config.DEV_SALMON_STATS_API_TOKEN : AppSharedPrefs().salmonStatsToken;

class SalmonStatsRepository {
  final SalmonStatsAPIProvider _provider = SalmonStatsAPIProvider();
  RequestOptions get _options {
    final String token = salmonStatsAPIToken;

    return defaultRequestOptions.merge(
      headers: <String, String>{
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<String> upload(Map<String, dynamic> payload) => _provider.postJson('/api/results?mode=object', payload, _options);
}
