// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_repository.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

class CommentRepositoryImpl extends CommentRepository {
  CommentRepositoryImpl(
    this.database,
    RelationshipContext relationshipContext,
  ) : super(relationshipContext);

  final DatapodDatabase database;

  static const _insertSql =
      'INSERT INTO comments (content, post_id) VALUES (@content, @postId) RETURNING id';

  static const _updateSql =
      'UPDATE comments SET content = @content, post_id = @postId WHERE id = @id';

  static const _deleteSql = 'DELETE FROM comments WHERE id = @id';

  static const _findByIdSql = 'SELECT * FROM comments WHERE id = @id';

  @override
  Future<Comment> save(entity) async {
    final params = <String, dynamic>{
      'id': entity.id,
      'content': entity.content,
      'postId': (entity is ManagedEntity) ? (entity as dynamic).postId : null,
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
    return entity;
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
    await database.connection.execute(_deleteSql, {'id': id});
  }

  @override
  Future<Comment?> findById(id) async {
    final result = await database.connection.execute(_findByIdSql, {'id': id});
    if (result.isEmpty) return null;
    return ManagedComment.fromRow(
        result.rows.first, database, relationshipContext);
  }

  Future<List<Comment>> findByPostId(id) async {
    final sql = 'SELECT * FROM comments WHERE post_id = @id';
    final result = await database.connection.execute(sql, {'id': id});
    return result.rows
        .map(
            (row) => ManagedComment.fromRow(row, database, relationshipContext))
        .toList();
  }
}
