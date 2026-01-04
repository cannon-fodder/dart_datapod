// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>

import 'package:datapod_api/datapod_api.dart';
import '../entities/setting.dart';
import '../entities/setting_audit.dart';

part 'setting_repository.datapod.dart';

@Repository()
@Database('config_db')
abstract class SettingRepository extends BaseRepository<Setting, int> {
  SettingRepository(super.relationshipContext);

  Future<Setting?> findByKey(String key);
}
