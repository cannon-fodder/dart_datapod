// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_repository.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

class UserRepositoryImpl extends UserRepository {
  UserRepositoryImpl(this.database);

  final DatapodDatabase database;

  static const _insertSql =
      'INSERT INTO users (name) VALUES (@name) RETURNING id';

  static const _updateSql = 'UPDATE users SET name = @name WHERE id = @id';

  static const _deleteSql = 'DELETE FROM users WHERE id = @id';

  static const _findByIdSql = 'SELECT * FROM users WHERE id = @id';

  @override
  Future<User> save(entity) async {
    final params = <String, dynamic>{
      'id': entity.id,
      'name': entity.name,
    };
    if (entity is ManagedEntity) {
      final managed = entity as ManagedEntity;
      if (managed.isPersistent) {
        if (managed.isDirty) {
          await database.connection.execute(_updateSql, params);
          managed.clearDirty();
        }
      } else {
        final result = await database.connection.execute(_insertSql, params);
        managed.markPersistent();
        (entity as dynamic).id = result.lastInsertId;
        managed.clearDirty();
      }
    } else {
      await database.connection.execute(_insertSql, params);
    }
    final posts = await entity.posts;
    if (posts != null && posts!.isNotEmpty) {
      for (final child in posts!) {
        (child as dynamic).authorId = entity.id;
        await database.repositoryFor<Post>().save(child);
      }
    }
    return entity;
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
        for (final child in posts!) {
          await database.repositoryFor<Post>().delete((child as dynamic).id);
        }
      }
    }
    await database.connection.execute(_deleteSql, {'id': id});
  }

  Future<User?> findById(id) async {
    final result = await database.connection.execute(_findByIdSql, {'id': id});
    if (result.isEmpty) return null;
    return ManagedUser.fromRow(result.rows.first, database);
  }

  @override
  Future<User?> findByName(String name) async {
    final params = <String, dynamic>{
      'name': name,
    };
    final result = await database.connection
        .execute('SELECT * FROM users WHERE name = @name', params);
    if (result.isEmpty) return null;
    return ManagedUser.fromRow(result.rows.first, database);
  }

  Future<List<User>> findByPostsId(id) async {
    final sql = 'SELECT * FROM users WHERE  = @id';
    final result = await database.connection.execute(sql, {'id': id});
    return result.rows
        .map((row) => ManagedUser.fromRow(row, database))
        .toList();
  }
}
