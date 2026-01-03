// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_entities.dart';

// **************************************************************************
// EntityGenerator
// **************************************************************************

class ManagedTestEntity extends TestEntity implements ManagedEntity {
  ManagedTestEntity();

  ManagedTestEntity.fromRow(
    Map<String, dynamic> row,
    DatapodDatabase database,
    RelationshipContext relationshipContext,
  )   : _database = database,
        _relationshipContext = relationshipContext {
    _isPersistent = true;
    super.id = row['id'];
    super.name = row['name'];
    super.value = row['value'];
    super.rating = row['rating'];
    super.flag = row['flag'] is int ? row['flag'] == 1 : row['flag'];
    super.createdAt = row['created_at'] is String
        ? DateTime.parse(row['created_at'])
        : row['created_at'];
    super.type = row['type'] != null
        ? TestEnum.values.firstWhere((e) => e.name == row['type'])
        : super.type;
    super.data = row['data'] is String
        ? Map.from(jsonDecode(row['data']))
        : (row['data'] != null ? Map.from(row['data']) : null);
    super.tags = row['tags'] is String
        ? List.from(jsonDecode(row['tags']))
        : (row['tags'] != null ? List.from(row['tags']) : null);
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
    super.name = entity.name;
    super.value = entity.value;
    super.rating = entity.rating;
    super.flag = entity.flag;
    super.createdAt = entity.createdAt;
    super.type = entity.type;
    super.data = entity.data;
    super.tags = entity.tags;
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
}
