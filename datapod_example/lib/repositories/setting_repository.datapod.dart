// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_repository.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

class SettingRepositoryOperationsImpl
    implements DatabaseOperations<Setting, int> {
  SettingRepositoryOperationsImpl(
    this.database,
    this.relationshipContext,
  );

  final DatapodDatabase database;

  final RelationshipContext relationshipContext;

  static const _insertSql =
      '''INSERT INTO settings (key, value) VALUES (@key, @value) RETURNING id''';

  static const _updateSql =
      '''UPDATE settings SET key = @key, value = @value WHERE id = @id''';

  static const _deleteSql = '''DELETE FROM settings WHERE id = @id''';

  static const _findByIdSql = '''SELECT * FROM settings WHERE id = @id''';

  static const _fieldToColumn = {
    'id': 'id',
    'key': 'key',
    'value': 'value',
    'auditTrail': ''
  };

  @override
  Future<QueryResult> save(
    Map<String, dynamic> params, {
    bool isUpdate = false,
  }) async {
    return database.connection
        .execute(isUpdate ? _updateSql : _insertSql, params);
  }

  @override
  Future<Setting> saveEntity(Setting entity) async {
    final ManagedSetting managed = entity is ManagedEntity
        ? (entity as ManagedSetting)
        : ManagedSetting.fromEntity(entity, database, relationshipContext);
    final params = <String, dynamic>{
      r'id': managed.id,
      r'key': managed.key,
      r'value': managed.value,
    };
    if (managed.isPersistent) {
      if (managed.isDirty) {
        await save(params, isUpdate: true);
        managed.clearDirty();
      }
    } else {
      final result = await save(params, isUpdate: false);
      managed.markPersistent();
      managed.id = result.lastInsertId;
      managed.clearDirty();
    }
    var auditTrail = await managed.auditTrail;
    if (auditTrail != null && auditTrail.isNotEmpty) {
      for (var child in auditTrail) {
        if (child is! ManagedEntity) {
          child = ManagedSettingAudit.fromEntity(
              child, database, relationshipContext);
        }
        (child as dynamic).settingId = managed.id;
        await relationshipContext
            .getOperations<SettingAudit, dynamic>()
            .saveEntity(child);
      }
    }
    return managed;
  }

  @override
  Future<QueryResult> findAll({
    List<Sort>? sort,
    int? limit,
    int? offset,
  }) async {
    final sql = applyPagination('''SELECT * FROM settings''',
        sort: sort,
        limit: limit,
        offset: offset,
        fieldToColumn: _fieldToColumn);
    return database.connection.execute(sql, {});
  }

  @override
  Future<void> delete(int id) async {
    await database.connection.execute(_deleteSql, {'id': id});
  }

  @override
  Future<QueryResult> findById(int id) async {
    return database.connection.execute(_findByIdSql, {'id': id});
  }

  Future<QueryResult> findByKey(String key) async {
    final params = <String, dynamic>{'key': key};
    final sql = applyPagination('''SELECT * FROM settings WHERE key = @key''',
        sort: null, limit: null, offset: null, fieldToColumn: _fieldToColumn);
    return database.connection.execute(sql, params);
  }
}

class SettingRepositoryImpl extends SettingRepository {
  SettingRepositoryImpl(
    this.database,
    this.operations,
    this.mapper,
    RelationshipContext relationshipContext,
  ) : super(relationshipContext);

  final DatapodDatabase database;

  final SettingRepositoryOperationsImpl operations;

  final SettingMapperImpl mapper;

  @override
  Future<Setting> save(entity) async {
    return await operations.saveEntity(entity);
  }

  @override
  Future<List<Setting>> saveAll(entities) async {
    final saved = <Setting>[];
    for (final entity in entities) {
      saved.add(await save(entity));
    }
    return saved;
  }

  @override
  Future<void> delete(id) async {
    final entity = await findById(id);
    if (entity != null) {
      final auditTrail = await entity.auditTrail;
      if (auditTrail != null) {
        for (final child in auditTrail) {
          await relationshipContext
              .getOperations<SettingAudit, dynamic>()
              .delete((child as dynamic).id);
        }
      }
    }
    await operations.delete(id);
  }

  @override
  Future<Setting?> findById(id) async {
    final result = await operations.findById(id);
    if (result.isEmpty) return null;
    return mapper.mapRow(result.rows.first, database, relationshipContext);
  }

  @override
  Future<List<Setting>> findAll({List<Sort>? sort}) async {
    final result = await operations.findAll(sort: sort);
    return mapper.mapRows(result.rows, database, relationshipContext);
  }

  @override
  Future<Page<Setting>> findAllPaged(Pageable pageable) async {
    final result = await operations.findAll(
        limit: pageable.size, offset: pageable.offset, sort: pageable.sort);
    final totalElements = await operations.database.connection.execute(
        applyPagination('''SELECT COUNT(*) FROM settings''',
            fieldToColumn: SettingRepositoryOperationsImpl._fieldToColumn),
        <String, dynamic>{});
    return Page(
      items: mapper.mapRows(result.rows, database, relationshipContext),
      totalElements: totalElements.rows.first.values.first as int,
      pageNumber: pageable.page,
      pageSize: pageable.size,
    );
  }

  @override
  Future<Setting?> findByKey(String key) async {
    final result = await operations.findByKey(key);
    if (result.isEmpty) return null;
    return mapper.mapRow(result.rows.first, database, relationshipContext);
  }
}
