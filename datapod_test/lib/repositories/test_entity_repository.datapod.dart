// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_entity_repository.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

class TestEntityRepositoryOperationsImpl
    implements DatabaseOperations<TestEntity, int> {
  TestEntityRepositoryOperationsImpl(
    this.database,
    this.relationshipContext,
  );

  final DatapodDatabase database;

  final RelationshipContext relationshipContext;

  static const _insertSql =
      '''INSERT INTO test_entities (duration, name, value, rating, flag, created_at, updated_at, type, data, tags, parent_id) VALUES (@duration, @name, @value, @rating, @flag, @createdAt, @updatedAt, @type, @data, @tags, @parentId) RETURNING id''';

  static const _updateSql =
      '''UPDATE test_entities SET duration = @duration, name = @name, value = @value, rating = @rating, flag = @flag, created_at = @createdAt, updated_at = @updatedAt, type = @type, data = @data, tags = @tags, parent_id = @parentId WHERE id = @id''';

  static const _deleteSql = '''DELETE FROM test_entities WHERE id = @id''';

  static const _findByIdSql = '''SELECT * FROM test_entities WHERE id = @id''';

  static const _fieldToColumn = {
    'id': 'id',
    'duration': 'duration',
    'name': 'name',
    'value': 'value',
    'rating': 'rating',
    'flag': 'flag',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
    'type': 'type',
    'data': 'data',
    'tags': 'tags',
    'parent': 'parent_id'
  };

  @override
  Future<QueryResult> save(
    Map<String, dynamic> params, {
    bool isUpdate = false,
  }) async {
    return database.connection
        .execute(isUpdate ? _updateSql : _insertSql, params);
  }

  @override
  Future<TestEntity> saveEntity(TestEntity entity) async {
    final ManagedTestEntity managed = entity is ManagedEntity
        ? (entity as ManagedTestEntity)
        : ManagedTestEntity.fromEntity(entity, database, relationshipContext);
    final parent = await managed.parent;
    if (parent != null) {
      if (parent is ManagedEntity) {
        managed.parentId = (parent as dynamic).id;
      }
    }
    final now = DateTime.now();
    if (!managed.isPersistent && managed.createdAt == null) {
      managed.createdAt = now;
    }
    managed.updatedAt = now;
    final params = <String, dynamic>{
      r'id': managed.id,
      r'duration': managed.duration != null
          ? const DurationConverter().convertToDatabaseColumn(managed.duration!)
          : null,
      r'name': managed.name,
      r'value': managed.value,
      r'rating': managed.rating,
      r'flag': managed.flag,
      r'createdAt': managed.createdAt,
      r'updatedAt': managed.updatedAt,
      r'type': managed.type?.name,
      r'data': jsonEncode(managed.data),
      r'tags': jsonEncode(managed.tags),
      'parentId': managed.parentId,
    };
    if (managed.isPersistent) {
      if (managed.isDirty) {
        await save(params, isUpdate: true);
        managed.clearDirty();
      }
    } else {
      final result = await save(params, isUpdate: false);
      managed.markPersistent();
      managed.id = result.lastInsertId;
      managed.clearDirty();
    }
    return managed;
  }

  @override
  Future<QueryResult> findAll({
    List<Sort>? sort,
    int? limit,
    int? offset,
  }) async {
    final sql = applyPagination('''SELECT * FROM test_entities''',
        sort: sort,
        limit: limit,
        offset: offset,
        fieldToColumn: _fieldToColumn);
    return database.connection.execute(sql, {});
  }

  @override
  Future<void> delete(int id) async {
    await database.connection.execute(_deleteSql, {'id': id});
  }

  @override
  Future<QueryResult> findById(int id) async {
    return database.connection.execute(_findByIdSql, {'id': id});
  }

  Future<QueryResult> findByName(String name) async {
    final params = <String, dynamic>{'name': name};
    final sql = applyPagination(
        '''SELECT * FROM test_entities WHERE name = @name''',
        sort: null, limit: null, offset: null, fieldToColumn: _fieldToColumn);
    return database.connection.execute(sql, params);
  }

  Future<QueryResult> findByNameContaining(
    String part,
    Pageable pageable,
  ) async {
    final params = <String, dynamic>{'part': '%$part%'};
    final sql = applyPagination(
        '''SELECT * FROM test_entities WHERE name LIKE @part''',
        sort: pageable.sort,
        limit: pageable.size,
        offset: pageable.offset,
        fieldToColumn: _fieldToColumn);
    return database.connection.execute(sql, params);
  }

  Future<QueryResult> findByFlagTrue(List<Sort> sort) async {
    final params = <String, dynamic>{};
    final sql = applyPagination(
        '''SELECT * FROM test_entities WHERE flag = TRUE''',
        sort: sort, limit: null, offset: null, fieldToColumn: _fieldToColumn);
    return database.connection.execute(sql, params);
  }

  Future<QueryResult> findByParentId(dynamic id) {
    final sql = 'SELECT * FROM test_entities WHERE parent_id = @id';
    return database.connection.execute(sql, {'id': id});
  }
}

