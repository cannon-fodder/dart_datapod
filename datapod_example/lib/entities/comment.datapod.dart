// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// EntityGenerator
// **************************************************************************

class ManagedComment extends Comment implements ManagedEntity {
  ManagedComment();

  ManagedComment.fromRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = row['id'];
    super.content = row['content'];
    postId = row['post_id'];
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
      _loadedPost = $relationshipContext!.getForEntity<Post>().findById(postId)
          as Future<Post?>?;
    }
    return await _loadedPost;
  }

  @override
  set post(Future<Post?>? value) {
    if (value != _loadedPost) {
      _loadedPost = value;
      _isDirty = true;
      // TODO: If value is persistent, update postId
    }
  }
}
