// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:logging/logging.dart';
import 'package:datapod_example/entities/user.dart';
import 'package:datapod_example/entities/post.dart';
import 'package:datapod_example/entities/setting.dart';
import 'package:datapod_example/entities/role.dart';
import 'package:datapod_example/entities/comment.dart';
import 'package:datapod_example/entities/setting_audit.dart';
import 'package:datapod_example/datapod_init.dart';

void main(List<String> args) async {
  // Configure logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print(
        '${record.time} [${record.level.name}] ${record.loggerName}: ${record.message}');
  });

  print('--- Datapod ORM Enterprise Demo ---');

  // 1. Initialize Datapod (Functional databases from YAML)
  final context = await DatapodInitializer.initialize();

  final userRepo = context.userRepository;
  final postRepo = context.postRepository;
  final settingRepo = context.settingRepository;

  try {
    // 2. Setup Schemas
    print('Dropping existing tables...');
    final postgresDb = context.postgresDb;
    final mysqlDb = context.mysqlDb;
    final sqliteDb = context.sqliteDb;

    await postgresDb.connection.execute('DROP TABLE IF EXISTS roles CASCADE');
    await postgresDb.connection.execute('DROP TABLE IF EXISTS users CASCADE');
    await mysqlDb.connection.execute('DROP TABLE IF EXISTS comments');
    await mysqlDb.connection.execute('DROP TABLE IF EXISTS posts');
    await sqliteDb.connection.execute('DROP TABLE IF EXISTS setting_audits');
    await sqliteDb.connection.execute('DROP TABLE IF EXISTS settings');

    print('Initializing schemas via SchemaManager...');
    await postgresDb.connection.schemaManager.initializeSchema();
    await mysqlDb.connection.schemaManager.initializeSchema();
    await sqliteDb.connection.schemaManager.initializeSchema();

    // In a real cross-database scenario, physical FKs across DB servers don't exist.
    // We'll drop the physical FK in MySQL that points to a table in Postgres.
    try {
      await mysqlDb.connection
          .execute('ALTER TABLE posts DROP FOREIGN KEY fk_posts_author_id');
    } catch (_) {
      // Ignore if it fails (e.g. if it wasn't created)
    }

    // 3. Exercise Identity (Postgres)
    print('\n[IDENTITY] Creating User with Roles in PostgreSQL...');
    var alice = User()..name = 'Alice';
    final adminRole = Role()..name = 'ADMIN';
    final userRole = Role()..name = 'USER';
    alice.roles = Future.value([adminRole, userRole]);

    alice = await userRepo.save(alice);
    print('Saved User: ${alice.name} with roles');
    print('  - Created at: ${alice.createdAt}');
    print('  - Updated at: ${alice.updatedAt}');

    // 4. Exercise Content (MySQL)
    print(
        '\n[CONTENT] Creating Post with Comments in MySQL (related to Postgres User)...');
    var post1 = Post()
      ..title = 'Enterprise Architecture'
      ..readingTime = const Duration(minutes: 15)
      ..content = 'Using multiple databases for different functions.'
      ..status = PostStatus.published
      ..metadata = {'version': '1.0', 'priority': 'high'}
      ..tags = ['architecture', 'orm', 'dart']
      ..author = Future.value(alice);

    final comment1 = Comment()..content = 'Great insight!';
    final comment2 = Comment()..content = 'Very useful for scaling.';
    post1.comments = Future.value([comment1, comment2]);

    post1 = await postRepo.save(post1);
    print(
        'Saved post: ${post1.title} with status ${post1.status}, metadata ${post1.metadata}, and tags ${post1.tags}');
    print('  - Reading time: ${post1.readingTime}');
    print('  - Created at: ${post1.createdAt}');
    print('  - Updated at: ${post1.updatedAt}');

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
      print(
          '  - Status: ${fetchedPost.status}, Metadata: ${fetchedPost.metadata}, Tags: ${fetchedPost.tags}');
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

    // 8. Exercise Memory DB (Custom Plugin)
    print('\n[MEMORY] Using custom MemoryPlugin...');
    final memoryDb = context.memoryDb;
    // We can use the connection directly for raw operations on the custom plugin
    await memoryDb.connection.execute(
        'INSERT INTO test (id, info) VALUES (@id, @info)',
        {'id': 1, 'info': 'Found in memory!'});
    final memResult = await memoryDb.connection
        .execute('SELECT * FROM test WHERE id = @id', {'id': 1});
    if (memResult.isNotEmpty) {
      print('Retrieved from Memory DB: ${memResult.rows.first['info']}');
    }

    // 9. Exercise Streams (Postgres)
    print('\n[STREAM] Using Stream-based queries...');
    await userRepo.save(User()..name = 'Bob');
    await userRepo.save(User()..name = 'Charlie');
    await userRepo.save(User()..name = 'Alice in Wonderland');

    print('Streaming users with "Ali" in their name:');
    final userStream = userRepo.findByNameContaining('Ali');
    await for (final user in userStream) {
      print('  - Emitted user: ${user.name}');
    }

    // 10. Performance check (just log)
    print('\nDone with functional operations.');
  } catch (e, s) {
    print('Error: $e');
    print(s);
  } finally {
    await context.close();
    print('\nExample finished.');
  }
}
