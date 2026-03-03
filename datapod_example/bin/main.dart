// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:logging/logging.dart';
import 'package:datapod_api/datapod_api.dart';
import 'package:datapod_example/entities/user.dart';
import 'package:datapod_example/entities/post.dart';
import 'package:datapod_example/entities/setting.dart';
import 'package:datapod_example/entities/role.dart';
import 'package:datapod_example/entities/comment.dart';
import 'package:datapod_example/entities/setting_audit.dart';
import 'package:datapod_example/entities/user_profile.dart';
import 'package:datapod_example/datapod_init.dart';

void main(List<String> args) async {
  // Configure logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print(
      '${record.time} [${record.level.name}] ${record.loggerName}: ${record.message}',
    );
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
    final identityDb = context.identityDb;
    final contentDb = context.contentDb;
    final configDb = context.configDb;

    await identityDb.connection.execute('DROP TABLE IF EXISTS roles CASCADE');
    await identityDb.connection.execute(
      'DROP TABLE IF EXISTS user_profiles CASCADE',
    );
    await identityDb.connection.execute('DROP TABLE IF EXISTS users CASCADE');
    await contentDb.connection.execute('DROP TABLE IF EXISTS comments');
    await contentDb.connection.execute('DROP TABLE IF EXISTS posts');
    await configDb.connection.execute('DROP TABLE IF EXISTS setting_audits');
    await configDb.connection.execute('DROP TABLE IF EXISTS settings');

    print('Initializing schemas via SchemaManager...');
    await identityDb.schemaManager.initializeSchema();
    await contentDb.schemaManager.initializeSchema();
    await configDb.schemaManager.initializeSchema();

    // In a real cross-database scenario, physical FKs across DB servers don't exist.
    // We'll drop the physical FK in MySQL that points to a table in Postgres.
    try {
      await contentDb.connection.execute(
        'ALTER TABLE posts DROP FOREIGN KEY fk_posts_author_id',
      );
    } catch (_) {
      // Ignore if it fails (e.g. if it wasn't created)
    }

    // 4. Exercise Identity (Postgres -> Identity DB)
    print(
      '\n[IDENTITY] Creating User with Roles & Profile in Identity DB (Transaction)...',
    );
    var alice = User()..name = 'Alice';
    final aliceProfile = UserProfile()
      ..bio = 'ORM enthusiast'
      ..website = 'https://example.com/alice';

    // Demonstrate Transaction
    alice = await identityDb.transactionManager.runInTransaction(() async {
      final savedUser = await userRepo.save(alice);
      aliceProfile.user = Future.value(savedUser);
      final savedProfile = await context.userProfileRepository.save(
        aliceProfile,
      );
      savedUser.profile = Future.value(savedProfile);
      return await userRepo.save(savedUser);
    });

    final adminRole = Role()..name = 'ADMIN';
    final userRole = Role()..name = 'USER';
    alice.roles = Future.value([adminRole, userRole]);
    alice = await userRepo.save(alice);

    print('Saved User: ${alice.name} with profile and roles');
    final profile = await alice.profile;
    print('  - Bio: ${profile?.bio}');
    print('  - Website: ${profile?.website}');

    // 5. Exercise Content (MySQL -> Content DB)
    print(
      '\n[CONTENT] Creating Post with Comments in Content DB (related to Identity User)...',
    );
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
    print('Saved post: ${post1.title} with status ${post1.status}');

    // Demonstrate Update
    print('\n[CONTENT] Demonstrating Entity Update...');
    post1.status = PostStatus.archived;
    post1 = await postRepo.save(post1);
    print('Updated post "${post1.title}" status to: ${post1.status}');

    // Demonstrate Bulk Insert
    print('\n[CONTENT] Demonstrating Bulk Insert (saveAll)...');
    final posts = await postRepo.saveAll([
      Post()
        ..title = 'Scaling Dart'
        ..author = Future.value(alice)
        ..status = PostStatus.published,
      Post()
        ..title = 'Microservices vs Monolith'
        ..author = Future.value(alice)
        ..status = PostStatus.draft,
    ]);
    print('Bulk saved ${posts.length} additional posts.');

    // 6. Exercise Config (SQLite -> Config DB)
    print('\n[CONFIG] Creating Settings with Audits in Config DB...');
    var themeSetting = Setting()
      ..key = 'ui.theme'
      ..value = 'dark';

    final audit1 = SettingAudit()
      ..action = 'Created setting'
      ..timestamp = DateTime.now();
    themeSetting.auditTrail = Future.value([audit1]);

    themeSetting = await settingRepo.save(themeSetting);
    print('Saved settings with audit trail to Config DB.');

    // 7. Verify cross-database lazy loading
    print(
      '\n[VERIFICATION] Testing Lazy Loading (Content DB Post -> Identity DB Author)...',
    );
    final fetchedPost = await postRepo.findById(post1.id!);
    if (fetchedPost != null) {
      final author = await fetchedPost.author;
      print(
        'Post "${fetchedPost.title}" author from Identity DB: ${author?.name}',
      );

      // Verify One-to-One reverse lookup
      final authorProfile = await author?.profile;
      print('  - Author Bio: ${authorProfile?.bio}');
    }

    // 8. Advanced Queries & Pagination
    print('\n[QUERIES] Demonstrating Advanced DSL & Pagination...');
    final postCount = await postRepo.countByAuthor(alice.id!);
    print('Total posts by Alice: $postCount');

    final exists = await postRepo.existsByTitle('Scaling Dart');
    print('Does "Scaling Dart" exist? $exists');

    final longPosts = await postRepo.findByReadingTimeGreaterThan(
      const Duration(minutes: 10),
    );
    print('Posts longer than 10 mins: ${longPosts.length}');

    print(
      '\n[PAGINATION] Requesting first page of posts (size 2, sort by title DESC)...',
    );
    final page = await postRepo.findAllPaged(
      Pageable(page: 0, size: 2, sort: [Sort('title', Direction.desc)]),
    );
    print('Page 1 of ${page.totalPages}:');
    for (var p in page.items) {
      print('  - ${p.title}');
    }

    // 9. Deletion & Cascade
    print('\n[CASCADE] Deleting User and verifying cascades...');
    final userId = alice.id!;
    await userRepo.delete(userId);
    final deletedUser = await userRepo.findById(userId);
    print('User deleted: ${deletedUser == null}');

    // Verify profile is also deleted (CascadeType.all)
    final profileId = profile?.id;
    if (profileId != null) {
      final deletedProfile = await context.userProfileRepository.findById(
        profileId,
      );
      print('Profile deleted via cascade: ${deletedProfile == null}');
    }

    // 10. Exercise Memory DB (Custom Plugin)
    print('\n[MEMORY] Using custom MemoryPlugin (Cache DB)...');
    final cacheDb = context.cacheDb;
    await cacheDb.connection.execute(
      'INSERT INTO test (id, info) VALUES (@id, @info)',
      {'id': 1, 'info': 'Found in memory!'},
    );
    final memResult = await cacheDb.connection.execute(
      'SELECT * FROM test WHERE id = @id',
      {'id': 1},
    );
    if (memResult.isNotEmpty) {
      print('Retrieved from Cache DB: ${memResult.rows.first['info']}');
    }

    // 11. Exercise Streams (Identity DB)
    print('\n[STREAM] Using Stream-based queries...');
    await userRepo.save(User()..name = 'Bob');
    await userRepo.save(User()..name = 'Charlie');

    print('Streaming users with "a" in their name:');
    final userStream = userRepo.findByNameContaining('a');
    await for (final user in userStream) {
      print('  - Emitted user: ${user.name}');
    }

    print('\nDone with functional operations.');
  } catch (e, s) {
    print('Error: $e');
    print(s);
  } finally {
    await context.close();
    print('\nExample finished.');
  }
}
