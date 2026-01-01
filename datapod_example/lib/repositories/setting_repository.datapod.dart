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
    final managed = entity is ManagedEntity
        ? (entity as ManagedSetting)
        : ManagedSetting.fromEntity(entity, database, relationshipContext);
    final params = <String, dynamic>{
      'id': managed.id,
      'key': managed.key,
      'value': managed.value,
    };
    if (managed.isPersistent) {
      if (managed.isDirty) {
        await database.connection.execute(_updateSql, params);
        managed.clearDirty();
      }
    } else {
      final result = await database.connection.execute(_insertSql, params);
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
        await relationshipContext.getForEntity<SettingAudit>().save(child);
      }
    }
    return managed;
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
