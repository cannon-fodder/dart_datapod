// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// EntityGenerator
// **************************************************************************

class ManagedUser extends User implements ManagedEntity {
  ManagedUser();

  ManagedUser.fromRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = row['id'];
    super.name = row['name'];
  }

  bool _isManaged = true;

  bool _isPersistent = false;

  bool _isDirty = false;

  DatapodDatabase? _database;

  RelationshipContext? _relationshipContext;

  Future<List<Post>>? _loadedPosts;

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
  set name(String? value) {
    if (value != super.name) {
      _isDirty = true;
      super.name = value;
    }
  }

  @override
  Future<List<Post>>? get posts async {
    if (_loadedPosts == null && $relationshipContext != null) {
      _loadedPosts = ($relationshipContext!.getForEntity<Post>() as dynamic)
          .findByAuthorId(id!) as Future<List<Post>>?;
    }
    return await _loadedPosts ?? <Post>[];
  }

  @override
  set posts(value) {
    if (_loadedPosts != value) {
      _loadedPosts = value;
      markDirty();
    }
  }
}
