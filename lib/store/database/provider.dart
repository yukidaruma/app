import 'package:path/path.dart';
import 'package:salmonia_android/store/database/all.dart';

// ignore_for_file: always_specify_types

// TODO
const int DB_SCHEMA_VERSION = 0;

class DatabaseProvider {
  DatabaseProvider._();

  static final DatabaseProvider _instance = DatabaseProvider._();
  static DatabaseProvider get instance => _instance;

  bool isInitialized = false;
  Database _db;

  Future<Database> db() async {
    if (!isInitialized) {
      await _init();
    }

    return _db;
  }

  Future<void> _init() async {
    final migrations = <int, List<Dao<dynamic>>>{
      // TODO
      1: [],
    };

    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, 'salmonia-test.db');

    _db = await openDatabase(
      path,
      version: DB_SCHEMA_VERSION,
      onCreate: (Database db, int oldVersion) async {
        if (oldVersion > DB_SCHEMA_VERSION) {
          return;
        }

        for (final MapEntry<int, List<Dao>> entry in migrations.entries) {
          final int migrationVersion = entry.key;
          final List<Dao> entities = entry.value;

          if (migrationVersion > oldVersion) {
            entities.map((Dao entity) => entity.createTableQuery).forEach(db.execute);
          }
        }
      },
    );
  }
}
