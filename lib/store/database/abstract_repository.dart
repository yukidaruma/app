import 'package:salmon_stats_app/store/database/all.dart';
import 'package:salmon_stats_app/ui/all.dart';

abstract class AbstractRepository<T extends Dao<dynamic>> {
  const AbstractRepository(this._databaseProvider);

  final DatabaseProvider _databaseProvider;

  T get dao;
  DatabaseProvider get databaseProvider => _databaseProvider;
}

abstract class AbstractCRUDRepository<E, T extends Dao<E>> extends AbstractRepository<T> implements Deletable<E>, Findable<E>, Gettable<E>, Queryable<E>, Savable<E> {
  AbstractCRUDRepository(DatabaseProvider databaseProvider) : super(databaseProvider);

  String get singleWhereClause => '${dao.primaryKey} = ?';

  List<E> _mapRows(List<Map<String, dynamic>> rows) {
    return rows.map(dao.fromMap).toList();
  }

  Future<List<E>> all() async {
    return query();
  }

  @override
  Future<void> delete({@required String where, List<dynamic> whereArgs}) async {
    final Database db = await databaseProvider.db();

    return db.delete(
      dao.tableName,
      where: where,
      whereArgs: whereArgs,
    );
  }

  @override
  Future<void> deleteById(dynamic id) async {
    return delete(
      where: singleWhereClause,
      whereArgs: <dynamic>[id],
    );
  }

  @override
  Future<List<E>> find(Map<String, dynamic> criteria, {int limit}) async {
    return query(
      where: criteria.keys.map((String key) => '$key = ?').join(' AND '),
      whereArgs: criteria.values.toList(),
      limit: limit,
    );
  }

  @override
  Future<E> findOne(Map<String, dynamic> criteria) async {
    final List<E> records = await find(criteria);
    return records.isEmpty ? null : records.first;
  }

  @override
  Future<E> findOneOrFail(Map<String, dynamic> criteria) async {
    final List<E> records = await find(criteria, limit: 1);

    if (records.isEmpty) {
      throw Exception('Entity meets criteria: $criteria was not found.');
    }

    return records.first;
  }

  @override
  Future<E> get(dynamic id) async {
    final List<E> records = await query(
      where: singleWhereClause,
      whereArgs: <dynamic>[id],
    );

    return records.isNotEmpty ? records.first : null;
  }

  @override
  Future<E> getOrFail(dynamic id) async {
    final E entity = await get(id);

    if (entity == null) {
      throw Exception('Entity id $id was not found.');
    }

    return entity;
  }

  @override
  Future<int> create(E entity) async {
    return save(entity, conflictAlgorithm: ConflictAlgorithm.fail);
  }

  @override
  Future<List<E>> query({
    bool distinct,
    List<String> columns,
    String where,
    List<dynamic> whereArgs,
    String groupBy,
    String having,
    String orderBy,
    int limit,
    int offset,
  }) async {
    final Database db = await databaseProvider.db();
    final List<Map<String, dynamic>> rows = await db.query(
      dao.tableName,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    return _mapRows(rows);
  }

  @override
  Future<int> save(E entity, {ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace}) async {
    final Database db = await databaseProvider.db();

    return db.insert(
      dao.tableName,
      dao.toMap(entity),
      conflictAlgorithm: conflictAlgorithm,
    );
  }
}

abstract class Deletable<E> {
  Future<void> delete({@required String where, List<dynamic> whereArgs});
  Future<void> deleteById(dynamic id);
}

abstract class Findable<E> {
  Future<List<E>> find(Map<String, dynamic> criteria);
  Future<E> findOne(Map<String, dynamic> criteria);
  Future<E> findOneOrFail(Map<String, dynamic> criteria);
}

abstract class Gettable<E> {
  Future<E> get(dynamic id);
  Future<E> getOrFail(dynamic id);
}

abstract class Paginatable<E> extends Queryable<E> {
  String get paginationColumn;

  Future<List<E>> paginate(dynamic id, int itemsPerPage);
}

mixin PaginationMixin<E> on Queryable<E> implements Paginatable<E> {
  @override
  Future<List<E>> paginate(dynamic id, int itemsPerPage) {
    return query(
      where: id == null ? null : '$paginationColumn < ?',
      whereArgs: id == null ? null : <dynamic>[id],
      orderBy: '$paginationColumn DESC',
      limit: itemsPerPage,
    );
  }
}

abstract class Queryable<E> {
  Future<List<E>> query({
    bool distinct,
    List<String> columns,
    String where,
    List<dynamic> whereArgs,
    String groupBy,
    String having,
    String orderBy,
    int limit,
    int offset,
  });
}

abstract class Savable<E> {
  Future<int> create(E entity);
  Future<int> save(E entity);
}
