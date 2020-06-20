import 'dart:convert';

import 'package:salmonia_android/model/all.dart';

@jsonSerializable
class InternalSalmonResult {
  InternalSalmonResult(this.id, this.salmonStatsId, this.raw);

  factory InternalSalmonResult.fromSplatnetResponse(String result, int salmonStatsId) {
    final Map<String, dynamic> map = jsonDecode(result);
    return InternalSalmonResult(map['job_id'], salmonStatsId, result);
  }

  final int id;
  final int salmonStatsId;
  final String raw;

  @JsonProperty(ignore: true)
  SalmonResult _salmonResultCache;

  SalmonResult toSalmonResult() {
    _salmonResultCache ??= JsonMapper.deserialize<SalmonResult>(raw, DEFAULT_SERIALIZE_OPTIONS);

    return _salmonResultCache;
  }
}
