// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_repository.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

class PostRepositoryImpl extends PostRepository {
  PostRepositoryImpl(
    this.database,
    RelationshipContext relationshipContext,
  ) : super(relationshipContext);

  final DatapodDatabase database;

  static const _insertSql =
      'INSERT INTO posts (title, content, status, metadata, tags, author_id) VALUES (@title, @content, @status, @metadata, @tags, @authorId) RETURNING id';

  static const _updateSql =
      'UPDATE posts SET title = @title, content = @content, status = @status, metadata = @metadata, tags = @tags, author_id = @authorId WHERE id = @id';

  static const _deleteSql = 'DELETE FROM posts WHERE id = @id';

  static const _findByIdSql = 'SELECT * FROM posts WHERE id = @id';

  @override
  Future<Post> save(entity) async {
    final managed = entity is ManagedEntity
        ? (entity as ManagedPost)
        : ManagedPost.fromEntity(entity, database, relationshipContext);
    final author = await managed.author;
    if (author != null) {
      if (author is ManagedEntity) {
        managed.authorId = (author as dynamic).id;
      }
    }
    final params = <String, dynamic>{
      'id': managed.id,
      'title': managed.title,
      'content': managed.content,
      'status': managed.status?.name,
      'metadata': jsonEncode(managed.metadata),
      'tags': jsonEncode(managed.tags),
      'authorId': managed.authorId,
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
    var comments = await managed.comments;
    if (comments != null && comments.isNotEmpty) {
      for (var child in comments) {
        if (child is! ManagedEntity) {
          child =
              ManagedComment.fromEntity(child, database, relationshipContext);
        }
        (child as dynamic).postId = managed.id;
        await relationshipContext.getForEntity<Comment>().save(child);
      }
    }
    return managed;
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
              .getForEntity<Comment>()
              .delete((child as dynamic).id);
        }
      }
    }
    await database.connection.execute(_deleteSql, {'id': id});
  }

  @override
  Future<Post?> findById(id) async {
    final result = await database.connection.execute(_findByIdSql, {'id': id});
    if (result.isEmpty) return null;
    return ManagedPost.fromRow(
        result.rows.first, database, relationshipContext);
  }

  @override
  Future<List<Post>> findByTitleContains(String title) async {
    final params = <String, dynamic>{
      'title': '%$title%',
    };
    final result = await database.connection
        .execute('SELECT * FROM posts WHERE title LIKE @title', params);
    return result.rows
        .map((row) => ManagedPost.fromRow(row, database, relationshipContext))
        .toList();
  }

  @override
  Future<int> countByTitle(String title) async {
    final params = <String, dynamic>{
      'title': title,
    };
    final result = await database.connection
        .execute('SELECT COUNT(*) FROM posts WHERE title = @title', params);
    return result.rows.first.values.first as int;
  }

  Future<List<Post>> findByAuthorId(id) async {
    final sql = 'SELECT * FROM posts WHERE author_id = @id';
    final result = await database.connection.execute(sql, {'id': id});
    return result.rows
        .map((row) => ManagedPost.fromRow(row, database, relationshipContext))
        .toList();
  }
}
