import 'package:path/path.dart';
import 'package:salmon_stats_app/logger.dart';
import 'package:salmon_stats_app/store/database/all.dart';
import 'package:salmon_stats_app/store/database/user_profile.dart';

// ignore_for_file: always_specify_types

// TODO
const int DB_SCHEMA_VERSION = 1;

final migrations = <int, List<Dao<dynamic>>>{
  1: [
    UserProfileDao(),
    SalmonResultDao(),
  ],
};

class DatabaseProvider {
  DatabaseProvider._();

  static final DatabaseProvider _instance = DatabaseProvider._();
  static DatabaseProvider get instance => _instance;

  Database _db;

  Future<Database> db() async {
    _db ??= await _init();

    return _db;
  }

  Future<Database> _init() async {
    Future<void> runMigrations(Database db, bool Function(int migratingVersion) runPredicate) async {
      for (final MapEntry<int, List<Dao>> entry in migrations.entries) {
        final int migratingVersion = entry.key;
        if (!runPredicate(migratingVersion)) {
          continue;
        }

        final List<Dao> entities = entry.value;

        debug('Running migration $migratingVersion');
        debug('Creating table(s): ${entities.map((Dao entity) => entity.tableName).join(',')}');

        await Future.forEach<String>(
          entities.map((Dao entity) => entity.createTableQuery),
          db.execute,
        );
      }
    }

    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, 'salmon-stats.db');

    return openDatabase(
      path,
      version: DB_SCHEMA_VERSION,
      onCreate: (Database db, int version) async {
        runMigrations(
          db,
          (int version) => version <= DB_SCHEMA_VERSION,
        );
      },
      onUpgrade: (Database db, int oldVersion, _) {
        runMigrations(
          db,
          (int version) => oldVersion < version && version <= DB_SCHEMA_VERSION,
        );
      },
    );
  }
}
