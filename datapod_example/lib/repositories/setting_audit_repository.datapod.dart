// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_audit_repository.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

class SettingAuditRepositoryOperationsImpl
    implements DatabaseOperations<SettingAudit, int> {
  SettingAuditRepositoryOperationsImpl(
    this.database,
    this.relationshipContext,
  );

  final DatapodDatabase database;

  final RelationshipContext relationshipContext;

  static const _insertSql =
      '''INSERT INTO setting_audits (action, timestamp, setting_id) VALUES (@action, @timestamp, @settingId) RETURNING id''';

  static const _updateSql =
      '''UPDATE setting_audits SET action = @action, timestamp = @timestamp, setting_id = @settingId WHERE id = @id''';

  static const _deleteSql = '''DELETE FROM setting_audits WHERE id = @id''';

  static const _findByIdSql = '''SELECT * FROM setting_audits WHERE id = @id''';

  static const _fieldToColumn = {
    'id': 'id',
    'action': 'action',
    'timestamp': 'timestamp',
    'setting': 'setting_id'
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
  Future<SettingAudit> saveEntity(SettingAudit entity) async {
    final ManagedSettingAudit managed = entity is ManagedEntity
        ? (entity as ManagedSettingAudit)
        : ManagedSettingAudit.fromEntity(entity, database, relationshipContext);
    final setting = await managed.setting;
    if (setting != null) {
      if (setting is ManagedEntity) {
        managed.settingId = (setting as dynamic).id;
      }
    }
    final params = <String, dynamic>{
      r'id': managed.id,
      r'action': managed.action,
      r'timestamp': managed.timestamp,
      'settingId': managed.settingId,
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
    return managed;
  }

  @override
  Future<QueryResult> findAll({
    List<Sort>? sort,
    int? limit,
    int? offset,
  }) async {
    final sql = applyPagination('''SELECT * FROM setting_audits''',
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

  Future<QueryResult> findBySettingId(dynamic id) {
    final sql = 'SELECT * FROM setting_audits WHERE setting_id = @id';
    return database.connection.execute(sql, {'id': id});
  }
}

class SettingAuditRepositoryImpl extends SettingAuditRepository {
  SettingAuditRepositoryImpl(
    this.database,
    this.operations,
    this.mapper,
    RelationshipContext relationshipContext,
  ) : super(relationshipContext);

  final DatapodDatabase database;

  final SettingAuditRepositoryOperationsImpl operations;

  final SettingAuditMapperImpl mapper;

  @override
  Future<SettingAudit> save(entity) async {
    return await operations.saveEntity(entity);
  }

  @override
  Future<List<SettingAudit>> saveAll(entities) async {
    final saved = <SettingAudit>[];
    for (final entity in entities) {
      saved.add(await save(entity));
    }
    return saved;
  }

  @override
  Future<void> delete(id) async {
    await operations.delete(id);
  }

  @override
  Future<SettingAudit?> findById(id) async {
    final result = await operations.findById(id);
    if (result.isEmpty) return null;
    return mapper.mapRow(result.rows.first, database, relationshipContext);
  }

  @override
  Future<List<SettingAudit>> findAll({List<Sort>? sort}) async {
    final result = await operations.findAll(sort: sort);
    return mapper.mapRows(result.rows, database, relationshipContext);
  }

  @override
  Future<Page<SettingAudit>> findAllPaged(Pageable pageable) async {
    final result = await operations.findAll(
        limit: pageable.size, offset: pageable.offset, sort: pageable.sort);
    final totalElements = await operations.database.connection.execute(
        applyPagination('''SELECT COUNT(*) FROM setting_audits''',
            fieldToColumn: SettingAuditRepositoryOperationsImpl._fieldToColumn),
        <String, dynamic>{});
    return Page(
      items: mapper.mapRows(result.rows, database, relationshipContext),
      totalElements: totalElements.rows.first.values.first as int,
      pageNumber: pageable.page,
      pageSize: pageable.size,
    );
  }

  Future<List<SettingAudit>> findBySettingId(id) async {
    final result = await operations.findBySettingId(id);
    return mapper.mapRows(result.rows, database, relationshipContext);
  }
}
