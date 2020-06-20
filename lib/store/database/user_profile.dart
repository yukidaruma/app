import 'package:salmonia_android/model/all.dart';
import 'package:salmonia_android/store/database/all.dart';

class UserProfileDao extends Dao<UserProfile> with ClassNameTableNameMixin, JsonMapperDaoMixin<UserProfile> {
  @override
  String get createTableQuery => '''
  CREATE TABLE $tableName (
    pid            TEXT PRIMARY KEY,
    name           TEXT NOT NULL,
    is_active_bool INTEGER NOT NULL DEFAULT FALSE,
    iksm_session   TEXT NOT NULL,
    job_id         INTEGER NOT NULL,
    session_token  TEXT,
    avatar         BLOB
  );
  ''';

  @override
  String get primaryKey => 'pid';
}

class UserProfileRepository extends AbstractCRUDRepository<UserProfile, UserProfileDao> {
  UserProfileRepository(DatabaseProvider databaseProvider) : super(databaseProvider);

  @override
  UserProfileDao get dao => UserProfileDao();
}
