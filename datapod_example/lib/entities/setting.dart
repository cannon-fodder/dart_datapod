import 'package:datapod_api/datapod_api.dart';
import 'setting_audit.dart';

part 'setting.datapod.dart';

@Entity(tableName: 'settings')
class Setting {
  @Id()
  int? id;

  @Column()
  String? key;

  @Column()
  String? value;

  @OneToMany(mappedBy: 'setting', cascade: [CascadeType.all])
  Future<List<SettingAudit>>? auditTrail;
}
