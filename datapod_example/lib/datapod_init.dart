// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:datapod_api/datapod_api.dart';
import 'package:datapod_core/datapod_core.dart';
import 'package:datapod_postgres/datapod_postgres.dart';
import 'package:datapod_mysql/datapod_mysql.dart';
import 'package:datapod_sqlite/datapod_sqlite.dart';
import 'package:datapod_example/repositories/user_repository.dart';
import 'package:datapod_example/repositories/setting_repository.dart';
import 'package:datapod_example/repositories/role_repository.dart';
import 'package:datapod_example/repositories/post_repository.dart';
import 'package:datapod_example/repositories/setting_audit_repository.dart';
import 'package:datapod_example/repositories/comment_repository.dart';
import 'package:datapod_example/entities/role.dart';
import 'package:datapod_example/entities/setting_audit.dart';
import 'package:datapod_example/entities/post.dart';
import 'package:datapod_example/entities/user.dart';
import 'package:datapod_example/entities/comment.dart';
import 'package:datapod_example/entities/setting.dart';

class DatapodInitializer {
  static Future<void> initialize({
    String databasesPath = 'databases.yaml',
    String connectionsPath = 'connections.yaml',
  }) async {
    await Databases.initialize(
      databasesPath: databasesPath,
      connectionsPath: connectionsPath,
    );

    final sharedContext = RelationshipContextImpl();

    // Initialize postgres_db
    final pluginPostgresDb = PostgresPlugin();
    final dbConfigPostgresDb = (await DatabaseConfig.load(databasesPath)).firstWhere((c) => c.name == 'postgres_db');
    final connConfigPostgresDb = (await ConnectionConfig.load(connectionsPath)).firstWhere((c) => c.name == 'postgres_db');
    final databasePostgresDb = await pluginPostgresDb.createDatabase(dbConfigPostgresDb, connConfigPostgresDb);
    Databases.register('postgres_db', databasePostgresDb);

    databasePostgresDb.connection.schemaManager.setSchema(const SchemaDefinition(tables: [
      TableDefinition(name: 'roles', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'user_id', type: 'int', isNullable: true, isAutoIncrement: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_roles_user_id', columns: ['user_id'], referencedTable: 'users', referencedColumns: ['id'])]),
      TableDefinition(name: 'setting_audits', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true), ColumnDefinition(name: 'action', type: 'String', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'timestamp', type: 'DateTime', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'setting_id', type: 'int', isNullable: true, isAutoIncrement: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_setting_audits_setting_id', columns: ['setting_id'], referencedTable: 'settings', referencedColumns: ['id'])]),
      TableDefinition(name: 'posts', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true), ColumnDefinition(name: 'title', type: 'String', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'author_id', type: 'int', isNullable: true, isAutoIncrement: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_posts_author_id', columns: ['author_id'], referencedTable: 'users', referencedColumns: ['id'])]),
      TableDefinition(name: 'users', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false)], primaryKey: ['id'], foreignKeys: []),
      TableDefinition(name: 'comments', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'post_id', type: 'int', isNullable: true, isAutoIncrement: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_comments_post_id', columns: ['post_id'], referencedTable: 'posts', referencedColumns: ['id'])]),
      TableDefinition(name: 'settings', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true), ColumnDefinition(name: 'key', type: 'String', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'value', type: 'String', isNullable: true, isAutoIncrement: false)], primaryKey: ['id'], foreignKeys: []),
    ]));

    final userRepository = UserRepositoryImpl(databasePostgresDb, sharedContext);
    final roleRepository = RoleRepositoryImpl(databasePostgresDb, sharedContext);

    // Initialize mysql_db
    final pluginMysqlDb = MySqlPlugin();
    final dbConfigMysqlDb = (await DatabaseConfig.load(databasesPath)).firstWhere((c) => c.name == 'mysql_db');
    final connConfigMysqlDb = (await ConnectionConfig.load(connectionsPath)).firstWhere((c) => c.name == 'mysql_db');
    final databaseMysqlDb = await pluginMysqlDb.createDatabase(dbConfigMysqlDb, connConfigMysqlDb);
    Databases.register('mysql_db', databaseMysqlDb);

    databaseMysqlDb.connection.schemaManager.setSchema(const SchemaDefinition(tables: [
      TableDefinition(name: 'roles', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'user_id', type: 'int', isNullable: true, isAutoIncrement: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_roles_user_id', columns: ['user_id'], referencedTable: 'users', referencedColumns: ['id'])]),
      TableDefinition(name: 'setting_audits', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true), ColumnDefinition(name: 'action', type: 'String', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'timestamp', type: 'DateTime', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'setting_id', type: 'int', isNullable: true, isAutoIncrement: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_setting_audits_setting_id', columns: ['setting_id'], referencedTable: 'settings', referencedColumns: ['id'])]),
      TableDefinition(name: 'posts', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true), ColumnDefinition(name: 'title', type: 'String', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'author_id', type: 'int', isNullable: true, isAutoIncrement: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_posts_author_id', columns: ['author_id'], referencedTable: 'users', referencedColumns: ['id'])]),
      TableDefinition(name: 'users', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false)], primaryKey: ['id'], foreignKeys: []),
      TableDefinition(name: 'comments', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'post_id', type: 'int', isNullable: true, isAutoIncrement: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_comments_post_id', columns: ['post_id'], referencedTable: 'posts', referencedColumns: ['id'])]),
      TableDefinition(name: 'settings', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true), ColumnDefinition(name: 'key', type: 'String', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'value', type: 'String', isNullable: true, isAutoIncrement: false)], primaryKey: ['id'], foreignKeys: []),
    ]));

    final postRepository = PostRepositoryImpl(databaseMysqlDb, sharedContext);
    final commentRepository = CommentRepositoryImpl(databaseMysqlDb, sharedContext);

    // Initialize sqlite_db
    final pluginSqliteDb = SqlitePlugin();
    final dbConfigSqliteDb = (await DatabaseConfig.load(databasesPath)).firstWhere((c) => c.name == 'sqlite_db');
    final connConfigSqliteDb = (await ConnectionConfig.load(connectionsPath)).firstWhere((c) => c.name == 'sqlite_db');
    final databaseSqliteDb = await pluginSqliteDb.createDatabase(dbConfigSqliteDb, connConfigSqliteDb);
    Databases.register('sqlite_db', databaseSqliteDb);

    databaseSqliteDb.connection.schemaManager.setSchema(const SchemaDefinition(tables: [
      TableDefinition(name: 'roles', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'user_id', type: 'int', isNullable: true, isAutoIncrement: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_roles_user_id', columns: ['user_id'], referencedTable: 'users', referencedColumns: ['id'])]),
      TableDefinition(name: 'setting_audits', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true), ColumnDefinition(name: 'action', type: 'String', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'timestamp', type: 'DateTime', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'setting_id', type: 'int', isNullable: true, isAutoIncrement: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_setting_audits_setting_id', columns: ['setting_id'], referencedTable: 'settings', referencedColumns: ['id'])]),
      TableDefinition(name: 'posts', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true), ColumnDefinition(name: 'title', type: 'String', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'author_id', type: 'int', isNullable: true, isAutoIncrement: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_posts_author_id', columns: ['author_id'], referencedTable: 'users', referencedColumns: ['id'])]),
      TableDefinition(name: 'users', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false)], primaryKey: ['id'], foreignKeys: []),
      TableDefinition(name: 'comments', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'post_id', type: 'int', isNullable: true, isAutoIncrement: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_comments_post_id', columns: ['post_id'], referencedTable: 'posts', referencedColumns: ['id'])]),
      TableDefinition(name: 'settings', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true), ColumnDefinition(name: 'key', type: 'String', isNullable: true, isAutoIncrement: false), ColumnDefinition(name: 'value', type: 'String', isNullable: true, isAutoIncrement: false)], primaryKey: ['id'], foreignKeys: []),
    ]));

    final settingRepository = SettingRepositoryImpl(databaseSqliteDb, sharedContext);
    final settingAuditRepository = SettingAuditRepositoryImpl(databaseSqliteDb, sharedContext);

    // Register all repositories
    sharedContext.registerForEntity<User>(userRepository);
    RepositoryRegistry.register<UserRepository>(userRepository);
    RepositoryRegistry.registerForEntity<User>(userRepository);
    sharedContext.registerForEntity<Role>(roleRepository);
    RepositoryRegistry.register<RoleRepository>(roleRepository);
    RepositoryRegistry.registerForEntity<Role>(roleRepository);
    sharedContext.registerForEntity<Post>(postRepository);
    RepositoryRegistry.register<PostRepository>(postRepository);
    RepositoryRegistry.registerForEntity<Post>(postRepository);
    sharedContext.registerForEntity<Comment>(commentRepository);
    RepositoryRegistry.register<CommentRepository>(commentRepository);
    RepositoryRegistry.registerForEntity<Comment>(commentRepository);
    sharedContext.registerForEntity<Setting>(settingRepository);
    RepositoryRegistry.register<SettingRepository>(settingRepository);
    RepositoryRegistry.registerForEntity<Setting>(settingRepository);
    sharedContext.registerForEntity<SettingAudit>(settingAuditRepository);
    RepositoryRegistry.register<SettingAuditRepository>(settingAuditRepository);
    RepositoryRegistry.registerForEntity<SettingAudit>(settingAuditRepository);
  }
}
