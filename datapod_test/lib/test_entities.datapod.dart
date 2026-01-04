// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_entities.dart';

// **************************************************************************
// EntityGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.
// ignore_for_file: prefer_interpolation_to_compose_strings, duplicate_ignore

class ManagedTestEntity extends TestEntity implements ManagedEntity {
  ManagedTestEntity();

  ManagedTestEntity.fromRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext, {
    String aliasPrefix = '',
  })  : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = row[aliasPrefix + "id"];
    super.duration = row[aliasPrefix + "duration"] != null
        ? const DurationConverter()
            .convertToEntityAttribute(row[aliasPrefix + "duration"])
        : null;
    super.name = row[aliasPrefix + "name"];
    super.value = row[aliasPrefix + "value"];
    super.rating = row[aliasPrefix + "rating"];
    super.flag = row[aliasPrefix + "flag"] is int
        ? row[aliasPrefix + "flag"] == 1
        : row[aliasPrefix + "flag"];
    super.createdAt = row[aliasPrefix + "created_at"] is String
        ? DateTime.parse(row[aliasPrefix + "created_at"])
        : row[aliasPrefix + "created_at"];
    super.updatedAt = row[aliasPrefix + "updated_at"] is String
        ? DateTime.parse(row[aliasPrefix + "updated_at"])
        : row[aliasPrefix + "updated_at"];
    super.type = row[aliasPrefix + "type"] != null
        ? TestEnum.values.firstWhere((e) => e.name == row[aliasPrefix + "type"])
        : super.type;
    super.data = row[aliasPrefix + "data"] is String
        ? (jsonDecode(row[aliasPrefix + "data"]) as Map?)
            ?.cast<String, dynamic>()
        : (row[aliasPrefix + "data"] != null
            ? Map<String, dynamic>.from(row[aliasPrefix + "data"])
            : null);
    super.tags = row[aliasPrefix + "tags"] is String
        ? (jsonDecode(row[aliasPrefix + "tags"]) as List?)?.cast<String>()
        : (row[aliasPrefix + "tags"] != null
            ? List<String>.from(row[aliasPrefix + "tags"])
            : null);
    parentId = row[aliasPrefix + "parent_id"] ?? row["parentId"];
  }

  ManagedTestEntity.fromEntity(
    TestEntity entity,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = entity is ManagedEntity
        ? (entity as ManagedEntity).isPersistent
        : false;
    super.id = entity.id;
    super.duration = entity.duration;
    super.name = entity.name;
    super.value = entity.value;
    super.rating = entity.rating;
    super.flag = entity.flag;
    super.createdAt = entity.createdAt;
    super.updatedAt = entity.updatedAt;
    super.type = entity.type;
    super.data = entity.data;
    super.tags = entity.tags;
    parent = entity.parent;
    if (entity is ManagedEntity) {
      parentId = (entity as dynamic).parentId;
    }
  }

  final bool _isManaged = true;

  bool _isPersistent = false;

  bool _isDirty = false;

  DatapodDatabase? _database;

  RelationshipContext? _relationshipContext;

  Future<TestEntity?>? _loadedParent;

  dynamic parentId;

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
  set duration(Duration? value) {
    if (value != super.duration) {
      _isDirty = true;
      super.duration = value;
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
  set value(int? value) {
    if (value != super.value) {
      _isDirty = true;
      super.value = value;
    }
  }

  @override
  set rating(double? value) {
    if (value != super.rating) {
      _isDirty = true;
      super.rating = value;
    }
  }

  @override
  set flag(bool? value) {
    if (value != super.flag) {
      _isDirty = true;
      super.flag = value;
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
  set type(TestEnum? value) {
    if (value != super.type) {
      _isDirty = true;
      super.type = value;
    }
  }

  @override
  set data(Map<String, dynamic>? value) {
    if (value != super.data) {
      _isDirty = true;
      super.data = value;
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
  Future<TestEntity?>? get parent async {
    if (_loadedParent == null &&
        parentId != null &&
        $relationshipContext != null) {
      final ops = $relationshipContext!.getOperations<TestEntity, dynamic>();
      final mapper = $relationshipContext!.getMapper<TestEntity>();
      final result = await ops.findById(parentId);
      if (result.isNotEmpty) {
        _loadedParent = Future.value(mapper.mapRow(
            result.rows.first, $database!, $relationshipContext!));
      }
    }
    return await _loadedParent;
  }

  @override
  set parent(Future<TestEntity?>? value) {
    if (value != _loadedParent) {
      _loadedParent = value;
      _isDirty = true;
    }
  }
}

class TestEntityMapperImpl extends EntityMapper<TestEntity> {
  @override
  TestEntity mapRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext, {
    String aliasPrefix = '',
  }) {
    return ManagedTestEntity.fromRow(row, database, relationshipContext,
        aliasPrefix: aliasPrefix);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.
// ignore_for_file: prefer_interpolation_to_compose_strings, duplicate_ignore

class ManagedUniqueEntity extends UniqueEntity implements ManagedEntity {
  ManagedUniqueEntity();

  ManagedUniqueEntity.fromRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext, {
    String aliasPrefix = '',
  })  : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = row[aliasPrefix + "id"];
    super.code = row[aliasPrefix + "code"];
    super.folder = row[aliasPrefix + "folder"];
    super.filename = row[aliasPrefix + "filename"];
  }

  ManagedUniqueEntity.fromEntity(
    UniqueEntity entity,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = entity is ManagedEntity
        ? (entity as ManagedEntity).isPersistent
        : false;
    super.id = entity.id;
    super.code = entity.code;
    super.folder = entity.folder;
    super.filename = entity.filename;
  }

  final bool _isManaged = true;

  bool _isPersistent = false;

  bool _isDirty = false;

  DatapodDatabase? _database;

  RelationshipContext? _relationshipContext;

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
  set code(String value) {
    if (value != super.code) {
      _isDirty = true;
      super.code = value;
    }
  }

  @override
  set folder(String value) {
    if (value != super.folder) {
      _isDirty = true;
      super.folder = value;
    }
  }

  @override
  set filename(String value) {
    if (value != super.filename) {
      _isDirty = true;
      super.filename = value;
    }
  }
}

class UniqueEntityMapperImpl extends EntityMapper<UniqueEntity> {
  @override
  UniqueEntity mapRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext, {
    String aliasPrefix = '',
  }) {
    return ManagedUniqueEntity.fromRow(row, database, relationshipContext,
        aliasPrefix: aliasPrefix);
  }
}
