// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// EntityGenerator
// **************************************************************************

class ManagedSetting extends Setting implements ManagedEntity {
  ManagedSetting();

  ManagedSetting.fromRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = row['id'];
    super.key = row['key'];
    super.value = row['value'];
  }

  ManagedSetting.fromEntity(
    Setting entity,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = entity.id;
    super.key = entity.key;
    super.value = entity.value;
  }

  final bool _isManaged = true;

  bool _isPersistent = false;

  bool _isDirty = false;

  DatapodDatabase? _database;

  RelationshipContext? _relationshipContext;

  Future<List<SettingAudit>>? _loadedAuditTrail;

  @override
  bool get isManaged => _isManaged;

  @override
  bool get isPersistent => _isPersistent;

  @override
  bool get isDirty => _isDirty;

  @override
  markPersistent() {
    _isPersistent = true;
  }

  @override
  markDirty() {
    _isDirty = true;
  }

  @override
  clearDirty() {
    _isDirty = false;
  }

  @override
  DatapodDatabase? get $database => _database;

  @override
  set $database(DatapodDatabase? value) {
    _database = value;
  }

  @override
  RelationshipContext? get $relationshipContext => _relationshipContext;

  @override
  set $relationshipContext(RelationshipContext? value) {
    _relationshipContext = value;
  }

  @override
  set id(int? value) {
    if (value != super.id) {
      _isDirty = true;
      super.id = value;
    }
  }

  @override
  set key(String? value) {
    if (value != super.key) {
      _isDirty = true;
      super.key = value;
    }
  }

  @override
  set value(String? value) {
    if (value != super.value) {
      _isDirty = true;
      super.value = value;
    }
  }

  @override
  Future<List<SettingAudit>>? get auditTrail async {
    if (_loadedAuditTrail == null && $relationshipContext != null) {
      _loadedAuditTrail =
          ($relationshipContext!.getForEntity<SettingAudit>() as dynamic)
              .findBySettingId(id!) as Future<List<SettingAudit>>?;
    }
    return await _loadedAuditTrail ?? <SettingAudit>[];
  }

  @override
  set auditTrail(value) {
    if (_loadedAuditTrail != value) {
      _loadedAuditTrail = value;
      markDirty();
    }
  }
}
