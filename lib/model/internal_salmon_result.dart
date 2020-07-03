import 'package:salmon_stats_app/model/all.dart';

@jsonSerializable
class InternalSalmonResult {
  InternalSalmonResult(this.playTime, this.id, this.pid, this.salmonStatsId, this.raw);

  factory InternalSalmonResult.fromSplatnetResponse(String source, String pid, int salmonStatsId) {
    final SalmonResult result = JsonMapper.deserialize<SalmonResult>(source, DEFAULT_SERIALIZE_OPTIONS);
    return InternalSalmonResult(result.playTime, result.jobId, pid, salmonStatsId, source);
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
