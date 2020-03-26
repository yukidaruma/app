import 'package:salmonia_android/store/database/all.dart';

abstract class AbstractRepository<T extends Dao<dynamic>> {
  const AbstractRepository(this._databaseProvider);

  final DatabaseProvider _databaseProvider;

  T get dao;
  DatabaseProvider get databaseProvider => _databaseProvider;
}

abstract class AbstractCRUDRepository<E, T extends Dao<dynamic>> extends AbstractRepository<T> implements Gettable<E>, Deletable<E>, Savable<E> {
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

abstract class Gettable<E> {
  Future<E> get(dynamic id);
  Future<E> getOrFail(dynamic id);
}

abstract class Savable<E> {
  Future<int> save(E entity);
}
