// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_repository.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

class CommentRepositoryOperationsImpl
    implements DatabaseOperations<Comment, int> {
  CommentRepositoryOperationsImpl(
    this.database,
    this.relationshipContext,
  );

  final DatapodDatabase database;

  final RelationshipContext relationshipContext;

  static const _insertSql =
      '''INSERT INTO comments (content, post_id) VALUES (@content, @postId) RETURNING id''';

  static const _updateSql =
      '''UPDATE comments SET content = @content, post_id = @postId WHERE id = @id''';

  static const _deleteSql = '''DELETE FROM comments WHERE id = @id''';

  static const _findByIdSql = '''SELECT * FROM comments WHERE id = @id''';

  static const _fieldToColumn = {
    'id': 'id',
    'content': 'content',
    'post': 'post_id'
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
  Future<Comment> saveEntity(Comment entity) async {
    final ManagedComment managed = entity is ManagedEntity
        ? (entity as ManagedComment)
        : ManagedComment.fromEntity(entity, database, relationshipContext);
    final post = await managed.post;
    if (post != null) {
      if (post is ManagedEntity) {
        managed.postId = (post as dynamic).id;
      }
    }
    final params = <String, dynamic>{
      r'id': managed.id,
      r'content': managed.content,
      'postId': managed.postId,
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
    final sql = applyPagination('''SELECT * FROM comments''',
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

  Future<QueryResult> findByPostId(dynamic id) {
    final sql = 'SELECT * FROM comments WHERE post_id = @id';
    return database.connection.execute(sql, {'id': id});
  }
}

class CommentRepositoryImpl extends CommentRepository {
  CommentRepositoryImpl(
    this.database,
    this.operations,
    this.mapper,
    RelationshipContext relationshipContext,
  ) : super(relationshipContext);

  final DatapodDatabase database;

  final CommentRepositoryOperationsImpl operations;

  final CommentMapperImpl mapper;

  @override
  Future<Comment> save(entity) async {
    return await operations.saveEntity(entity);
  }

  @override
  Future<List<Comment>> saveAll(entities) async {
    final saved = <Comment>[];
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
  Future<Comment?> findById(id) async {
    final sql =
        'SELECT t0.id AS id, t0.content AS content, t0.post_id AS post_id, t1.id AS t1_id, t1.title AS t1_title, t1.reading_time AS t1_reading_time, t1.created_at AS t1_created_at, t1.updated_at AS t1_updated_at, t1.content AS t1_content, t1.status AS t1_status, t1.metadata AS t1_metadata, t1.tags AS t1_tags, t1.author_id AS t1_author_id FROM comments t0 LEFT JOIN posts t1 ON t0.post_id = t1.id WHERE t0.id = @id';
    final result = await database.connection.execute(sql, {'id': id});

    if (result.isEmpty) return null;
    final row = result.rows.first;
    final entity = mapper.mapRow(row, database, relationshipContext);
    final managed = entity as ManagedComment;
    if (row['t1_id'] != null) {
      managed.post = Future.value(ManagedPost.fromRow(
          row, database, relationshipContext,
          aliasPrefix: 't1_'));
    }
    return entity;
  }

  @override
  Future<List<Comment>> findAll({List<Sort>? sort}) async {
    final result = await operations.findAll(sort: sort);
    return mapper.mapRows(result.rows, database, relationshipContext);
  }

  @override
  Future<Page<Comment>> findAllPaged(Pageable pageable) async {
    final result = await operations.findAll(
        limit: pageable.size, offset: pageable.offset, sort: pageable.sort);
    final totalElements = await operations.database.connection.execute(
        applyPagination('''SELECT COUNT(*) FROM comments''',
            fieldToColumn: CommentRepositoryOperationsImpl._fieldToColumn),
        <String, dynamic>{});
    return Page(
      items: mapper.mapRows(result.rows, database, relationshipContext),
      totalElements: totalElements.rows.first.values.first as int,
      pageNumber: pageable.page,
      pageSize: pageable.size,
    );
  }

  Future<List<Comment>> findByPostId(id) async {
    final result = await operations.findByPostId(id);
    return mapper.mapRows(result.rows, database, relationshipContext);
  }
}
