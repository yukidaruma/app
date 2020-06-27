import 'package:salmon_stats_app/store/database/all.dart';

abstract class AbstractRepository<T extends Dao<dynamic>> {
  const AbstractRepository(this._databaseProvider);

  final DatabaseProvider _databaseProvider;

  T get dao;
  DatabaseProvider get databaseProvider => _databaseProvider;
}

abstract class AbstractCRUDRepository<E, T extends Dao<E>> extends AbstractRepository<T> implements Deletable<E>, Findable<E>, Gettable<E>, Savable<E> {
  AbstractCRUDRepository(DatabaseProvider databaseProvider) : super(databaseProvider);

  String get singleWhereClause => '${dao.primaryKey} = ?';

  List<E> _mapRows(List<Map<String, dynamic>> rows) {
    return rows.map(dao.fromMap).toList();
  }

  Future<List<E>> all() async {
    final Database db = await databaseProvider.db();
    final List<Map<String, dynamic>> rows = await db.query(dao.tableName);

    return _mapRows(rows);
  }

  @override
  Future<void> deleteById(dynamic id) async {
    final Database db = await databaseProvider.db();

    return db.delete(
      dao.tableName,
      where: singleWhereClause,
      whereArgs: <dynamic>[id],
    );
  }

  @override
  Future<List<E>> find(Map<String, dynamic> criteria) async {
    final Database db = await databaseProvider.db();
    final List<Map<String, dynamic>> rows = await db.query(
      dao.tableName,
      where: criteria.keys.map((String key) => '$key = ?').join(' AND '),
      whereArgs: criteria.values.toList(),
    );

    return _mapRows(rows);
  }

  @override
  Future<E> findOne(Map<String, dynamic> criteria) async {
    final List<E> rows = await find(criteria);
    return rows.isEmpty ? null : rows.first;
  }

  @override
  Future<E> findOneOrFail(Map<String, dynamic> criteria) async {
    final List<E> rows = await find(criteria);

    if (rows.isEmpty) {
      throw Exception('Entity meets criteria: $criteria was not found.');
    }

    return rows.first;
  }

  @override
  Future<E> get(dynamic id) async {
    final Database db = await databaseProvider.db();

    final List<Map<String, dynamic>> rows = await db.query(
      dao.tableName,
      where: singleWhereClause,
      whereArgs: <dynamic>[id],
    );

    return rows.isNotEmpty ? dao.fromMap(rows.first) : null;
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

abstract class Savable<E> {
  Future<int> create(E entity);
  Future<int> save(E entity);
}
