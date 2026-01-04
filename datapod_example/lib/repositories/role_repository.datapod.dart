// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_repository.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

class RoleRepositoryOperationsImpl implements DatabaseOperations<Role, int> {
  RoleRepositoryOperationsImpl(
    this.database,
    this.relationshipContext,
  );

  final DatapodDatabase database;

  final RelationshipContext relationshipContext;

  static const _insertSql =
      '''INSERT INTO roles (name, user_id) VALUES (@name, @userId) RETURNING id''';

  static const _updateSql =
      '''UPDATE roles SET name = @name, user_id = @userId WHERE id = @id''';

  static const _deleteSql = '''DELETE FROM roles WHERE id = @id''';

  static const _findByIdSql = '''SELECT * FROM roles WHERE id = @id''';

  static const _fieldToColumn = {'id': 'id', 'name': 'name', 'user': 'user_id'};

  @override
  Future<QueryResult> save(
    Map<String, dynamic> params, {
    bool isUpdate = false,
  }) async {
    return database.connection
        .execute(isUpdate ? _updateSql : _insertSql, params);
  }

  @override
  Future<Role> saveEntity(Role entity) async {
    final ManagedRole managed = entity is ManagedEntity
        ? (entity as ManagedRole)
        : ManagedRole.fromEntity(entity, database, relationshipContext);
    final user = await managed.user;
    if (user != null) {
      if (user is ManagedEntity) {
        managed.userId = (user as dynamic).id;
      }
    }
    final params = <String, dynamic>{
      r'id': managed.id,
      r'name': managed.name,
      'userId': managed.userId,
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
    final sql = applyPagination('''SELECT * FROM roles''',
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

  Future<QueryResult> findByUserId(dynamic id) {
    final sql = 'SELECT * FROM roles WHERE user_id = @id';
    return database.connection.execute(sql, {'id': id});
  }
}

class RoleRepositoryImpl extends RoleRepository {
  RoleRepositoryImpl(
    this.database,
    this.operations,
    this.mapper,
    RelationshipContext relationshipContext,
  ) : super(relationshipContext);

  final DatapodDatabase database;

  final RoleRepositoryOperationsImpl operations;

  final RoleMapperImpl mapper;

  @override
  Future<Role> save(entity) async {
    return await operations.saveEntity(entity);
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
    await operations.delete(id);
  }

  @override
  Future<Role?> findById(id) async {
    final result = await operations.findById(id);
    if (result.isEmpty) return null;
    return mapper.mapRow(result.rows.first, database, relationshipContext);
  }

  @override
  Future<List<Role>> findAll({List<Sort>? sort}) async {
    final result = await operations.findAll(sort: sort);
    return mapper.mapRows(result.rows, database, relationshipContext);
  }

  @override
  Future<Page<Role>> findAllPaged(Pageable pageable) async {
    final result = await operations.findAll(
        limit: pageable.size, offset: pageable.offset, sort: pageable.sort);
    final totalElements = await operations.database.connection.execute(
        applyPagination('''SELECT COUNT(*) FROM roles''',
            fieldToColumn: RoleRepositoryOperationsImpl._fieldToColumn),
        <String, dynamic>{});
    return Page(
      items: mapper.mapRows(result.rows, database, relationshipContext),
      totalElements: totalElements.rows.first.values.first as int,
      pageNumber: pageable.page,
      pageSize: pageable.size,
    );
  }

  Future<List<Role>> findByUserId(id) async {
    final result = await operations.findByUserId(id);
    return mapper.mapRows(result.rows, database, relationshipContext);
  }
}
