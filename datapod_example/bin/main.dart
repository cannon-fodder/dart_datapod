// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:logging/logging.dart';
import 'package:datapod_core/datapod_core.dart';
import 'package:datapod_example/entities/user.dart';
import 'package:datapod_example/entities/post.dart';
import 'package:datapod_example/entities/setting.dart';
import 'package:datapod_example/entities/role.dart';
import 'package:datapod_example/entities/comment.dart';
import 'package:datapod_example/entities/setting_audit.dart';
import 'package:datapod_example/repositories/user_repository.dart';
import 'package:datapod_example/repositories/post_repository.dart';
import 'package:datapod_example/repositories/setting_repository.dart';
import 'package:datapod_example/datapod_init.dart';
import 'package:datapod_api/datapod_api.dart';

void main(List<String> args) async {
  // Configure logging
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    print(
        '${record.time} [${record.level.name}] ${record.loggerName}: ${record.message}');
  });

  print('--- Datapod ORM Enterprise Demo ---');

  // 1. Initialize Datapod (Functional databases from YAML)
  await DatapodInitializer.initialize();

  final userRepo = RepositoryRegistry.get<UserRepository>();
  final postRepo = RepositoryRegistry.get<PostRepository>();
  final settingRepo = RepositoryRegistry.get<SettingRepository>();

  try {
    // 2. Setup Schemas
    print('Dropping existing tables...');
    final postgresDb = Databases.get('postgres_db');
    final mysqlDb = Databases.get('mysql_db');
    final sqliteDb = Databases.get('sqlite_db');

    await postgresDb.connection.execute('DROP TABLE IF EXISTS roles');
    await postgresDb.connection.execute('DROP TABLE IF EXISTS users');
    await mysqlDb.connection.execute('DROP TABLE IF EXISTS comments');
    await mysqlDb.connection.execute('DROP TABLE IF EXISTS posts');
    await sqliteDb.connection.execute('DROP TABLE IF EXISTS setting_audits');
    await sqliteDb.connection.execute('DROP TABLE IF EXISTS settings');

    print('Creating tables in respective databases...');

    // Identity (Postgres)
    await postgresDb.connection.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');
    await postgresDb.connection.execute('''
      CREATE TABLE roles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        user_id INTEGER
      )
    ''');

    // Content (MySQL)
    await mysqlDb.connection.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        author_id INTEGER
      )
    ''');
    await mysqlDb.connection.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT,
        post_id INTEGER
      )
    ''');

    // Config (SQLite)
    await sqliteDb.connection.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT,
        value TEXT
      )
    ''');
    await sqliteDb.connection.execute('''
      CREATE TABLE setting_audits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT,
        timestamp TEXT,
        setting_id INTEGER
      )
    ''');

    // 3. Exercise Identity (Postgres)
    print('\n[IDENTITY] Creating User with Roles in PostgreSQL...');
    var alice = User()..name = 'Alice';
    final adminRole = Role()..name = 'ADMIN';
    final userRole = Role()..name = 'USER';
    alice.roles = Future.value([adminRole, userRole]);

    alice = await userRepo.save(alice);
    print('Saved User: ${alice.name} with roles');

    // 4. Exercise Content (MySQL)
    print(
        '\n[CONTENT] Creating Post with Comments in MySQL (related to Postgres User)...');
    var post1 = Post()
      ..title = 'Enterprise Architecture'
      ..content = 'Using multiple databases for different functions.'
      ..author = Future.value(alice);

    final comment1 = Comment()..content = 'Great insight!';
    final comment2 = Comment()..content = 'Very useful for scaling.';
    post1.comments = Future.value([comment1, comment2]);

    post1 = await postRepo.save(post1);
    print('Saved post: ${post1.title} with 2 comments');

    // 5. Exercise Config (SQLite)
    print('\n[CONFIG] Creating Settings with Audits in SQLite...');
    var themeSetting = Setting()
      ..key = 'ui.theme'
      ..value = 'dark';

    final audit1 = SettingAudit()
      ..action = 'Created setting'
      ..timestamp = DateTime.now();
    themeSetting.auditTrail = Future.value([audit1]);

    themeSetting = await settingRepo.save(themeSetting);

    var langSetting = Setting()
      ..key = 'app.language'
      ..value = 'en_US';
    langSetting = await settingRepo.save(langSetting);
    print('Saved settings with audit trail to SQLite.');

    // 6. Verify cross-database lazy loading
    print(
        '\n[VERIFICATION] Testing Lazy Loading (MySQL Post -> Postgres Author)...');
    final fetchedPost = await postRepo.findById(post1.id!);
    if (fetchedPost != null) {
      final author = await fetchedPost.author;
      print(
          'Post "${fetchedPost.title}" author from Identity DB: ${author?.name}');
    }

    // 7. Verify Config DB
    print('\n[VERIFICATION] Verifying Settings and Audits in Config DB...');
    final dbTheme = await settingRepo.findByKey('ui.theme');
    print('Found setting in SQLite: ${dbTheme?.key} = ${dbTheme?.value}');
    final audits = await dbTheme?.auditTrail;
    if (audits != null) {
      print('Audit trail count: ${audits.length}');
      for (var a in audits) {
        print('  - ${a.action} at ${a.timestamp}');
      }
    }

    // 8. Performance check (just log)
    print('\nDone with functional operations.');
  } catch (e, s) {
    print('Error: $e');
    print(s);
  } finally {
    await Databases.get('postgres_db').close();
    await Databases.get('mysql_db').close();
    await Databases.get('sqlite_db').close();
    print('\nExample finished.');
  }
}
