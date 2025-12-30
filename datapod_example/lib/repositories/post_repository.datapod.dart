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
      'INSERT INTO posts (title, content, author_id) VALUES (@title, @content, @authorId) RETURNING id';

  static const _updateSql =
      'UPDATE posts SET title = @title, content = @content, author_id = @authorId WHERE id = @id';

  static const _deleteSql = 'DELETE FROM posts WHERE id = @id';

  static const _findByIdSql = 'SELECT * FROM posts WHERE id = @id';

  @override
  Future<Post> save(entity) async {
    final params = <String, dynamic>{
      'id': entity.id,
      'title': entity.title,
      'content': entity.content,
      'authorId':
          (entity is ManagedEntity) ? (entity as dynamic).authorId : null,
    };
    if (entity is ManagedEntity) {
      final managed = entity as ManagedEntity;
      if (managed.isPersistent) {
        if (managed.isDirty) {
          await database.connection.execute(_updateSql, params);
          managed.clearDirty();
        }
      } else {
        final result = await database.connection.execute(_insertSql, params);
        managed.markPersistent();
        (entity as dynamic).id = result.lastInsertId;
        managed.clearDirty();
      }
    } else {
      await database.connection.execute(_insertSql, params);
    }
    final comments = await entity.comments;
    if (comments != null && comments.isNotEmpty) {
      for (final child in comments) {
        (child as dynamic).postId = entity.id;
        await relationshipContext.getForEntity<Comment>().save(child);
      }
    }
    return entity;
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
