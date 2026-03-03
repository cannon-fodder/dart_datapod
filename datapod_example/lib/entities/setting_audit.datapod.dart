// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'setting_audit.dart';

// **************************************************************************
// EntityGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.
// ignore_for_file: prefer_interpolation_to_compose_strings, duplicate_ignore

class ManagedSettingAudit extends SettingAudit implements ManagedEntity {
  ManagedSettingAudit();

  ManagedSettingAudit.fromRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext, {
    String aliasPrefix = '',
  }) : _database = database,
       _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = row[aliasPrefix + "id"];
    super.action = row[aliasPrefix + "action"];
    super.timestamp = row[aliasPrefix + "timestamp"] is String
        ? DateTime.parse(row[aliasPrefix + "timestamp"])
        : row[aliasPrefix + "timestamp"];
    settingId = row[aliasPrefix + "setting_id"] ?? row["settingId"];
  }

  ManagedSettingAudit.fromEntity(
    SettingAudit entity,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  ) : _database = database,
      _relationshipContext = relationshipContext {
    _isPersistent = entity is ManagedEntity
        ? (entity as ManagedEntity).isPersistent
        : false;
    super.id = entity.id;
    super.action = entity.action;
    super.timestamp = entity.timestamp;
    setting = entity.setting;
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
  dynamic get $id => id;

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
  Future<Setting?>? get setting {
    final context = $relationshipContext;
    final db = $database;
    if (_loadedSetting == null && context != null && db != null) {
      final ops = context.getOperations<Setting, dynamic>();
      final mapper = context.getMapper<Setting>();
      if (settingId == null) {
        _loadedSetting = Future<Setting?>.value(null);
      } else {
        _loadedSetting = ops.findById(settingId).then<Setting?>((result) {
          if (result.isNotEmpty) {
            return mapper.mapRow(result.rows.first, db, context);
          }
          return null;
        });
      }
    }
    return _loadedSetting;
  }

  @override
  set setting(Future<Setting?>? value) {
    if (value != _loadedSetting) {
      _loadedSetting = value;
      _isDirty = true;
    }
  }
}

class SettingAuditMapperImpl extends EntityMapper<SettingAudit> {
  @override
  SettingAudit mapRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext, {
    String aliasPrefix = '',
  }) {
    return ManagedSettingAudit.fromRow(
      row,
      database,
      relationshipContext,
      aliasPrefix: aliasPrefix,
    );
  }
}
