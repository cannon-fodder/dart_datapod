// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// EntityGenerator
// **************************************************************************

class ManagedUser extends User implements ManagedEntity {
  ManagedUser();

  ManagedUser.fromRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = row['id'];
    super.name = row['name'];
  }

  ManagedUser.fromEntity(
    User entity,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = entity.id;
    super.name = entity.name;
  }

  final bool _isManaged = true;

  bool _isPersistent = false;

  bool _isDirty = false;

  DatapodDatabase? _database;

  RelationshipContext? _relationshipContext;

  Future<List<Post>>? _loadedPosts;

  Future<List<Role>>? _loadedRoles;

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
  Future<List<Post>>? get posts async {
    if (_loadedPosts == null && $relationshipContext != null) {
      _loadedPosts = ($relationshipContext!.getForEntity<Post>() as dynamic)
          .findByAuthorId(id!) as Future<List<Post>>?;
    }
    return await _loadedPosts ?? <Post>[];
  }

  @override
  set posts(value) {
    if (_loadedPosts != value) {
      _loadedPosts = value;
      markDirty();
    }
  }

  @override
  Future<List<Role>>? get roles async {
    if (_loadedRoles == null && $relationshipContext != null) {
      _loadedRoles = ($relationshipContext!.getForEntity<Role>() as dynamic)
          .findByUserId(id!) as Future<List<Role>>?;
    }
    return await _loadedRoles ?? <Role>[];
  }

  @override
  set roles(value) {
    if (_loadedRoles != value) {
      _loadedRoles = value;
      markDirty();
    }
  }
}
