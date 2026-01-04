// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'dart:io';
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

    // Initialize postgres_db
    final pluginPostgresDb = PostgresPlugin();
    final dbConfigPostgresDb = (await DatabaseConfig.load(databasesPath)).firstWhere((c) => c.name == 'postgres_db');
    final connConfigPostgresDb = (await ConnectionConfig.load(connectionsPath)).firstWhere((c) => c.name == 'postgres_db');
    final databasePostgresDb = await pluginPostgresDb.createDatabase(dbConfigPostgresDb, connConfigPostgresDb);

    databasePostgresDb.connection.schemaManager.setSchema(const SchemaDefinition(tables: [
      TableDefinition(name: 'roles', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'user_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_roles_user_id', columns: ['user_id'], referencedTable: 'users', referencedColumns: ['id'])], uniqueConstraints: []),
      TableDefinition(name: 'setting_audits', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'action', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'timestamp', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'setting_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_setting_audits_setting_id', columns: ['setting_id'], referencedTable: 'settings', referencedColumns: ['id'])], uniqueConstraints: []),
      TableDefinition(name: 'posts', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'title', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'status', type: 'PostStatus', isNullable: true, isAutoIncrement: false, enumValues: ['draft', 'published', 'archived'], isJson: false, isList: false), ColumnDefinition(name: 'metadata', type: 'Map<String, dynamic>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: false), ColumnDefinition(name: 'tags', type: 'List<String>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: true), ColumnDefinition(name: 'author_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_posts_author_id', columns: ['author_id'], referencedTable: 'users', referencedColumns: ['id'])], uniqueConstraints: []),
      TableDefinition(name: 'users', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: []),
      TableDefinition(name: 'comments', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'post_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_comments_post_id', columns: ['post_id'], referencedTable: 'posts', referencedColumns: ['id'])], uniqueConstraints: []),
      TableDefinition(name: 'settings', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'key', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'value', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: []),
    ]));

    final userRepositoryOps = UserRepositoryOperationsImpl(databasePostgresDb, sharedContext);
    final userRepositoryMapper = UserMapperImpl();
    final userRepository = UserRepositoryImpl(databasePostgresDb, userRepositoryOps, userRepositoryMapper, sharedContext);
    sharedContext.registerOperations<User, int>(userRepositoryOps);
    sharedContext.registerMapper<User>(userRepositoryMapper);
    final roleRepositoryOps = RoleRepositoryOperationsImpl(databasePostgresDb, sharedContext);
    final roleRepositoryMapper = RoleMapperImpl();
    final roleRepository = RoleRepositoryImpl(databasePostgresDb, roleRepositoryOps, roleRepositoryMapper, sharedContext);
    sharedContext.registerOperations<Role, int>(roleRepositoryOps);
    sharedContext.registerMapper<Role>(roleRepositoryMapper);

    // Initialize mysql_db
    final pluginMysqlDb = MySqlPlugin();
    final dbConfigMysqlDb = (await DatabaseConfig.load(databasesPath)).firstWhere((c) => c.name == 'mysql_db');
    final connConfigMysqlDb = (await ConnectionConfig.load(connectionsPath)).firstWhere((c) => c.name == 'mysql_db');
    final databaseMysqlDb = await pluginMysqlDb.createDatabase(dbConfigMysqlDb, connConfigMysqlDb);

    databaseMysqlDb.connection.schemaManager.setSchema(const SchemaDefinition(tables: [
      TableDefinition(name: 'roles', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'user_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_roles_user_id', columns: ['user_id'], referencedTable: 'users', referencedColumns: ['id'])], uniqueConstraints: []),
      TableDefinition(name: 'setting_audits', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'action', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'timestamp', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'setting_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_setting_audits_setting_id', columns: ['setting_id'], referencedTable: 'settings', referencedColumns: ['id'])], uniqueConstraints: []),
      TableDefinition(name: 'posts', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'title', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'status', type: 'PostStatus', isNullable: true, isAutoIncrement: false, enumValues: ['draft', 'published', 'archived'], isJson: false, isList: false), ColumnDefinition(name: 'metadata', type: 'Map<String, dynamic>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: false), ColumnDefinition(name: 'tags', type: 'List<String>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: true), ColumnDefinition(name: 'author_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_posts_author_id', columns: ['author_id'], referencedTable: 'users', referencedColumns: ['id'])], uniqueConstraints: []),
      TableDefinition(name: 'users', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: []),
      TableDefinition(name: 'comments', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'post_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_comments_post_id', columns: ['post_id'], referencedTable: 'posts', referencedColumns: ['id'])], uniqueConstraints: []),
      TableDefinition(name: 'settings', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'key', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'value', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: []),
    ]));

    final postRepositoryOps = PostRepositoryOperationsImpl(databaseMysqlDb, sharedContext);
    final postRepositoryMapper = PostMapperImpl();
    final postRepository = PostRepositoryImpl(databaseMysqlDb, postRepositoryOps, postRepositoryMapper, sharedContext);
    sharedContext.registerOperations<Post, int>(postRepositoryOps);
    sharedContext.registerMapper<Post>(postRepositoryMapper);
    final commentRepositoryOps = CommentRepositoryOperationsImpl(databaseMysqlDb, sharedContext);
    final commentRepositoryMapper = CommentMapperImpl();
    final commentRepository = CommentRepositoryImpl(databaseMysqlDb, commentRepositoryOps, commentRepositoryMapper, sharedContext);
    sharedContext.registerOperations<Comment, int>(commentRepositoryOps);
    sharedContext.registerMapper<Comment>(commentRepositoryMapper);

    // Initialize sqlite_db
    final pluginSqliteDb = SqlitePlugin();
    final dbConfigSqliteDb = (await DatabaseConfig.load(databasesPath)).firstWhere((c) => c.name == 'sqlite_db');
    final connConfigSqliteDb = (await ConnectionConfig.load(connectionsPath)).firstWhere((c) => c.name == 'sqlite_db');
    final databaseSqliteDb = await pluginSqliteDb.createDatabase(dbConfigSqliteDb, connConfigSqliteDb);

    databaseSqliteDb.connection.schemaManager.setSchema(const SchemaDefinition(tables: [
      TableDefinition(name: 'roles', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'user_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_roles_user_id', columns: ['user_id'], referencedTable: 'users', referencedColumns: ['id'])], uniqueConstraints: []),
      TableDefinition(name: 'setting_audits', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'action', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'timestamp', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'setting_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_setting_audits_setting_id', columns: ['setting_id'], referencedTable: 'settings', referencedColumns: ['id'])], uniqueConstraints: []),
      TableDefinition(name: 'posts', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'title', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'status', type: 'PostStatus', isNullable: true, isAutoIncrement: false, enumValues: ['draft', 'published', 'archived'], isJson: false, isList: false), ColumnDefinition(name: 'metadata', type: 'Map<String, dynamic>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: false), ColumnDefinition(name: 'tags', type: 'List<String>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: true), ColumnDefinition(name: 'author_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_posts_author_id', columns: ['author_id'], referencedTable: 'users', referencedColumns: ['id'])], uniqueConstraints: []),
      TableDefinition(name: 'users', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: []),
      TableDefinition(name: 'comments', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'post_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_comments_post_id', columns: ['post_id'], referencedTable: 'posts', referencedColumns: ['id'])], uniqueConstraints: []),
      TableDefinition(name: 'settings', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'key', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'value', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: []),
    ]));

    final settingRepositoryOps = SettingRepositoryOperationsImpl(databaseSqliteDb, sharedContext);
    final settingRepositoryMapper = SettingMapperImpl();
    final settingRepository = SettingRepositoryImpl(databaseSqliteDb, settingRepositoryOps, settingRepositoryMapper, sharedContext);
    sharedContext.registerOperations<Setting, int>(settingRepositoryOps);
    sharedContext.registerMapper<Setting>(settingRepositoryMapper);
    final settingAuditRepositoryOps = SettingAuditRepositoryOperationsImpl(databaseSqliteDb, sharedContext);
    final settingAuditRepositoryMapper = SettingAuditMapperImpl();
    final settingAuditRepository = SettingAuditRepositoryImpl(databaseSqliteDb, settingAuditRepositoryOps, settingAuditRepositoryMapper, sharedContext);
    sharedContext.registerOperations<SettingAudit, int>(settingAuditRepositoryOps);
    sharedContext.registerMapper<SettingAudit>(settingAuditRepositoryMapper);

    // Initialize memory_db
    final pluginMemoryDb = MemoryPlugin();
    final dbConfigMemoryDb = (await DatabaseConfig.load(databasesPath)).firstWhere((c) => c.name == 'memory_db');
    final connConfigMemoryDb = (await ConnectionConfig.load(connectionsPath)).firstWhere((c) => c.name == 'memory_db');
    final databaseMemoryDb = await pluginMemoryDb.createDatabase(dbConfigMemoryDb, connConfigMemoryDb);

    databaseMemoryDb.connection.schemaManager.setSchema(const SchemaDefinition(tables: [
      TableDefinition(name: 'roles', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'user_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_roles_user_id', columns: ['user_id'], referencedTable: 'users', referencedColumns: ['id'])], uniqueConstraints: []),
      TableDefinition(name: 'setting_audits', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'action', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'timestamp', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'setting_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_setting_audits_setting_id', columns: ['setting_id'], referencedTable: 'settings', referencedColumns: ['id'])], uniqueConstraints: []),
      TableDefinition(name: 'posts', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'title', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'status', type: 'PostStatus', isNullable: true, isAutoIncrement: false, enumValues: ['draft', 'published', 'archived'], isJson: false, isList: false), ColumnDefinition(name: 'metadata', type: 'Map<String, dynamic>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: false), ColumnDefinition(name: 'tags', type: 'List<String>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: true), ColumnDefinition(name: 'author_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_posts_author_id', columns: ['author_id'], referencedTable: 'users', referencedColumns: ['id'])], uniqueConstraints: []),
      TableDefinition(name: 'users', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: []),
      TableDefinition(name: 'comments', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'content', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'post_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_comments_post_id', columns: ['post_id'], referencedTable: 'posts', referencedColumns: ['id'])], uniqueConstraints: []),
      TableDefinition(name: 'settings', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'key', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'value', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: []),
    ]));


    return DatapodContext(
      postgresDb: databasePostgresDb,
      mysqlDb: databaseMysqlDb,
      sqliteDb: databaseSqliteDb,
      memoryDb: databaseMemoryDb,
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
  final DatapodDatabase postgresDb;
  final DatapodDatabase mysqlDb;
  final DatapodDatabase sqliteDb;
  final DatapodDatabase memoryDb;
  final UserRepository userRepository;
  final RoleRepository roleRepository;
  final PostRepository postRepository;
  final CommentRepository commentRepository;
  final SettingRepository settingRepository;
  final SettingAuditRepository settingAuditRepository;

  DatapodContext({
    required this.postgresDb,
    required this.mysqlDb,
    required this.sqliteDb,
    required this.memoryDb,
    required this.userRepository,
    required this.roleRepository,
    required this.postRepository,
    required this.commentRepository,
    required this.settingRepository,
    required this.settingAuditRepository,
  });

  Future<void> close() async {
    await postgresDb.close();
    await mysqlDb.close();
    await sqliteDb.close();
    await memoryDb.close();
  }
}
