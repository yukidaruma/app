import 'dart:convert';

import 'package:salmonia_android/model/all.dart';
import 'package:salmonia_android/store/database/all.dart';

class SalmonResultDao extends Dao<InternalSalmonResult> with ClassNameTableNameMixin {
  @override
  String get createTableQuery => '''
  CREATE TABLE $tableName (
    id INTEGER PRIMARY KEY,
    raw TEXT
  );
  ''';

  @override
  InternalSalmonResult fromMap(Map<String, dynamic> row) {
    return InternalSalmonResult(row['id'], row['raw']);
  }

  @override
  Map<String, dynamic> toMap(InternalSalmonResult entity) {
    return <String, dynamic>{
      'id': entity.id,
      'raw': entity.raw,
    };
  }
}

class SalmonResultRepository extends AbstractCRUDRepository<InternalSalmonResult, SalmonResultDao> {
  SalmonResultRepository(DatabaseProvider databaseProvider) : super(databaseProvider);

  @override
  SalmonResultDao get dao => SalmonResultDao();
}

class InternalSalmonResult {
  InternalSalmonResult(this.id, this.raw);

  factory InternalSalmonResult.fromString(String result) {
    final Map<String, dynamic> map = jsonDecode(result);
    return InternalSalmonResult(map['id'], result);
  }

  factory InternalSalmonResult.fromSalmonResult(SalmonResult result) {
    return InternalSalmonResult(
      result.jobId,
      JsonMapper.serialize(result),
    );
  }

  final int id;
  final String raw;

  SalmonResult _salmonResultCache;

  SalmonResult toSalmonResult() {
    _salmonResultCache ??= JsonMapper.deserialize<SalmonResult>(raw, DEFAULT_SERIALIZE_OPTIONS);

    return _salmonResultCache;
  }
}
