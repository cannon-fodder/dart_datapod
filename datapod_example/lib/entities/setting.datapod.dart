// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// EntityGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.
// ignore_for_file: prefer_interpolation_to_compose_strings, duplicate_ignore

class ManagedSetting extends Setting implements ManagedEntity {
  ManagedSetting();

  ManagedSetting.fromRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext, {
    String aliasPrefix = '',
  })  : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = row[aliasPrefix + "id"];
    super.key = row[aliasPrefix + "key"];
    super.value = row[aliasPrefix + "value"];
  }

  ManagedSetting.fromEntity(
    Setting entity,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = entity is ManagedEntity
        ? (entity as ManagedEntity).isPersistent
        : false;
    super.id = entity.id;
    super.key = entity.key;
    super.value = entity.value;
    auditTrail = entity.auditTrail;
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
  dynamic get $id => id;

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
    if (_loadedAuditTrail == null &&
        id != null &&
        $relationshipContext != null) {
      final ops = $relationshipContext!.getOperations<SettingAudit, dynamic>();
      final mapper = $relationshipContext!.getMapper<SettingAudit>();
      final result = await (ops as dynamic).findBySettingId(id!);
      _loadedAuditTrail = Future.value(
          mapper.mapRows(result.rows, $database!, $relationshipContext!));
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

class SettingMapperImpl extends EntityMapper<Setting> {
  @override
  Setting mapRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext, {
    String aliasPrefix = '',
  }) {
    return ManagedSetting.fromRow(row, database, relationshipContext,
        aliasPrefix: aliasPrefix);
  }
}
