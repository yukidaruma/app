import 'package:salmonia_android/model/all.dart';
import 'package:salmonia_android/store/database/all.dart';

class SalmonResultDao extends Dao<SalmonResult> with ClassNameTableNameMixin, JsonMapperDaoMixin<SalmonResult> {
  // TODO
  @override
  String get createTableQuery => throw UnimplementedError();
}

class SalmonResultRepository extends AbstractCRUDRepository<SalmonResult, SalmonResultDao> {
  SalmonResultRepository(DatabaseProvider databaseProvider) : super(databaseProvider);

  @override
  SalmonResultDao get dao => SalmonResultDao();
}
