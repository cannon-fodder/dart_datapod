// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// EntityGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.
// ignore_for_file: prefer_interpolation_to_compose_strings, duplicate_ignore

class ManagedUser extends User implements ManagedEntity {
  ManagedUser();

  ManagedUser.fromRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext, {
    String aliasPrefix = '',
  })  : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = row[aliasPrefix + "id"];
    super.name = row[aliasPrefix + "name"];
    super.createdAt = row[aliasPrefix + "created_at"] is String
        ? DateTime.parse(row[aliasPrefix + "created_at"])
        : row[aliasPrefix + "created_at"];
    super.updatedAt = row[aliasPrefix + "updated_at"] is String
        ? DateTime.parse(row[aliasPrefix + "updated_at"])
        : row[aliasPrefix + "updated_at"];
  }

  ManagedUser.fromEntity(
    User entity,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = entity is ManagedEntity
        ? (entity as ManagedEntity).isPersistent
        : false;
    super.id = entity.id;
    super.name = entity.name;
    super.createdAt = entity.createdAt;
    super.updatedAt = entity.updatedAt;
    posts = entity.posts;
    roles = entity.roles;
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
  set createdAt(DateTime? value) {
    if (value != super.createdAt) {
      _isDirty = true;
      super.createdAt = value;
    }
  }

  @override
  set updatedAt(DateTime? value) {
    if (value != super.updatedAt) {
      _isDirty = true;
      super.updatedAt = value;
    }
  }

  @override
  Future<List<Post>>? get posts async {
    if (_loadedPosts == null && id != null && $relationshipContext != null) {
      final ops = $relationshipContext!.getOperations<Post, dynamic>();
      final mapper = $relationshipContext!.getMapper<Post>();
      final result = await (ops as dynamic).findByAuthorId(id!);
      _loadedPosts = Future.value(
          mapper.mapRows(result.rows, $database!, $relationshipContext!));
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
    if (_loadedRoles == null && id != null && $relationshipContext != null) {
      final ops = $relationshipContext!.getOperations<Role, dynamic>();
      final mapper = $relationshipContext!.getMapper<Role>();
      final result = await (ops as dynamic).findByUserId(id!);
      _loadedRoles = Future.value(
          mapper.mapRows(result.rows, $database!, $relationshipContext!));
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

class UserMapperImpl extends EntityMapper<User> {
  @override
  User mapRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext, {
    String aliasPrefix = '',
  }) {
    return ManagedUser.fromRow(row, database, relationshipContext,
        aliasPrefix: aliasPrefix);
  }
}
