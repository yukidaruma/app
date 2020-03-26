import 'package:salmonia_android/model/all.dart';
import 'package:salmonia_android/store/database/all.dart';

class SalmonResultDao extends Dao<SalmonResult> with JsonMapperDaoMixin<SalmonResult> {
  @override
  String get tableName => 'salmon_results';

  // TODO
  @override
  String get createTableQuery => throw UnimplementedError();
}

class SalmonResultRepository extends AbstractCRUDRepository<SalmonResult, SalmonResultDao> {
  SalmonResultRepository(DatabaseProvider databaseProvider) : super(databaseProvider);

  @override
  SalmonResultDao get dao => SalmonResultDao();
}
