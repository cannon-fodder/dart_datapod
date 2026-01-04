// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unique_entity_repository.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

class UniqueEntityRepositoryOperationsImpl
    implements DatabaseOperations<UniqueEntity, int> {
  UniqueEntityRepositoryOperationsImpl(
    this.database,
    this.relationshipContext,
  );

  final DatapodDatabase database;

  final RelationshipContext relationshipContext;

  static const _insertSql =
      '''INSERT INTO unique_entities (code, folder, filename) VALUES (@code, @folder, @filename) RETURNING id''';

  static const _updateSql =
      '''UPDATE unique_entities SET code = @code, folder = @folder, filename = @filename WHERE id = @id''';

  static const _deleteSql = '''DELETE FROM unique_entities WHERE id = @id''';

  static const _findByIdSql =
      '''SELECT * FROM unique_entities WHERE id = @id''';

  static const _fieldToColumn = {
    'id': 'id',
    'code': 'code',
    'folder': 'folder',
    'filename': 'filename'
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
  Future<UniqueEntity> saveEntity(UniqueEntity entity) async {
    final ManagedUniqueEntity managed = entity is ManagedEntity
        ? (entity as ManagedUniqueEntity)
        : ManagedUniqueEntity.fromEntity(entity, database, relationshipContext);
    final params = <String, dynamic>{
      r'id': managed.id,
      r'code': managed.code,
      r'folder': managed.folder,
      r'filename': managed.filename,
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
    final sql = applyPagination('''SELECT * FROM unique_entities''',
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
}

class UniqueEntityRepositoryImpl extends UniqueEntityRepository {
  UniqueEntityRepositoryImpl(
    this.database,
    this.operations,
    this.mapper,
    RelationshipContext relationshipContext,
  ) : super(relationshipContext);

  final DatapodDatabase database;

  final UniqueEntityRepositoryOperationsImpl operations;

  final UniqueEntityMapperImpl mapper;

  @override
  Future<UniqueEntity> save(entity) async {
    return await operations.saveEntity(entity);
  }

  @override
  Future<List<UniqueEntity>> saveAll(entities) async {
    final saved = <UniqueEntity>[];
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
  Future<UniqueEntity?> findById(id) async {
    final result = await operations.findById(id);
    if (result.isEmpty) return null;
    return mapper.mapRow(result.rows.first, database, relationshipContext);
  }

  @override
  Future<List<UniqueEntity>> findAll({List<Sort>? sort}) async {
    final result = await operations.findAll(sort: sort);
    return mapper.mapRows(result.rows, database, relationshipContext);
  }

  @override
  Future<Page<UniqueEntity>> findAllPaged(Pageable pageable) async {
    final result = await operations.findAll(
        limit: pageable.size, offset: pageable.offset, sort: pageable.sort);
    final totalElements = await operations.database.connection.execute(
        applyPagination('''SELECT COUNT(*) FROM unique_entities''',
            fieldToColumn: UniqueEntityRepositoryOperationsImpl._fieldToColumn),
        <String, dynamic>{});
    return Page(
      items: mapper.mapRows(result.rows, database, relationshipContext),
      totalElements: totalElements.rows.first.values.first as int,
      pageNumber: pageable.page,
      pageSize: pageable.size,
    );
  }
}
