// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_audit.dart';

// **************************************************************************
// EntityGenerator
// **************************************************************************

class ManagedSettingAudit extends SettingAudit implements ManagedEntity {
  ManagedSettingAudit();

  ManagedSettingAudit.fromRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = row['id'];
    super.action = row['action'];
    super.timestamp = row['timestamp'] is String
        ? DateTime.parse(row['timestamp'])
        : row['timestamp'];
    settingId = row['setting_id'];
  }

  ManagedSettingAudit.fromEntity(
    SettingAudit entity,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = entity is ManagedEntity
        ? (entity as ManagedEntity).isPersistent
        : false;
    super.id = entity.id;
    super.action = entity.action;
    super.timestamp = entity.timestamp;
    if (entity is ManagedEntity) {
      settingId = (entity as dynamic).settingId;
    }
  }

  final bool _isManaged = true;

  bool _isPersistent = false;

  bool _isDirty = false;

  DatapodDatabase? _database;

  RelationshipContext? _relationshipContext;

  Future<Setting?>? _loadedSetting;

  dynamic settingId;

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
  set action(String? value) {
    if (value != super.action) {
      _isDirty = true;
      super.action = value;
    }
  }

  @override
  set timestamp(DateTime? value) {
    if (value != super.timestamp) {
      _isDirty = true;
      super.timestamp = value;
    }
  }

  @override
  Future<Setting?>? get setting async {
    if (_loadedSetting == null &&
        settingId != null &&
        $relationshipContext != null) {
      _loadedSetting = $relationshipContext!
          .getForEntity<Setting>()
          .findById(settingId) as Future<Setting?>?;
    }
    return await _loadedSetting;
  }

  @override
  set setting(Future<Setting?>? value) {
    if (value != _loadedSetting) {
      _loadedSetting = value;
      _isDirty = true;
      // TODO: If value is persistent, update settingId
    }
  }
}
