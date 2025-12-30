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
    authorId = row['author_id'];
  }

  bool _isManaged = true;

  bool _isPersistent = false;

  bool _isDirty = false;

  DatapodDatabase? _database;

  RelationshipContext? _relationshipContext;

  Future<User?>? _loadedAuthor;

  dynamic authorId;

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
  Future<User?>? get author async {
    if (_loadedAuthor == null &&
        authorId != null &&
        $relationshipContext != null) {
      _loadedAuthor = $relationshipContext!
          .getForEntity<User>()
          .findById(authorId!) as Future<User?>?;
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
}
