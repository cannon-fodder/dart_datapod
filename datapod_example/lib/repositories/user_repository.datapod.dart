// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_repository.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

class UserRepositoryOperationsImpl implements DatabaseOperations<User, int> {
  UserRepositoryOperationsImpl(
    this.database,
    this.relationshipContext,
  );

  final DatapodDatabase database;

  final RelationshipContext relationshipContext;

  static const _insertSql =
      '''INSERT INTO users (name, created_at, updated_at) VALUES (@name, @createdAt, @updatedAt) RETURNING id''';

  static const _updateSql =
      '''UPDATE users SET name = @name, created_at = @createdAt, updated_at = @updatedAt WHERE id = @id''';

  static const _deleteSql = '''DELETE FROM users WHERE id = @id''';

  static const _findByIdSql = '''SELECT * FROM users WHERE id = @id''';

  static const _fieldToColumn = {
    'id': 'id',
    'name': 'name',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
    'posts': '',
    'roles': ''
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
  Future<User> saveEntity(User entity) async {
    final ManagedUser managed = entity is ManagedEntity
        ? (entity as ManagedUser)
        : ManagedUser.fromEntity(entity, database, relationshipContext);
    final now = DateTime.now();
    if (!managed.isPersistent && managed.createdAt == null) {
      managed.createdAt = now;
    }
    managed.updatedAt = now;
    final params = <String, dynamic>{
      r'id': managed.id,
      r'name': managed.name,
      r'createdAt': managed.createdAt,
      r'updatedAt': managed.updatedAt,
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
    var posts = await managed.posts;
    if (posts != null && posts.isNotEmpty) {
      for (var child in posts) {
        if (child is! ManagedEntity) {
          child = ManagedPost.fromEntity(child, database, relationshipContext);
        }
        (child as dynamic).authorId = managed.id;
        await relationshipContext
            .getOperations<Post, dynamic>()
            .saveEntity(child);
      }
    }
    var roles = await managed.roles;
    if (roles != null && roles.isNotEmpty) {
      for (var child in roles) {
        if (child is! ManagedEntity) {
          child = ManagedRole.fromEntity(child, database, relationshipContext);
        }
        (child as dynamic).userId = managed.id;
        await relationshipContext
            .getOperations<Role, dynamic>()
            .saveEntity(child);
      }
    }
    return managed;
  }

  @override
  Future<QueryResult> findAll({
    List<Sort>? sort,
    int? limit,
    int? offset,
  }) async {
    final sql = applyPagination('''SELECT * FROM users''',
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
    final sql = applyPagination('''SELECT * FROM users WHERE name = @name''',
        sort: null, limit: null, offset: null, fieldToColumn: _fieldToColumn);
    return database.connection.execute(sql, params);
  }

  Stream<Map<String, dynamic>> findByNameContaining(String name) {
    final params = <String, dynamic>{'name': '%$name%'};
    final sql = applyPagination('''SELECT * FROM users WHERE name LIKE @name''',
        sort: null, limit: null, offset: null, fieldToColumn: _fieldToColumn);
    return database.connection.stream(sql, params);
  }
}

class UserRepositoryImpl extends UserRepository {
  UserRepositoryImpl(
    this.database,
    this.operations,
    this.mapper,
    RelationshipContext relationshipContext,
  ) : super(relationshipContext);

  final DatapodDatabase database;

  final UserRepositoryOperationsImpl operations;

  final UserMapperImpl mapper;

  @override
  Future<User> save(entity) async {
    return await operations.saveEntity(entity);
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
              .getOperations<Post, dynamic>()
              .delete((child as dynamic).id);
        }
      }
      final roles = await entity.roles;
      if (roles != null) {
        for (final child in roles) {
          await relationshipContext
              .getOperations<Role, dynamic>()
              .delete((child as dynamic).id);
        }
      }
    }
    await operations.delete(id);
  }

  @override
  Future<User?> findById(id) async {
    final result = await operations.findById(id);
    if (result.isEmpty) return null;
    return mapper.mapRow(result.rows.first, database, relationshipContext);
  }

  @override
  Future<List<User>> findAll({List<Sort>? sort}) async {
    final result = await operations.findAll(sort: sort);
    return mapper.mapRows(result.rows, database, relationshipContext);
  }

  @override
  Future<Page<User>> findAllPaged(Pageable pageable) async {
    final result = await operations.findAll(
        limit: pageable.size, offset: pageable.offset, sort: pageable.sort);
    final totalElements = await operations.database.connection.execute(
        applyPagination('''SELECT COUNT(*) FROM users''',
            fieldToColumn: UserRepositoryOperationsImpl._fieldToColumn),
        <String, dynamic>{});
    return Page(
      items: mapper.mapRows(result.rows, database, relationshipContext),
      totalElements: totalElements.rows.first.values.first as int,
      pageNumber: pageable.page,
      pageSize: pageable.size,
    );
  }

  @override
  Future<User?> findByName(String name) async {
    final result = await operations.findByName(name);
    if (result.isEmpty) return null;
    return mapper.mapRow(result.rows.first, database, relationshipContext);
  }

  @override
  Stream<User> findByNameContaining(String name) {
    final result = operations.findByNameContaining(name);
    return result
        .map((row) => mapper.mapRow(row, database, relationshipContext));
  }
}
