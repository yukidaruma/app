import 'dart:convert';

import 'package:salmon_stats_app/model/all.dart';

@jsonSerializable
class InternalSalmonResult {
  InternalSalmonResult(this.playTime, this.id, this.pid, this.salmonStatsId, this.raw);

  factory InternalSalmonResult.fromSplatnetResponse(String result, String pid, int salmonStatsId) {
    final Map<String, dynamic> map = jsonDecode(result);
    return InternalSalmonResult(map['play_time'], map['job_id'], pid, salmonStatsId, result);
  }

  final int playTime;
  final int id;
  final String pid;
  final int salmonStatsId;
  final String raw;

  @JsonProperty(ignore: true)
  SalmonResult _salmonResultCache;

  SalmonResult toSalmonResult() {
    _salmonResultCache ??= JsonMapper.deserialize<SalmonResult>(raw, DEFAULT_SERIALIZE_OPTIONS);

    return _salmonResultCache;
  }
}
