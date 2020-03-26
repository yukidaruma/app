import 'package:salmonia_android/store/database/all.dart';

abstract class AbstractRepository<T extends Dao<dynamic>> {
  const AbstractRepository(this._databaseProvider);

  final DatabaseProvider _databaseProvider;

  T get dao;
  DatabaseProvider get databaseProvider => _databaseProvider;
}

abstract class AbstractCRUDRepository<T extends Dao<dynamic>> extends AbstractRepository<T> implements Gettable<T>, Deletable<T>, Savable<T> {
  AbstractCRUDRepository(DatabaseProvider databaseProvider) : super(databaseProvider);

  @override
  Future<void> deleteById(int id) async {
    final Database db = await databaseProvider.db();

    return db.delete(
      dao.tableName,
      where: 'id = ?',
      whereArgs: <dynamic>[id],
    );
  }

  @override
  Future<T> get(int id) async {
    final Database db = await databaseProvider.db();

    final List<Map<String, dynamic>> result = await db.query(
      dao.tableName,
      where: 'id = ?',
      whereArgs: <dynamic>[id],
    );

    return result.isNotEmpty ? dao.fromMap(result.first) : null;
  }

  @override
  Future<T> getOrFail(int id) async {
    final T entity = await get(id);

    if (entity == null) {
      throw Exception('Entity id: $id was not found.');
    }

    return entity;
  }

  @override
  Future<int> save(T entity) async {
    final Database db = await databaseProvider.db();

    return db.update(
      dao.tableName,
      dao.toMap(entity),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

abstract class Deletable<T extends Dao<dynamic>> {
  Future<void> deleteById(int id);
}

abstract class Gettable<T extends Dao<dynamic>> {
  Future<T> get(int id);
  Future<T> getOrFail(int id);
}

abstract class Savable<T extends Dao<dynamic>> {
  Future<int> save(T entity);
}
