import 'package:salmonia_android/model/all.dart';
import 'package:salmonia_android/store/database/all.dart';

class UserProfileDao extends Dao<UserProfile> with JsonMapperDaoMixin<UserProfile> {
  @override
  String get tableName => 'user_profiles';

  @override
  String get createTableQuery => '''
  CREATE TABLE $tableName (
    pid            TEXT PRIMARY KEY,
    name           TEXT NOT NULL,
    is_active_bool BOOLEAN NOT NULL DEFAULT FALSE,
    iksm_session   TEXT NOT NULL,
    session_token  TEXT NOT NULL
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
