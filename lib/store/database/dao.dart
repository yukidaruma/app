import 'package:salmonia_android/model/all.dart';

abstract class Dao<T> {
  String get tableName;
  String get createTableQuery;

  T fromMap(Map<String, dynamic> row);
  Map<String, dynamic> toMap(T entity);
}

mixin JsonMapperDaoMixin<T> {
  T fromMap(Map<String, dynamic> row) {
    return JsonMapper.fromMap<T>(row, DEFAULT_SERIALIZE_OPTIONS);
  }

  Map<String, dynamic> toMap(T entity) {
    return JsonMapper.toMap(entity, DEFAULT_SERIALIZE_OPTIONS);
  }
}
