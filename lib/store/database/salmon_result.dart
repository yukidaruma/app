import 'package:salmon_stats_app/model/all.dart';
import 'package:salmon_stats_app/store/database/all.dart';

class SalmonResultDao extends Dao<InternalSalmonResult> with ClassNameTableNameMixin, JsonMapperDaoMixin<InternalSalmonResult> {
  @override
  String get primaryKey => 'play_time';

  @override
  String get createTableQuery => '''
  CREATE TABLE $tableName (
    play_time INTEGER PRIMARY KEY,
    id INTEGER NOT NULL,
    pid TEXT NOT NULL,
    salmon_stats_id INTEGER NOT NULL,
    raw TEXT NOT NULL
  );
  ''';
}

class SalmonResultRepository extends AbstractCRUDRepository<InternalSalmonResult, SalmonResultDao> with PaginationMixin<InternalSalmonResult> {
  SalmonResultRepository(DatabaseProvider databaseProvider) : super(databaseProvider);

  @override
  SalmonResultDao get dao => SalmonResultDao();

  @override
  String get paginationColumn => 'id';
}
