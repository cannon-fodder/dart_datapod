// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_entity_repository.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

class TestEntityRepositoryImpl extends TestEntityRepository {
  TestEntityRepositoryImpl(
    this.database,
    RelationshipContext relationshipContext,
  ) : super(relationshipContext);

  final DatapodDatabase database;

  static const _insertSql =
      'INSERT INTO test_entities (name, value, rating, flag, created_at, type, data, tags) VALUES (@name, @value, @rating, @flag, @createdAt, @type, @data, @tags) RETURNING id';

  static const _updateSql =
      'UPDATE test_entities SET name = @name, value = @value, rating = @rating, flag = @flag, created_at = @createdAt, type = @type, data = @data, tags = @tags WHERE id = @id';

  static const _deleteSql = 'DELETE FROM test_entities WHERE id = @id';

  static const _findByIdSql = 'SELECT * FROM test_entities WHERE id = @id';

  @override
  Future<TestEntity> save(entity) async {
    final managed = entity is ManagedEntity
        ? (entity as ManagedTestEntity)
        : ManagedTestEntity.fromEntity(entity, database, relationshipContext);
    final params = <String, dynamic>{
      'id': managed.id,
      'name': managed.name,
      'value': managed.value,
      'rating': managed.rating,
      'flag': managed.flag,
      'createdAt': managed.createdAt,
      'type': managed.type?.name,
      'data': jsonEncode(managed.data),
      'tags': jsonEncode(managed.tags),
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
  Future<List<TestEntity>> saveAll(entities) async {
    final saved = <TestEntity>[];
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
  Future<TestEntity?> findById(id) async {
    final result = await database.connection.execute(_findByIdSql, {'id': id});
    if (result.isEmpty) return null;
    return ManagedTestEntity.fromRow(
        result.rows.first, database, relationshipContext);
  }
}
