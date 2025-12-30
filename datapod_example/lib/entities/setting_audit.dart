// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>

import 'package:datapod_api/datapod_api.dart';
import 'setting.dart';

part 'setting_audit.datapod.dart';

@Entity(tableName: 'setting_audits')
abstract class SettingAudit {
  @Id()
  int? id;

  @Column()
  String? action;

  @Column()
  DateTime? timestamp;

  @ManyToOne()
  @JoinColumn('setting_id')
  Future<Setting?>? setting;
}
