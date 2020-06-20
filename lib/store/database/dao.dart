import 'package:salmonia_android/model/all.dart';

abstract class Dao<T> {
  String get tableName;
  String get createTableQuery;
  String get primaryKey => 'id';

  T fromMap(Map<String, dynamic> row);
  Map<String, dynamic> toMap(T entity);
}

mixin JsonMapperDaoMixin<T> {
  T fromMap(Map<String, dynamic> row) {
    row = Map<String, dynamic>.fromEntries(
      row.entries.map((MapEntry<String, dynamic> entry) {
        final String key = entry.key;
        final dynamic value = entry.value;

        if (key.endsWith('bool') && value is int) {
          return MapEntry<String, dynamic>(key, value == 1);
        }

        return entry;
      }),
    );

    return JsonMapper.fromMap<T>(row, DEFAULT_SERIALIZE_OPTIONS);
  }

  Map<String, dynamic> toMap(T entity) {
    final Map<String, dynamic> map = JsonMapper.toMap(entity, DEFAULT_SERIALIZE_OPTIONS);
    return Map<String, dynamic>.fromEntries(
      map.entries.map((MapEntry<String, dynamic> entry) {
        final String key = entry.key;
        final dynamic value = entry.value;

        if (key.endsWith('bool')) {
          return MapEntry<String, dynamic>(key, value ? 1 : 0);
        }

        return entry;
      }),
    );
  }
}
