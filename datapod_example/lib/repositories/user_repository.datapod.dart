// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_repository.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

class UserRepositoryImpl extends UserRepository {
  UserRepositoryImpl(
    this.database,
    RelationshipContext relationshipContext,
  ) : super(relationshipContext);

  final DatapodDatabase database;

  static const _insertSql =
      'INSERT INTO users (name) VALUES (@name) RETURNING id';

  static const _updateSql = 'UPDATE users SET name = @name WHERE id = @id';

  static const _deleteSql = 'DELETE FROM users WHERE id = @id';

  static const _findByIdSql = 'SELECT * FROM users WHERE id = @id';

  @override
  Future<User> save(entity) async {
    final managed = entity is ManagedEntity
        ? (entity as ManagedUser)
        : ManagedUser.fromEntity(entity, database, relationshipContext);
    final params = <String, dynamic>{
      'id': managed.id,
      'name': managed.name,
    };
    if (managed.isPersistent) {
      if (managed.isDirty) {
        await database.connection.execute(_updateSql, params);
        managed.clearDirty();
      }
    } else {
      final result = await database.connection.execute(_insertSql, params);
      managed.markPersistent();
      managed.id = result.lastInsertId;
      managed.clearDirty();
    }
    var posts = await managed.posts;
    if (posts != null && posts.isNotEmpty) {
      for (var child in posts) {
        if (child is! ManagedEntity) {
          child = ManagedPost.fromEntity(child, database, relationshipContext);
        }
        (child as dynamic).authorId = managed.id;
        await relationshipContext.getForEntity<Post>().save(child);
      }
    }
    var roles = await managed.roles;
    if (roles != null && roles.isNotEmpty) {
      for (var child in roles) {
        if (child is! ManagedEntity) {
          child = ManagedRole.fromEntity(child, database, relationshipContext);
        }
        (child as dynamic).userId = managed.id;
        await relationshipContext.getForEntity<Role>().save(child);
      }
    }
    return managed;
  }

  @override
  Future<List<User>> saveAll(entities) async {
    final saved = <User>[];
    for (final entity in entities) {
      saved.add(await save(entity));
    }
    return saved;
  }

  @override
  Future<void> delete(id) async {
    final entity = await findById(id);
    if (entity != null) {
      final posts = await entity.posts;
      if (posts != null) {
        for (final child in posts) {
          await relationshipContext
              .getForEntity<Post>()
              .delete((child as dynamic).id);
        }
      }
      final roles = await entity.roles;
      if (roles != null) {
        for (final child in roles) {
          await relationshipContext
              .getForEntity<Role>()
              .delete((child as dynamic).id);
        }
      }
    }
    await database.connection.execute(_deleteSql, {'id': id});
  }

  @override
  Future<User?> findById(id) async {
    final result = await database.connection.execute(_findByIdSql, {'id': id});
    if (result.isEmpty) return null;
    return ManagedUser.fromRow(
        result.rows.first, database, relationshipContext);
  }

  @override
  Future<User?> findByName(String name) async {
    final params = <String, dynamic>{
      'name': name,
    };
    final result = await database.connection
        .execute('SELECT * FROM users WHERE name = @name', params);
    if (result.isEmpty) return null;
    return ManagedUser.fromRow(
        result.rows.first, database, relationshipContext);
  }
}
