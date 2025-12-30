// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:datapod_api/datapod_api.dart';
import 'package:datapod_core/datapod_core.dart';
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
    final plugin_postgres_db = SqlitePlugin();
    final dbConfig_postgres_db = (await DatabaseConfig.load(databasesPath)).firstWhere((c) => c.name == 'postgres_db');
    final connConfig_postgres_db = (await ConnectionConfig.load(connectionsPath)).firstWhere((c) => c.name == 'postgres_db');
    final database_postgres_db = await plugin_postgres_db.createDatabase(dbConfig_postgres_db, connConfig_postgres_db);
    Databases.register('postgres_db', database_postgres_db);

    final userRepository = UserRepositoryImpl(database_postgres_db, sharedContext);
    final roleRepository = RoleRepositoryImpl(database_postgres_db, sharedContext);

    // Initialize mysql_db
    final plugin_mysql_db = SqlitePlugin();
    final dbConfig_mysql_db = (await DatabaseConfig.load(databasesPath)).firstWhere((c) => c.name == 'mysql_db');
    final connConfig_mysql_db = (await ConnectionConfig.load(connectionsPath)).firstWhere((c) => c.name == 'mysql_db');
    final database_mysql_db = await plugin_mysql_db.createDatabase(dbConfig_mysql_db, connConfig_mysql_db);
    Databases.register('mysql_db', database_mysql_db);

    final postRepository = PostRepositoryImpl(database_mysql_db, sharedContext);
    final commentRepository = CommentRepositoryImpl(database_mysql_db, sharedContext);

    // Initialize sqlite_db
    final plugin_sqlite_db = SqlitePlugin();
    final dbConfig_sqlite_db = (await DatabaseConfig.load(databasesPath)).firstWhere((c) => c.name == 'sqlite_db');
    final connConfig_sqlite_db = (await ConnectionConfig.load(connectionsPath)).firstWhere((c) => c.name == 'sqlite_db');
    final database_sqlite_db = await plugin_sqlite_db.createDatabase(dbConfig_sqlite_db, connConfig_sqlite_db);
    Databases.register('sqlite_db', database_sqlite_db);

    final settingRepository = SettingRepositoryImpl(database_sqlite_db, sharedContext);
    final settingAuditRepository = SettingAuditRepositoryImpl(database_sqlite_db, sharedContext);

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
