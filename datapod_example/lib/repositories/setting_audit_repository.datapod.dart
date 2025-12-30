// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_audit_repository.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

class SettingAuditRepositoryImpl extends SettingAuditRepository {
  SettingAuditRepositoryImpl(
    this.database,
    RelationshipContext relationshipContext,
  ) : super(relationshipContext);

  final DatapodDatabase database;

  static const _insertSql =
      'INSERT INTO setting_audits (action, timestamp, setting_id) VALUES (@action, @timestamp, @settingId) RETURNING id';

  static const _updateSql =
      'UPDATE setting_audits SET action = @action, timestamp = @timestamp, setting_id = @settingId WHERE id = @id';

  static const _deleteSql = 'DELETE FROM setting_audits WHERE id = @id';

  static const _findByIdSql = 'SELECT * FROM setting_audits WHERE id = @id';

  @override
  Future<SettingAudit> save(entity) async {
    final params = <String, dynamic>{
      'id': entity.id,
      'action': entity.action,
      'timestamp': entity.timestamp,
      'settingId':
          (entity is ManagedEntity) ? (entity as dynamic).settingId : null,
    };
    if (entity is ManagedEntity) {
      final managed = entity as ManagedEntity;
      if (managed.isPersistent) {
        if (managed.isDirty) {
          await database.connection.execute(_updateSql, params);
          managed.clearDirty();
        }
      } else {
        final result = await database.connection.execute(_insertSql, params);
        managed.markPersistent();
        (entity as dynamic).id = result.lastInsertId;
        managed.clearDirty();
      }
    } else {
      await database.connection.execute(_insertSql, params);
    }
    return entity;
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
    await database.connection.execute(_deleteSql, {'id': id});
  }

  @override
  Future<SettingAudit?> findById(id) async {
    final result = await database.connection.execute(_findByIdSql, {'id': id});
    if (result.isEmpty) return null;
    return ManagedSettingAudit.fromRow(
        result.rows.first, database, relationshipContext);
  }

  Future<List<SettingAudit>> findBySettingId(id) async {
    final sql = 'SELECT * FROM setting_audits WHERE setting_id = @id';
    final result = await database.connection.execute(sql, {'id': id});
    return result.rows
        .map((row) =>
            ManagedSettingAudit.fromRow(row, database, relationshipContext))
        .toList();
  }
}
