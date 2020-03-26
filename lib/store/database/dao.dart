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

        if (key.endsWith('bool') && value is String) {
          if (entry.value == 'FALSE') {
            return MapEntry<String, dynamic>(key, false);
          } else if (entry.value == 'TRUE') {
            return MapEntry<String, dynamic>(key, true);
          }
        }

        return entry;
      }),
    );

    return JsonMapper.fromMap<T>(row, DEFAULT_SERIALIZE_OPTIONS);
  }

  Map<String, dynamic> toMap(T entity) {
    return JsonMapper.toMap(entity, DEFAULT_SERIALIZE_OPTIONS);
  }
}
