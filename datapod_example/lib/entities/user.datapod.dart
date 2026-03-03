// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

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
  }) : _database = database,
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
    profileId = row[aliasPrefix + "profile_id"] ?? row["profileId"];
  }

  ManagedUser.fromEntity(
    User entity,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  ) : _database = database,
      _relationshipContext = relationshipContext {
    _isPersistent = entity is ManagedEntity
        ? (entity as ManagedEntity).isPersistent
        : false;
    super.id = entity.id;
    super.name = entity.name;
    super.createdAt = entity.createdAt;
    super.updatedAt = entity.updatedAt;
    profile = entity.profile;
    if (entity is ManagedEntity) {
      profileId = (entity as dynamic).profileId;
    }
    posts = entity.posts;
    roles = entity.roles;
  }

  final bool _isManaged = true;

  bool _isPersistent = false;

  bool _isDirty = false;

  DatapodDatabase? _database;

  RelationshipContext? _relationshipContext;

  Future<UserProfile?>? _loadedProfile;

  dynamic profileId;

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
  Future<UserProfile?>? get profile {
    final context = $relationshipContext;
    final db = $database;
    if (_loadedProfile == null && context != null && db != null) {
      final ops = context.getOperations<UserProfile, dynamic>();
      final mapper = context.getMapper<UserProfile>();
      if (profileId == null) {
        _loadedProfile = Future<UserProfile?>.value(null);
      } else {
        _loadedProfile = ops.findById(profileId).then<UserProfile?>((result) {
          if (result.isNotEmpty) {
            return mapper.mapRow(result.rows.first, db, context);
          }
          return null;
        });
      }
    }
    return _loadedProfile;
  }

  @override
  set profile(Future<UserProfile?>? value) {
    if (value != _loadedProfile) {
      _loadedProfile = value;
      _isDirty = true;
    }
  }

  @override
  Future<List<Post>>? get posts {
    final context = $relationshipContext;
    final db = $database;
    if (_loadedPosts == null && context != null && db != null) {
      final ops = context.getOperations<Post, dynamic>();
      final mapper = context.getMapper<Post>();
      if (id == null) {
        _loadedPosts = Future<List<Post>>.value([]);
      } else {
        _loadedPosts = (ops as dynamic).findByAuthorId(id!).then<List<Post>>((
          result,
        ) {
          return mapper.mapRows(result.rows, db, context);
        });
      }
    }
    return _loadedPosts;
  }

  @override
  set posts(value) {
    if (_loadedPosts != value) {
      _loadedPosts = value;
      markDirty();
    }
  }

  @override
  Future<List<Role>>? get roles {
    final context = $relationshipContext;
    final db = $database;
    if (_loadedRoles == null && context != null && db != null) {
      final ops = context.getOperations<Role, dynamic>();
      final mapper = context.getMapper<Role>();
      if (id == null) {
        _loadedRoles = Future<List<Role>>.value([]);
      } else {
        _loadedRoles = (ops as dynamic).findByUserId(id!).then<List<Role>>((
          result,
        ) {
          return mapper.mapRows(result.rows, db, context);
        });
      }
    }
    return _loadedRoles;
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
    return ManagedUser.fromRow(
      row,
      database,
      relationshipContext,
      aliasPrefix: aliasPrefix,
    );
  }
}
