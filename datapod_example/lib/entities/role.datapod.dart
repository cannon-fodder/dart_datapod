// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// EntityGenerator
// **************************************************************************

class ManagedRole extends Role implements ManagedEntity {
  ManagedRole();

  ManagedRole.fromRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = row['id'];
    super.name = row['name'];
    userId = row['user_id'];
  }

  ManagedRole.fromEntity(
    Role entity,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = entity.id;
    super.name = entity.name;
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
      _loadedUser = $relationshipContext!.getForEntity<User>().findById(userId!)
          as Future<User?>?;
    }
    return await _loadedUser;
  }

  @override
  set user(Future<User?>? value) {
    if (value != _loadedUser) {
      _loadedUser = value;
      _isDirty = true;
      // TODO: If value is persistent, update userId
    }
  }
}
