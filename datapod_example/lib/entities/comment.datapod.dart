// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// EntityGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.
// ignore_for_file: prefer_interpolation_to_compose_strings, duplicate_ignore

class ManagedComment extends Comment implements ManagedEntity {
  ManagedComment();

  ManagedComment.fromRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext, {
    String aliasPrefix = '',
  })  : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = row[aliasPrefix + "id"];
    super.content = row[aliasPrefix + "content"];
    postId = row[aliasPrefix + "post_id"] ?? row["postId"];
  }

  ManagedComment.fromEntity(
    Comment entity,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = entity is ManagedEntity
        ? (entity as ManagedEntity).isPersistent
        : false;
    super.id = entity.id;
    super.content = entity.content;
    post = entity.post;
    if (entity is ManagedEntity) {
      postId = (entity as dynamic).postId;
    }
  }

  final bool _isManaged = true;

  bool _isPersistent = false;

  bool _isDirty = false;

  DatapodDatabase? _database;

  RelationshipContext? _relationshipContext;

  Future<Post?>? _loadedPost;

  dynamic postId;

  @override
  bool get isManaged => _isManaged;

  @override
  bool get isPersistent => _isPersistent;

  @override
  bool get isDirty => _isDirty;

  @override
  markPersistent() {
    _isPersistent = true;
  }

  @override
  markDirty() {
    _isDirty = true;
  }

  @override
  clearDirty() {
    _isDirty = false;
  }

  @override
  DatapodDatabase? get $database => _database;

  @override
  set $database(DatapodDatabase? value) {
    _database = value;
  }

  @override
  RelationshipContext? get $relationshipContext => _relationshipContext;

  @override
  set $relationshipContext(RelationshipContext? value) {
    _relationshipContext = value;
  }

  @override
  dynamic get $id => id;

  @override
  set id(int? value) {
    if (value != super.id) {
      _isDirty = true;
      super.id = value;
    }
  }

  @override
  set content(String? value) {
    if (value != super.content) {
      _isDirty = true;
      super.content = value;
    }
  }

  @override
  Future<Post?>? get post async {
    if (_loadedPost == null && postId != null && $relationshipContext != null) {
      final ops = $relationshipContext!.getOperations<Post, dynamic>();
      final mapper = $relationshipContext!.getMapper<Post>();
      final result = await ops.findById(postId);
      if (result.isNotEmpty) {
        _loadedPost = Future.value(mapper.mapRow(
            result.rows.first, $database!, $relationshipContext!));
      }
    }
    return await _loadedPost;
  }

  @override
  set post(Future<Post?>? value) {
    if (value != _loadedPost) {
      _loadedPost = value;
      _isDirty = true;
    }
  }
}

class CommentMapperImpl extends EntityMapper<Comment> {
  @override
  Comment mapRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext, {
    String aliasPrefix = '',
  }) {
    return ManagedComment.fromRow(row, database, relationshipContext,
        aliasPrefix: aliasPrefix);
  }
}
