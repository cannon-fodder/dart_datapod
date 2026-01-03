// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// EntityGenerator
// **************************************************************************

class ManagedPost extends Post implements ManagedEntity {
  ManagedPost();

  ManagedPost.fromRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = row['id'];
    super.title = row['title'];
    super.content = row['content'];
    super.status = row['status'] != null
        ? PostStatus.values.firstWhere((e) => e.name == row['status'])
        : super.status;
    super.metadata = row['metadata'] is String
        ? Map.from(jsonDecode(row['metadata']))
        : (row['metadata'] != null ? Map.from(row['metadata']) : null);
    super.tags = row['tags'] is String
        ? List.from(jsonDecode(row['tags']))
        : (row['tags'] != null ? List.from(row['tags']) : null);
    authorId = row['author_id'];
  }

  ManagedPost.fromEntity(
    Post entity,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = entity is ManagedEntity
        ? (entity as ManagedEntity).isPersistent
        : false;
    super.id = entity.id;
    super.title = entity.title;
    super.content = entity.content;
    super.status = entity.status;
    super.metadata = entity.metadata;
    super.tags = entity.tags;
    author = entity.author;
    if (entity is ManagedEntity) {
      authorId = (entity as dynamic).authorId;
    }
    comments = entity.comments;
  }

  final bool _isManaged = true;

  bool _isPersistent = false;

  bool _isDirty = false;

  DatapodDatabase? _database;

  RelationshipContext? _relationshipContext;

  Future<User?>? _loadedAuthor;

  dynamic authorId;

  Future<List<Comment>>? _loadedComments;

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
  set title(String? value) {
    if (value != super.title) {
      _isDirty = true;
      super.title = value;
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
  set status(PostStatus? value) {
    if (value != super.status) {
      _isDirty = true;
      super.status = value;
    }
  }

  @override
  set metadata(Map<String, dynamic>? value) {
    if (value != super.metadata) {
      _isDirty = true;
      super.metadata = value;
    }
  }

  @override
  set tags(List<String>? value) {
    if (value != super.tags) {
      _isDirty = true;
      super.tags = value;
    }
  }

  @override
  Future<User?>? get author async {
    if (_loadedAuthor == null &&
        authorId != null &&
        $relationshipContext != null) {
      _loadedAuthor = $relationshipContext!
          .getForEntity<User>()
          .findById(authorId) as Future<User?>?;
    }
    return await _loadedAuthor;
  }

  @override
  set author(Future<User?>? value) {
    if (value != _loadedAuthor) {
      _loadedAuthor = value;
      _isDirty = true;
      // TODO: If value is persistent, update authorId
    }
  }

  @override
  Future<List<Comment>>? get comments async {
    if (_loadedComments == null && id != null && $relationshipContext != null) {
      _loadedComments =
          ($relationshipContext!.getForEntity<Comment>() as dynamic)
              .findByPostId(id!) as Future<List<Comment>>?;
    }
    return await _loadedComments ?? <Comment>[];
  }

  @override
  set comments(value) {
    if (_loadedComments != value) {
      _loadedComments = value;
      markDirty();
    }
  }
}
