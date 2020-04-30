import 'package:inflection2/inflection2.dart';

final RegExp endsWithDao = RegExp(r'Dao$');

mixin ClassNameTableNameMixin {
  String get tableName {
    final String className = runtimeType.toString().replaceFirst(endsWithDao, '');
    final String snakeClassName = convertToSnakeCase(className);
    final List<String> words = snakeClassName.split('_');
    words.last = pluralize(words.last);
    return words.join('_');
  }
}
