import 'package:salmonia_android/model/all.dart';
import 'package:salmonia_android/store/database/all.dart';

class SalmonResultDao extends Dao<InternalSalmonResult> with ClassNameTableNameMixin, JsonMapperDaoMixin<InternalSalmonResult> {
  @override
  String get createTableQuery => '''
  CREATE TABLE $tableName (
    id INTEGER PRIMARY KEY,
    salmon_stats_id INTEGER NOT NULL,
    raw TEXT
  );
  ''';
}

class SalmonResultRepository extends AbstractCRUDRepository<InternalSalmonResult, SalmonResultDao> {
  SalmonResultRepository(DatabaseProvider databaseProvider) : super(databaseProvider);

  @override
  SalmonResultDao get dao => SalmonResultDao();
}
