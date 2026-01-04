// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// EntityGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.
// ignore_for_file: prefer_interpolation_to_compose_strings, duplicate_ignore

class ManagedRole extends Role implements ManagedEntity {
  ManagedRole();

  ManagedRole.fromRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext, {
    String aliasPrefix = '',
  })  : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = row[aliasPrefix + "id"];
    super.name = row[aliasPrefix + "name"];
    userId = row[aliasPrefix + "user_id"] ?? row["userId"];
  }

  ManagedRole.fromEntity(
    Role entity,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = entity is ManagedEntity
        ? (entity as ManagedEntity).isPersistent
        : false;
    super.id = entity.id;
    super.name = entity.name;
    user = entity.user;
    if (entity is ManagedEntity) {
      userId = (entity as dynamic).userId;
    }
  }

  final bool _isManaged = true;

  bool _isPersistent = false;

  bool _isDirty = false;

  DatapodDatabase? _database;

  RelationshipContext? _relationshipContext;

  Future<User?>? _loadedUser;

  dynamic userId;

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
  set name(String? value) {
    if (value != super.name) {
      _isDirty = true;
      super.name = value;
    }
  }

  @override
  Future<User?>? get user async {
    if (_loadedUser == null && userId != null && $relationshipContext != null) {
      final ops = $relationshipContext!.getOperations<User, dynamic>();
      final mapper = $relationshipContext!.getMapper<User>();
      final result = await ops.findById(userId);
      if (result.isNotEmpty) {
        _loadedUser = Future.value(mapper.mapRow(
            result.rows.first, $database!, $relationshipContext!));
      }
    }
    return await _loadedUser;
  }

  @override
  set user(Future<User?>? value) {
    if (value != _loadedUser) {
      _loadedUser = value;
      _isDirty = true;
    }
  }
}

class RoleMapperImpl extends EntityMapper<Role> {
  @override
  Role mapRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext, {
    String aliasPrefix = '',
  }) {
    return ManagedRole.fromRow(row, database, relationshipContext,
        aliasPrefix: aliasPrefix);
  }
}
