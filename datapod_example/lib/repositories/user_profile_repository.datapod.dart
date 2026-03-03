// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'user_profile_repository.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

class UserProfileRepositoryOperationsImpl
    implements DatabaseOperations<UserProfile, int> {
  UserProfileRepositoryOperationsImpl(this.database, this.relationshipContext);

  final DatapodDatabase database;

  final RelationshipContext relationshipContext;

  static const _insertSql =
      '''INSERT INTO user_profiles (bio, website, user_id) VALUES (@bio, @website, @userId) RETURNING id''';

  static const _updateSql =
      '''UPDATE user_profiles SET bio = @bio, website = @website, user_id = @userId WHERE id = @id''';

  static const _deleteSql = '''DELETE FROM user_profiles WHERE id = @id''';

  static const _findByIdSql = '''SELECT * FROM user_profiles WHERE id = @id''';

  static const _fieldToColumn = {
    'id': 'id',
    'bio': 'bio',
    'website': 'website',
    'user': 'user_id',
  };

  @override
  Future<QueryResult> save(
    Map<String, dynamic> params, {
    bool isUpdate = false,
  }) async {
    return database.connection.execute(
      isUpdate ? _updateSql : _insertSql,
      params,
    );
  }

  @override
  Future<UserProfile> saveEntity(UserProfile entity) async {
    final ManagedUserProfile managed = entity is ManagedEntity
        ? (entity as ManagedUserProfile)
        : ManagedUserProfile.fromEntity(entity, database, relationshipContext);
    final user = await managed.user;
    if (user != null) {
      if (user is ManagedEntity) {
        managed.userId = (user as dynamic).id;
      }
    }
    final params = <String, dynamic>{
      r'id': managed.id,
      r'bio': managed.bio,
      r'website': managed.website,
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
    final sql = applyPagination(
      '''SELECT * FROM user_profiles''',
      sort: sort,
      limit: limit,
      offset: offset,
      fieldToColumn: _fieldToColumn,
    );
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
    final sql = 'SELECT * FROM user_profiles WHERE user_id = @id';
    return database.connection.execute(sql, {'id': id});
  }
}

class UserProfileRepositoryImpl extends UserProfileRepository {
  UserProfileRepositoryImpl(
    this.database,
    this.operations,
    this.mapper,
    RelationshipContext relationshipContext,
  ) : super(relationshipContext) {
    relationshipContext.registerOperations<UserProfile, int>(operations);
    relationshipContext.registerMapper<UserProfile>(mapper);
  }

  final DatapodDatabase database;

  final UserProfileRepositoryOperationsImpl operations;

  final UserProfileMapperImpl mapper;

  @override
  Future<UserProfile> save(entity) async {
    return await operations.saveEntity(entity);
  }

  @override
  Future<List<UserProfile>> saveAll(entities) async {
    final saved = <UserProfile>[];
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
  Future<UserProfile?> findById(id) async {
    final result = await operations.findById(id);
    if (result.isEmpty) return null;
    return mapper.mapRow(result.rows.first, database, relationshipContext);
  }

  @override
  Future<List<UserProfile>> findAll({List<Sort>? sort}) async {
    final result = await operations.findAll(sort: sort);
    return mapper.mapRows(result.rows, database, relationshipContext);
  }

  @override
  Future<Page<UserProfile>> findAllPaged(Pageable pageable) async {
    final result = await operations.findAll(
      limit: pageable.size,
      offset: pageable.offset,
      sort: pageable.sort,
    );
    final totalElements = await operations.database.connection.execute(
      applyPagination(
        '''SELECT COUNT(*) FROM user_profiles''',
        fieldToColumn: UserProfileRepositoryOperationsImpl._fieldToColumn,
      ),
      <String, dynamic>{},
    );
    return Page(
      items: mapper.mapRows(result.rows, database, relationshipContext),
      totalElements: totalElements.rows.first.values.first as int,
      pageNumber: pageable.page,
      pageSize: pageable.size,
    );
  }

  Future<List<UserProfile>> findByUserId(id) async {
    final result = await operations.findByUserId(id);
    return mapper.mapRows(result.rows, database, relationshipContext);
  }
}
