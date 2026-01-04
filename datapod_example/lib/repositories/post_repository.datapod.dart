// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_repository.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

class PostRepositoryOperationsImpl implements DatabaseOperations<Post, int> {
  PostRepositoryOperationsImpl(
    this.database,
    this.relationshipContext,
  );

  final DatapodDatabase database;

  final RelationshipContext relationshipContext;

  static const _insertSql =
      '''INSERT INTO posts (title, reading_time, created_at, updated_at, content, status, metadata, tags, author_id) VALUES (@title, @readingTime, @createdAt, @updatedAt, @content, @status, @metadata, @tags, @authorId) RETURNING id''';

  static const _updateSql =
      '''UPDATE posts SET title = @title, reading_time = @readingTime, created_at = @createdAt, updated_at = @updatedAt, content = @content, status = @status, metadata = @metadata, tags = @tags, author_id = @authorId WHERE id = @id''';

  static const _deleteSql = '''DELETE FROM posts WHERE id = @id''';

  static const _findByIdSql = '''SELECT * FROM posts WHERE id = @id''';

  static const _fieldToColumn = {
    'id': 'id',
    'title': 'title',
    'readingTime': 'reading_time',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
    'content': 'content',
    'status': 'status',
    'metadata': 'metadata',
    'tags': 'tags',
    'author': 'author_id',
    'comments': ''
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
  Future<Post> saveEntity(Post entity) async {
    final ManagedPost managed = entity is ManagedEntity
        ? (entity as ManagedPost)
        : ManagedPost.fromEntity(entity, database, relationshipContext);
    final author = await managed.author;
    if (author != null) {
      if (author is ManagedEntity) {
        managed.authorId = (author as dynamic).id;
      }
    }
    final now = DateTime.now();
    if (!managed.isPersistent && managed.createdAt == null) {
      managed.createdAt = now;
    }
    managed.updatedAt = now;
    final params = <String, dynamic>{
      r'id': managed.id,
      r'title': managed.title,
      r'readingTime': managed.readingTime != null
          ? const DurationConverter()
              .convertToDatabaseColumn(managed.readingTime!)
          : null,
      r'createdAt': managed.createdAt,
      r'updatedAt': managed.updatedAt,
      r'content': managed.content,
      r'status': managed.status?.name,
      r'metadata': jsonEncode(managed.metadata),
      r'tags': jsonEncode(managed.tags),
      'authorId': managed.authorId,
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
    var comments = await managed.comments;
    if (comments != null && comments.isNotEmpty) {
      for (var child in comments) {
        if (child is! ManagedEntity) {
          child =
              ManagedComment.fromEntity(child, database, relationshipContext);
        }
        (child as dynamic).postId = managed.id;
        await relationshipContext
            .getOperations<Comment, dynamic>()
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
    final sql = applyPagination('''SELECT * FROM posts''',
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

  Future<QueryResult> findByTitleContains(String title) async {
    final params = <String, dynamic>{'title': '%$title%'};
    final sql = applyPagination(
        '''SELECT * FROM posts WHERE title LIKE @title''',
        sort: null, limit: null, offset: null, fieldToColumn: _fieldToColumn);
    return database.connection.execute(sql, params);
  }

  Future<QueryResult> countByTitle(String title) async {
    final params = <String, dynamic>{'title': title};
    final sql = applyPagination(
        '''SELECT COUNT(*) FROM posts WHERE title = @title''',
        sort: null, limit: null, offset: null, fieldToColumn: _fieldToColumn);
    return database.connection.execute(sql, params);
  }

  Future<QueryResult> findByAuthorId(dynamic id) {
    final sql = 'SELECT * FROM posts WHERE author_id = @id';
    return database.connection.execute(sql, {'id': id});
  }
}

class PostRepositoryImpl extends PostRepository {
  PostRepositoryImpl(
    this.database,
    this.operations,
    this.mapper,
    RelationshipContext relationshipContext,
  ) : super(relationshipContext);

  final DatapodDatabase database;

  final PostRepositoryOperationsImpl operations;

  final PostMapperImpl mapper;

  @override
  Future<Post> save(entity) async {
    return await operations.saveEntity(entity);
  }

  @override
  Future<List<Post>> saveAll(entities) async {
    final saved = <Post>[];
    for (final entity in entities) {
      saved.add(await save(entity));
    }
    return saved;
  }

  @override
  Future<void> delete(id) async {
    final entity = await findById(id);
    if (entity != null) {
      final comments = await entity.comments;
      if (comments != null) {
        for (final child in comments) {
          await relationshipContext
              .getOperations<Comment, dynamic>()
              .delete((child as dynamic).id);
        }
      }
    }
    await operations.delete(id);
  }

  @override
  Future<Post?> findById(id) async {
    final result = await operations.findById(id);
    if (result.isEmpty) return null;
    return mapper.mapRow(result.rows.first, database, relationshipContext);
  }

  @override
  Future<List<Post>> findAll({List<Sort>? sort}) async {
    final result = await operations.findAll(sort: sort);
    return mapper.mapRows(result.rows, database, relationshipContext);
  }

  @override
  Future<Page<Post>> findAllPaged(Pageable pageable) async {
    final result = await operations.findAll(
        limit: pageable.size, offset: pageable.offset, sort: pageable.sort);
    final totalElements = await operations.database.connection.execute(
        applyPagination('''SELECT COUNT(*) FROM posts''',
            fieldToColumn: PostRepositoryOperationsImpl._fieldToColumn),
        <String, dynamic>{});
    return Page(
      items: mapper.mapRows(result.rows, database, relationshipContext),
      totalElements: totalElements.rows.first.values.first as int,
      pageNumber: pageable.page,
      pageSize: pageable.size,
    );
  }

  @override
  Future<List<Post>> findByTitleContains(String title) async {
    final result = await operations.findByTitleContains(title);
    return mapper.mapRows(result.rows, database, relationshipContext);
  }

  @override
  Future<int> countByTitle(String title) async {
    final result = await operations.countByTitle(title);
    return result.rows.first.values.first as int;
  }

  Future<List<Post>> findByAuthorId(id) async {
    final result = await operations.findByAuthorId(id);
    return mapper.mapRows(result.rows, database, relationshipContext);
  }
}
