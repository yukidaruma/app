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

class SalmonResultRepository extends AbstractCRUDRepository<InternalSalmonResult, SalmonResultDao> implements Paginatable<InternalSalmonResult> {
  SalmonResultRepository(DatabaseProvider databaseProvider, [this.pid]) : super(databaseProvider);

  final String pid;

  @override
  SalmonResultDao get dao => SalmonResultDao();

  @override
  String get paginationColumn => 'id';

  @override
  Future<List<InternalSalmonResult>> paginate(dynamic id, int itemsPerPage) {
    final String whereClause = <String>[
      if (id != null) '$paginationColumn < ?',
      if (pid != null) 'pid = ?',
    ].join(' AND ');

    final List<dynamic> whereArgs = <dynamic>[
      if (id != null) id,
      if (pid != null) pid,
    ];

    return query(
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs,
      orderBy: '$paginationColumn DESC',
      limit: itemsPerPage,
    );
  }
}
