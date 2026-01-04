// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'dart:io';
import 'package:datapod_api/datapod_api.dart';
import 'package:datapod_engine/datapod_engine.dart';
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
import 'package:datapod_example/plugins/memory_plugin.dart';

class DatapodInitializer {
  static Future<DatapodContext> initialize({
    String databasesPath = 'databases.yaml',
    String connectionsPath = 'connections.yaml',
  }) async {
    final databasesFile = File(databasesPath);
    final connectionsFile = File(connectionsPath);

    if (!await databasesFile.exists()) {
      throw ConfigurationException('databases.yaml not found at $databasesPath');
    }
    if (!await connectionsFile.exists()) {
      throw ConfigurationException('connections.yaml not found at $connectionsPath');
    }

    final sharedContext = RelationshipContextImpl();

    // Initialize identity_db
    final pluginIdentityDb = PostgresPlugin();
    final dbConfigIdentityDb = (await DatabaseConfig.load(databasesPath)).firstWhere((c) => c.name == 'identity_db');
    final connConfigIdentityDb = (await ConnectionConfig.load(connectionsPath)).firstWhere((c) => c.name == 'identity_db');
    final databaseIdentityDb = await pluginIdentityDb.createDatabase(dbConfigIdentityDb, connConfigIdentityDb);

    databaseIdentityDb.connection.schemaManager.setSchema(const SchemaDefinition(tables: [
      TableDefinition(name: 'roles', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'user_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_roles_user_id', columns: ['user_id'], referencedTable: 'users', referencedColumns: ['id'])], uniqueConstraints: [], indexes: []),
      TableDefinition(name: 'setting_audits', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'action', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'timestamp', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'setting_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_setting_audits_setting_id', columns: ['setting_id'], referencedTable: 'settings', referencedColumns: ['id'])], uniqueConstraints: [], indexes: []),
      TableDefinition(name: 'posts', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'title', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'reading_time', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'created_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'updated_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'status', type: 'PostStatus', isNullable: true, isAutoIncrement: false, enumValues: ['draft', 'published', 'archived'], isJson: false, isList: false), ColumnDefinition(name: 'metadata', type: 'Map<String, dynamic>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: false), ColumnDefinition(name: 'tags', type: 'List<String>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: true), ColumnDefinition(name: 'author_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_posts_author_id', columns: ['author_id'], referencedTable: 'users', referencedColumns: ['id'])], uniqueConstraints: [], indexes: [IndexDefinition(name: 'idx_posts_title', columns: ['title'], unique: false)]),
      TableDefinition(name: 'users', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'created_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'updated_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: [UniqueConstraintDefinition(name: 'uidx_users_name', columns: ['name'])], indexes: [IndexDefinition(name: 'idx_users_name', columns: ['name'], unique: false)]),
      TableDefinition(name: 'comments', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'post_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_comments_post_id', columns: ['post_id'], referencedTable: 'posts', referencedColumns: ['id'])], uniqueConstraints: [], indexes: []),
      TableDefinition(name: 'settings', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'key', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'value', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: [], indexes: []),
    ]));

    final userRepositoryOps = UserRepositoryOperationsImpl(databaseIdentityDb, sharedContext);
    final userRepositoryMapper = UserMapperImpl();
    final userRepository = UserRepositoryImpl(databaseIdentityDb, userRepositoryOps, userRepositoryMapper, sharedContext);
    sharedContext.registerOperations<User, int>(userRepositoryOps);
    sharedContext.registerMapper<User>(userRepositoryMapper);
    final roleRepositoryOps = RoleRepositoryOperationsImpl(databaseIdentityDb, sharedContext);
    final roleRepositoryMapper = RoleMapperImpl();
    final roleRepository = RoleRepositoryImpl(databaseIdentityDb, roleRepositoryOps, roleRepositoryMapper, sharedContext);
    sharedContext.registerOperations<Role, int>(roleRepositoryOps);
    sharedContext.registerMapper<Role>(roleRepositoryMapper);

    // Initialize content_db
    final pluginContentDb = MySqlPlugin();
    final dbConfigContentDb = (await DatabaseConfig.load(databasesPath)).firstWhere((c) => c.name == 'content_db');
    final connConfigContentDb = (await ConnectionConfig.load(connectionsPath)).firstWhere((c) => c.name == 'content_db');
    final databaseContentDb = await pluginContentDb.createDatabase(dbConfigContentDb, connConfigContentDb);

    databaseContentDb.connection.schemaManager.setSchema(const SchemaDefinition(tables: [
      TableDefinition(name: 'roles', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'user_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_roles_user_id', columns: ['user_id'], referencedTable: 'users', referencedColumns: ['id'])], uniqueConstraints: [], indexes: []),
      TableDefinition(name: 'setting_audits', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'action', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'timestamp', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'setting_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_setting_audits_setting_id', columns: ['setting_id'], referencedTable: 'settings', referencedColumns: ['id'])], uniqueConstraints: [], indexes: []),
      TableDefinition(name: 'posts', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'title', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'reading_time', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'created_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'updated_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'status', type: 'PostStatus', isNullable: true, isAutoIncrement: false, enumValues: ['draft', 'published', 'archived'], isJson: false, isList: false), ColumnDefinition(name: 'metadata', type: 'Map<String, dynamic>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: false), ColumnDefinition(name: 'tags', type: 'List<String>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: true), ColumnDefinition(name: 'author_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_posts_author_id', columns: ['author_id'], referencedTable: 'users', referencedColumns: ['id'])], uniqueConstraints: [], indexes: [IndexDefinition(name: 'idx_posts_title', columns: ['title'], unique: false)]),
      TableDefinition(name: 'users', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'created_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'updated_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: [UniqueConstraintDefinition(name: 'uidx_users_name', columns: ['name'])], indexes: [IndexDefinition(name: 'idx_users_name', columns: ['name'], unique: false)]),
      TableDefinition(name: 'comments', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'post_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_comments_post_id', columns: ['post_id'], referencedTable: 'posts', referencedColumns: ['id'])], uniqueConstraints: [], indexes: []),
      TableDefinition(name: 'settings', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'key', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'value', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: [], indexes: []),
    ]));

    final postRepositoryOps = PostRepositoryOperationsImpl(databaseContentDb, sharedContext);
    final postRepositoryMapper = PostMapperImpl();
    final postRepository = PostRepositoryImpl(databaseContentDb, postRepositoryOps, postRepositoryMapper, sharedContext);
    sharedContext.registerOperations<Post, int>(postRepositoryOps);
    sharedContext.registerMapper<Post>(postRepositoryMapper);
    final commentRepositoryOps = CommentRepositoryOperationsImpl(databaseContentDb, sharedContext);
    final commentRepositoryMapper = CommentMapperImpl();
    final commentRepository = CommentRepositoryImpl(databaseContentDb, commentRepositoryOps, commentRepositoryMapper, sharedContext);
    sharedContext.registerOperations<Comment, int>(commentRepositoryOps);
    sharedContext.registerMapper<Comment>(commentRepositoryMapper);

    // Initialize config_db
    final pluginConfigDb = SqlitePlugin();
    final dbConfigConfigDb = (await DatabaseConfig.load(databasesPath)).firstWhere((c) => c.name == 'config_db');
    final connConfigConfigDb = (await ConnectionConfig.load(connectionsPath)).firstWhere((c) => c.name == 'config_db');
    final databaseConfigDb = await pluginConfigDb.createDatabase(dbConfigConfigDb, connConfigConfigDb);

    databaseConfigDb.connection.schemaManager.setSchema(const SchemaDefinition(tables: [
      TableDefinition(name: 'roles', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'user_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_roles_user_id', columns: ['user_id'], referencedTable: 'users', referencedColumns: ['id'])], uniqueConstraints: [], indexes: []),
      TableDefinition(name: 'setting_audits', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'action', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'timestamp', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'setting_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_setting_audits_setting_id', columns: ['setting_id'], referencedTable: 'settings', referencedColumns: ['id'])], uniqueConstraints: [], indexes: []),
      TableDefinition(name: 'posts', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'title', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'reading_time', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'created_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'updated_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'status', type: 'PostStatus', isNullable: true, isAutoIncrement: false, enumValues: ['draft', 'published', 'archived'], isJson: false, isList: false), ColumnDefinition(name: 'metadata', type: 'Map<String, dynamic>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: false), ColumnDefinition(name: 'tags', type: 'List<String>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: true), ColumnDefinition(name: 'author_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_posts_author_id', columns: ['author_id'], referencedTable: 'users', referencedColumns: ['id'])], uniqueConstraints: [], indexes: [IndexDefinition(name: 'idx_posts_title', columns: ['title'], unique: false)]),
      TableDefinition(name: 'users', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'created_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'updated_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: [UniqueConstraintDefinition(name: 'uidx_users_name', columns: ['name'])], indexes: [IndexDefinition(name: 'idx_users_name', columns: ['name'], unique: false)]),
      TableDefinition(name: 'comments', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'post_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_comments_post_id', columns: ['post_id'], referencedTable: 'posts', referencedColumns: ['id'])], uniqueConstraints: [], indexes: []),
      TableDefinition(name: 'settings', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'key', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'value', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: [], indexes: []),
    ]));

    final settingRepositoryOps = SettingRepositoryOperationsImpl(databaseConfigDb, sharedContext);
    final settingRepositoryMapper = SettingMapperImpl();
    final settingRepository = SettingRepositoryImpl(databaseConfigDb, settingRepositoryOps, settingRepositoryMapper, sharedContext);
    sharedContext.registerOperations<Setting, int>(settingRepositoryOps);
    sharedContext.registerMapper<Setting>(settingRepositoryMapper);
    final settingAuditRepositoryOps = SettingAuditRepositoryOperationsImpl(databaseConfigDb, sharedContext);
    final settingAuditRepositoryMapper = SettingAuditMapperImpl();
    final settingAuditRepository = SettingAuditRepositoryImpl(databaseConfigDb, settingAuditRepositoryOps, settingAuditRepositoryMapper, sharedContext);
    sharedContext.registerOperations<SettingAudit, int>(settingAuditRepositoryOps);
    sharedContext.registerMapper<SettingAudit>(settingAuditRepositoryMapper);

    // Initialize cache_db
    final pluginCacheDb = MemoryPlugin();
    final dbConfigCacheDb = (await DatabaseConfig.load(databasesPath)).firstWhere((c) => c.name == 'cache_db');
    final connConfigCacheDb = (await ConnectionConfig.load(connectionsPath)).firstWhere((c) => c.name == 'cache_db');
    final databaseCacheDb = await pluginCacheDb.createDatabase(dbConfigCacheDb, connConfigCacheDb);

    databaseCacheDb.connection.schemaManager.setSchema(const SchemaDefinition(tables: [
      TableDefinition(name: 'roles', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'user_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_roles_user_id', columns: ['user_id'], referencedTable: 'users', referencedColumns: ['id'])], uniqueConstraints: [], indexes: []),
      TableDefinition(name: 'setting_audits', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'action', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'timestamp', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'setting_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_setting_audits_setting_id', columns: ['setting_id'], referencedTable: 'settings', referencedColumns: ['id'])], uniqueConstraints: [], indexes: []),
      TableDefinition(name: 'posts', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'title', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'reading_time', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'created_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'updated_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'status', type: 'PostStatus', isNullable: true, isAutoIncrement: false, enumValues: ['draft', 'published', 'archived'], isJson: false, isList: false), ColumnDefinition(name: 'metadata', type: 'Map<String, dynamic>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: false), ColumnDefinition(name: 'tags', type: 'List<String>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: true), ColumnDefinition(name: 'author_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_posts_author_id', columns: ['author_id'], referencedTable: 'users', referencedColumns: ['id'])], uniqueConstraints: [], indexes: [IndexDefinition(name: 'idx_posts_title', columns: ['title'], unique: false)]),
      TableDefinition(name: 'users', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'created_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'updated_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: [UniqueConstraintDefinition(name: 'uidx_users_name', columns: ['name'])], indexes: [IndexDefinition(name: 'idx_users_name', columns: ['name'], unique: false)]),
      TableDefinition(name: 'comments', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'post_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_comments_post_id', columns: ['post_id'], referencedTable: 'posts', referencedColumns: ['id'])], uniqueConstraints: [], indexes: []),
      TableDefinition(name: 'settings', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'key', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'value', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: [], indexes: []),
    ]));


    return DatapodContext(
      identityDb: databaseIdentityDb,
      contentDb: databaseContentDb,
      configDb: databaseConfigDb,
      cacheDb: databaseCacheDb,
      userRepository: userRepository,
      roleRepository: roleRepository,
      postRepository: postRepository,
      commentRepository: commentRepository,
      settingRepository: settingRepository,
      settingAuditRepository: settingAuditRepository,
    );
  }
}

class DatapodContext {
  final DatapodDatabase identityDb;
  final DatapodDatabase contentDb;
  final DatapodDatabase configDb;
  final DatapodDatabase cacheDb;
  final UserRepository userRepository;
  final RoleRepository roleRepository;
  final PostRepository postRepository;
  final CommentRepository commentRepository;
  final SettingRepository settingRepository;
  final SettingAuditRepository settingAuditRepository;

  DatapodContext({
    required this.identityDb,
    required this.contentDb,
    required this.configDb,
    required this.cacheDb,
    required this.userRepository,
    required this.roleRepository,
    required this.postRepository,
    required this.commentRepository,
    required this.settingRepository,
    required this.settingAuditRepository,
  });

  Future<void> close() async {
    await identityDb.close();
    await contentDb.close();
    await configDb.close();
    await cacheDb.close();
  }
}
