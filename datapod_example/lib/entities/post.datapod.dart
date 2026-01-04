// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// EntityGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.
// ignore_for_file: prefer_interpolation_to_compose_strings, duplicate_ignore

class ManagedPost extends Post implements ManagedEntity {
  ManagedPost();

  ManagedPost.fromRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext, {
    String aliasPrefix = '',
  })  : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = row[aliasPrefix + "id"];
    super.title = row[aliasPrefix + "title"];
    super.readingTime = row[aliasPrefix + "reading_time"] != null
        ? const DurationConverter()
            .convertToEntityAttribute(row[aliasPrefix + "reading_time"])
        : null;
    super.createdAt = row[aliasPrefix + "created_at"] is String
        ? DateTime.parse(row[aliasPrefix + "created_at"])
        : row[aliasPrefix + "created_at"];
    super.updatedAt = row[aliasPrefix + "updated_at"] is String
        ? DateTime.parse(row[aliasPrefix + "updated_at"])
        : row[aliasPrefix + "updated_at"];
    super.content = row[aliasPrefix + "content"];
    super.status = row[aliasPrefix + "status"] != null
        ? PostStatus.values
            .firstWhere((e) => e.name == row[aliasPrefix + "status"])
        : super.status;
    super.metadata = row[aliasPrefix + "metadata"] is String
        ? (jsonDecode(row[aliasPrefix + "metadata"]) as Map?)
            ?.cast<String, dynamic>()
        : (row[aliasPrefix + "metadata"] != null
            ? Map<String, dynamic>.from(row[aliasPrefix + "metadata"])
            : null);
    super.tags = row[aliasPrefix + "tags"] is String
        ? (jsonDecode(row[aliasPrefix + "tags"]) as List?)?.cast<String>()
        : (row[aliasPrefix + "tags"] != null
            ? List<String>.from(row[aliasPrefix + "tags"])
            : null);
    authorId = row[aliasPrefix + "author_id"] ?? row["authorId"];
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
    super.readingTime = entity.readingTime;
    super.createdAt = entity.createdAt;
    super.updatedAt = entity.updatedAt;
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
  dynamic get $id => id;

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
  set readingTime(Duration? value) {
    if (value != super.readingTime) {
      _isDirty = true;
      super.readingTime = value;
    }
  }

  @override
  set createdAt(DateTime? value) {
    if (value != super.createdAt) {
      _isDirty = true;
      super.createdAt = value;
    }
  }

  @override
  set updatedAt(DateTime? value) {
    if (value != super.updatedAt) {
      _isDirty = true;
      super.updatedAt = value;
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
      final ops = $relationshipContext!.getOperations<User, dynamic>();
      final mapper = $relationshipContext!.getMapper<User>();
      final result = await ops.findById(authorId);
      if (result.isNotEmpty) {
        _loadedAuthor = Future.value(mapper.mapRow(
            result.rows.first, $database!, $relationshipContext!));
      }
    }
    return await _loadedAuthor;
  }

  @override
  set author(Future<User?>? value) {
    if (value != _loadedAuthor) {
      _loadedAuthor = value;
      _isDirty = true;
    }
  }

  @override
  Future<List<Comment>>? get comments async {
    if (_loadedComments == null && id != null && $relationshipContext != null) {
      final ops = $relationshipContext!.getOperations<Comment, dynamic>();
      final mapper = $relationshipContext!.getMapper<Comment>();
      final result = await (ops as dynamic).findByPostId(id!);
      _loadedComments = Future.value(
          mapper.mapRows(result.rows, $database!, $relationshipContext!));
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

class PostMapperImpl extends EntityMapper<Post> {
  @override
  Post mapRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext, {
    String aliasPrefix = '',
  }) {
    return ManagedPost.fromRow(row, database, relationshipContext,
        aliasPrefix: aliasPrefix);
  }
}
