import 'package:salmonia_android/store/database/all.dart';

abstract class AbstractRepository<T extends Dao<dynamic>> {
  const AbstractRepository(this._databaseProvider);

  final DatabaseProvider _databaseProvider;

  T get dao;
  DatabaseProvider get databaseProvider => _databaseProvider;
}

abstract class AbstractCRUDRepository<E, T extends Dao<E>> extends AbstractRepository<T> implements Deletable<E>, Findable<E>, Gettable<E>, Savable<E> {
  AbstractCRUDRepository(DatabaseProvider databaseProvider) : super(databaseProvider);

  String get singleWhereClause => '${dao.primaryKey} = ?';

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
    final List<Map<String, dynamic>> result = await db.query(
      dao.tableName,
      where: criteria.keys.map((String key) => '$key = ?').join(' AND '),
      whereArgs: criteria.values.toList(),
    );

    return result.map(dao.fromMap).toList();
  }

  @override
  Future<E> findOne(Map<String, dynamic> criteria) async {
    final List<E> rows = await find(criteria);
    return rows.isEmpty ? null : rows.first;
  }

  @override
  Future<E> get(dynamic id) async {
    final Database db = await databaseProvider.db();

    final List<Map<String, dynamic>> result = await db.query(
      dao.tableName,
      where: singleWhereClause,
      whereArgs: <dynamic>[id],
    );

    return result.isNotEmpty ? dao.fromMap(result.first) : null;
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
  Future<int> save(E entity) async {
    final Database db = await databaseProvider.db();

    return db.insert(
      dao.tableName,
      dao.toMap(entity),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

abstract class Deletable<E> {
  Future<void> deleteById(dynamic id);
}

abstract class Findable<E> {
  Future<List<E>> find(Map<String, dynamic> criteria);
  Future<E> findOne(Map<String, dynamic> criteria);
}

abstract class Gettable<E> {
  Future<E> get(dynamic id);
  Future<E> getOrFail(dynamic id);
}

abstract class Savable<E> {
  Future<int> save(E entity);
}
