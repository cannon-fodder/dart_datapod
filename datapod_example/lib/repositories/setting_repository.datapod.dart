// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_repository.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

class SettingRepositoryImpl extends SettingRepository {
  SettingRepositoryImpl(
    this.database,
    RelationshipContext relationshipContext,
  ) : super(relationshipContext);

  final DatapodDatabase database;

  static const _insertSql =
      'INSERT INTO settings (key, value) VALUES (@key, @value) RETURNING id';

  static const _updateSql =
      'UPDATE settings SET key = @key, value = @value WHERE id = @id';

  static const _deleteSql = 'DELETE FROM settings WHERE id = @id';

  static const _findByIdSql = 'SELECT * FROM settings WHERE id = @id';

  @override
  Future<Setting> save(entity) async {
    final params = <String, dynamic>{
      'id': entity.id,
      'key': entity.key,
      'value': entity.value,
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
    final auditTrail = await entity.auditTrail;
    if (auditTrail != null && auditTrail.isNotEmpty) {
      for (final child in auditTrail) {
        (child as dynamic).settingId = entity.id;
        await relationshipContext.getForEntity<SettingAudit>().save(child);
      }
    }
    return entity;
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
              .getForEntity<SettingAudit>()
              .delete((child as dynamic).id);
        }
      }
    }
    await database.connection.execute(_deleteSql, {'id': id});
  }

  @override
  Future<Setting?> findById(id) async {
    final result = await database.connection.execute(_findByIdSql, {'id': id});
    if (result.isEmpty) return null;
    return ManagedSetting.fromRow(
        result.rows.first, database, relationshipContext);
  }

  @override
  Future<Setting?> findByKey(String key) async {
    final params = <String, dynamic>{
      'key': key,
    };
    final result = await database.connection
        .execute('SELECT * FROM settings WHERE key = @key', params);
    if (result.isEmpty) return null;
    return ManagedSetting.fromRow(
        result.rows.first, database, relationshipContext);
  }
}
