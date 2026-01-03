// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_repository.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

class RoleRepositoryImpl extends RoleRepository {
  RoleRepositoryImpl(
    this.database,
    RelationshipContext relationshipContext,
  ) : super(relationshipContext);

  final DatapodDatabase database;

  static const _insertSql =
      'INSERT INTO roles (name, user_id) VALUES (@name, @userId) RETURNING id';

  static const _updateSql =
      'UPDATE roles SET name = @name, user_id = @userId WHERE id = @id';

  static const _deleteSql = 'DELETE FROM roles WHERE id = @id';

  static const _findByIdSql = 'SELECT * FROM roles WHERE id = @id';

  @override
  Future<Role> save(entity) async {
    final managed = entity is ManagedEntity
        ? (entity as ManagedRole)
        : ManagedRole.fromEntity(entity, database, relationshipContext);
    final user = await managed.user;
    if (user != null) {
      if (user is ManagedEntity) {
        managed.userId = (user as dynamic).id;
      }
    }
    final params = <String, dynamic>{
      'id': managed.id,
      'name': managed.name,
      'userId': managed.userId,
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
    return managed;
  }

  @override
  Future<List<Role>> saveAll(entities) async {
    final saved = <Role>[];
    for (final entity in entities) {
      saved.add(await save(entity));
    }
    return saved;
  }

  @override
  Future<void> delete(id) async {
    await database.connection.execute(_deleteSql, {'id': id});
  }

  @override
  Future<Role?> findById(id) async {
    final result = await database.connection.execute(_findByIdSql, {'id': id});
    if (result.isEmpty) return null;
    return ManagedRole.fromRow(
        result.rows.first, database, relationshipContext);
  }

  Future<List<Role>> findByUserId(id) async {
    final sql = 'SELECT * FROM roles WHERE user_id = @id';
    final result = await database.connection.execute(sql, {'id': id});
    return result.rows
        .map((row) => ManagedRole.fromRow(row, database, relationshipContext))
        .toList();
  }
}
