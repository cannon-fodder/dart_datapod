// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>

import 'package:datapod_api/datapod_api.dart';
import '../entities/setting_audit.dart';

part 'setting_audit_repository.datapod.dart';

@Repository()
@Database('config_db')
abstract class SettingAuditRepository
    extends BaseRepository<SettingAudit, int> {
  SettingAuditRepository(super.relationshipContext);
}
