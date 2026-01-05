// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_repository.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

class TodoRepositoryOperationsImpl implements DatabaseOperations<Todo, int> {
  TodoRepositoryOperationsImpl(
    this.database,
    this.relationshipContext,
  );

  final DatapodDatabase database;

  final RelationshipContext relationshipContext;

  static const _insertSql =
      '''INSERT INTO todo (title, is_done) VALUES (@title, @isDone) RETURNING id''';

  static const _updateSql =
      '''UPDATE todo SET title = @title, is_done = @isDone WHERE id = @id''';

  static const _deleteSql = '''DELETE FROM todo WHERE id = @id''';

  static const _findByIdSql = '''SELECT * FROM todo WHERE id = @id''';

  static const _fieldToColumn = {
    'id': 'id',
    'title': 'title',
    'isDone': 'is_done'
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
  Future<Todo> saveEntity(Todo entity) async {
    final ManagedTodo managed = entity is ManagedEntity
        ? (entity as ManagedTodo)
        : ManagedTodo.fromEntity(entity, database, relationshipContext);
    final params = <String, dynamic>{
      r'id': managed.id,
      r'title': managed.title,
      r'isDone': managed.isDone,
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
    final sql = applyPagination('''SELECT * FROM todo''',
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

class TodoRepositoryImpl extends TodoRepository {
  TodoRepositoryImpl(
    this.database,
    this.operations,
    this.mapper,
    RelationshipContext relationshipContext,
  ) : super(relationshipContext);

  final DatapodDatabase database;

  final TodoRepositoryOperationsImpl operations;

  final TodoMapperImpl mapper;

  @override
  Future<Todo> save(entity) async {
    return await operations.saveEntity(entity);
  }

  @override
  Future<List<Todo>> saveAll(entities) async {
    final saved = <Todo>[];
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
  Future<Todo?> findById(id) async {
    final result = await operations.findById(id);
    if (result.isEmpty) return null;
    return mapper.mapRow(result.rows.first, database, relationshipContext);
  }

  @override
  Future<List<Todo>> findAll({List<Sort>? sort}) async {
    final result = await operations.findAll(sort: sort);
    return mapper.mapRows(result.rows, database, relationshipContext);
  }

  @override
  Future<Page<Todo>> findAllPaged(Pageable pageable) async {
    final result = await operations.findAll(
        limit: pageable.size, offset: pageable.offset, sort: pageable.sort);
    final totalElements = await operations.database.connection.execute(
        applyPagination('''SELECT COUNT(*) FROM todo''',
            fieldToColumn: TodoRepositoryOperationsImpl._fieldToColumn),
        <String, dynamic>{});
    return Page(
      items: mapper.mapRows(result.rows, database, relationshipContext),
      totalElements: totalElements.rows.first.values.first as int,
      pageNumber: pageable.page,
      pageSize: pageable.size,
    );
  }
}