class TestEntityRepositoryImpl extends TestEntityRepository {
  TestEntityRepositoryImpl(
    this.database,
    this.operations,
    this.mapper,
    RelationshipContext relationshipContext,
  ) : super(relationshipContext);

  final DatapodDatabase database;

  final TestEntityRepositoryOperationsImpl operations;

  final TestEntityMapperImpl mapper;

  @override
  Future<TestEntity> save(entity) async {
    return await operations.saveEntity(entity);
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
    await operations.delete(id);
  }

  @override
  Future<TestEntity?> findById(id) async {
    final sql =
        'SELECT t0.id AS id, t0.duration AS duration, t0.name AS name, t0.value AS value, t0.rating AS rating, t0.flag AS flag, t0.created_at AS created_at, t0.updated_at AS updated_at, t0.type AS type, t0.data AS data, t0.tags AS tags, t0.parent_id AS parent_id, t1.id AS t1_id, t1.duration AS t1_duration, t1.name AS t1_name, t1.value AS t1_value, t1.rating AS t1_rating, t1.flag AS t1_flag, t1.created_at AS t1_created_at, t1.updated_at AS t1_updated_at, t1.type AS t1_type, t1.data AS t1_data, t1.tags AS t1_tags, t1.parent_id AS t1_parent_id FROM test_entities t0 LEFT JOIN test_entities t1 ON t0.parent_id = t1.id WHERE t0.id = @id';
    final result = await database.connection.execute(sql, {'id': id});

    if (result.isEmpty) return null;
    final row = result.rows.first;
    final entity = mapper.mapRow(row, database, relationshipContext);
    final managed = entity as ManagedTestEntity;
    if (row['t1_id'] != null) {
      managed.parent = Future.value(ManagedTestEntity.fromRow(
          row, database, relationshipContext,
          aliasPrefix: 't1_'));
    }
    return entity;
  }

  @override
  Future<List<TestEntity>> findAll({List<Sort>? sort}) async {
    final result = await operations.findAll(sort: sort);
    return mapper.mapRows(result.rows, database, relationshipContext);
  }

  @override
  Future<Page<TestEntity>> findAllPaged(Pageable pageable) async {
    final result = await operations.findAll(
        limit: pageable.size, offset: pageable.offset, sort: pageable.sort);
    final totalElements = await operations.database.connection.execute(
        applyPagination('''SELECT COUNT(*) FROM test_entities''',
            fieldToColumn: TestEntityRepositoryOperationsImpl._fieldToColumn),
        <String, dynamic>{});
    return Page(
      items: mapper.mapRows(result.rows, database, relationshipContext),
      totalElements: totalElements.rows.first.values.first as int,
      pageNumber: pageable.page,
      pageSize: pageable.size,
    );
  }

  @override
  Future<TestEntity?> findByName(String name) async {
    final result = await operations.findByName(name);
    if (result.isEmpty) return null;
    return mapper.mapRow(result.rows.first, database, relationshipContext);
  }

  @override
  Future<Page<TestEntity>> findByNameContaining(
    String part,
    Pageable pageable,
  ) async {
    final result = await operations.findByNameContaining(part, pageable);
    final totalElements = await operations.database.connection.execute(
        applyPagination(
            '''SELECT COUNT(*) FROM test_entities WHERE name LIKE @part''',
            fieldToColumn: TestEntityRepositoryOperationsImpl._fieldToColumn),
        <String, dynamic>{'part': '%$part%'});
    return Page(
      items: mapper.mapRows(result.rows, database, relationshipContext),
      totalElements: totalElements.rows.first.values.first as int,
      pageNumber: pageable.page,
      pageSize: pageable.size,
    );
  }

  @override
  Future<List<TestEntity>> findByFlagTrue(List<Sort> sort) async {
    final result = await operations.findByFlagTrue(sort);
    return mapper.mapRows(result.rows, database, relationshipContext);
  }

  Future<List<TestEntity>> findByParentId(id) async {
    final result = await operations.findByParentId(id);
    return mapper.mapRows(result.rows, database, relationshipContext);
  }
}
