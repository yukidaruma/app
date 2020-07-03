import 'package:dart_json_mapper/dart_json_mapper.dart';

@jsonSerializable
class NicknameAndIconsResponse {
  List<NicknameAndIcon> nicknameAndIcons;
}

@jsonSerializable
class NicknameAndIcon {
  String nickname;
  String nsaId;
  String thumbnailUrl;
}

@jsonSerializable
class IdEntity {
  @JsonProperty(ignore: true)
  int get id => int.parse(idStr);

  @JsonProperty(name: 'id')
  String idStr;
}

class CountEntity {
  const CountEntity(this.count);

  final int count;

  static MapEntry<String, CountEntity> mapper(MapEntry<String, dynamic> entry) {
    return MapEntry<String, CountEntity>(entry.key, CountEntity(entry.value['count'] as int));
  }
}

@jsonSerializable
class JobResult {
  String failureReason; // 'time_limit' | 'wipe_out'
  int failureWave;
  bool isClear;
}

@jsonSerializable
class SalmonResults {
  // summary;
  // rewardGear;

  List<SalmonResult> results = <SalmonResult>[];
}

@jsonSerializable
class SalmonResult {
  @JsonProperty(ignore: true)
  DateTime get playDate => DateTime.fromMillisecondsSinceEpoch((playTime ?? 0) * 1000);

  @JsonProperty(ignore: true)
  Map<String, CountEntity> get bossCounts => _bossCounts == null
      ? null
      : Map<String, CountEntity>.fromEntries(
          _bossCounts?.entries?.map(CountEntity.mapper),
        );

  @JsonProperty(name: 'boss_counts')
  Map<String, dynamic> _bossCounts;
  num dangerRate; // either int or double
  IdEntity grade;
  int gradePoint;
  int jobId;
  int jobRate;
  JobResult jobResult;
  int playTime;
  ResultDetails myResult;
  List<ResultDetails> otherResults;
}

@jsonSerializable
class ResultDetails {
  @JsonProperty(ignore: true)
  Map<String, CountEntity> get bossKillCounts => _bossKillCounts == null
      ? null
      : Map<String, CountEntity>.fromEntries(
          _bossKillCounts.entries.map(CountEntity.mapper),
        );

  @JsonProperty(name: 'boss_kill_counts')
  Map<String, dynamic> _bossKillCounts;
  int deadCount;
  int goldenIkuraNum;
  int ikuraNum;
  String name;
  int helpCount;
  String pid;
  // player_type: { style: 'girl' | 'boy'; species: 'inklings' | 'octolings'; };
  IdEntity special;
  List<int> specialCounts;
  List<IdEntity> weaponList;
}
