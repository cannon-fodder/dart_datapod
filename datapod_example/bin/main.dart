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
import 'package:datapod_example/repositories/user_repository.dart';
import 'package:datapod_example/repositories/post_repository.dart';
import 'package:datapod_example/datapod_init.dart';
import 'package:datapod_api/datapod_api.dart';

void main(List<String> args) async {
  // Configure logging
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    print(
        '${record.time} [${record.level.name}] ${record.loggerName}: ${record.message}');
  });

  final engine = args.isNotEmpty ? args[0].toLowerCase() : 'sqlite';
  print('--- Datapod ORM Example ($engine) ---');

  // 1. Initialize Datapod (All databases from YAML)
  await DatapodInitializer.initialize();

  // Get the database instance based on the engine argument
  // (Not used directly here anymore as we use specific DBs for the demo)
  // final dbName = '${engine}_db';
  // final database = Databases.get(dbName);

  final userRepo = RepositoryRegistry.get<UserRepository>();
  final postRepo = RepositoryRegistry.get<PostRepository>();

  try {
    // 3. Setup Schema (Manual for now)
    print('Dropping existing tables...');
    // We might need to drop tables in different databases if we are testing cross-DB.
    // For this example, we'll just drop them in the "main" database of the context.

    // In our setup:
    // User is in postgres_db
    // Post is in mysql_db
    // If we passed 'sqlite' as arg, both might fail if they are not in sqlite_db.
    // Let's make the schema setup robust.

    final postgresDb = Databases.get('postgres_db');
    final mysqlDb = Databases.get('mysql_db');
    final sqliteDb = Databases.get('sqlite_db');

    await postgresDb.connection.execute('DROP TABLE IF EXISTS users');
    await mysqlDb.connection.execute('DROP TABLE IF EXISTS posts');
    await sqliteDb.connection.execute('DROP TABLE IF EXISTS posts');
    await sqliteDb.connection.execute('DROP TABLE IF EXISTS users');

    print('Creating tables...');

    // Create users in "Postgres" (actually SQLite mock)
    await postgresDb.connection.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');

    // Create posts in "MySQL" (actually SQLite mock)
    await mysqlDb.connection.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        author_id INTEGER
      )
    ''');

    // 4. Test Persistence (Cross-Database!)
    print('\nCreating User in PostgreSQL...');
    final user = ManagedUser()..name = 'Alice';
    final savedUser = await userRepo.save(user);
    print('Saved User: ${savedUser.name} (ID: ${savedUser.id})');

    print('\nCreating Posts in MySQL (related to PostgreSQL User)...');
    final post1 = ManagedPost()
      ..title = 'Hello Cross-DB'
      ..content = 'This post is in MySQL, its author is in Postgres'
      ..authorId = savedUser.id;

    await postRepo.save(post1);
    print('Saved post 1 for User ${savedUser.id}');

    // 5. Test Lazy Loading (ManyToOne)
    print('\nTesting Lazy Loading (Post -> Author)...');
    final fetchedPost = await postRepo.findById(post1.id!);
    if (fetchedPost != null) {
      print('Fetched Post: ${fetchedPost.title}');
      final author = await fetchedPost.author;
      print('Author from PostgreSQL: ${author?.name}');
    }

    // 8. Test DSL Queries
    print('\nTesting DSL Queries...');
    final alice = await userRepo.findByName('Alice');
    print('findByName(\'Alice\'): ${alice?.name} (ID: ${alice?.id})');

    // 9. Test Cascading Save
    print('\nTesting Cascading Save (User -> Postgres, Posts -> MySQL)...');
    final bob = ManagedUser()
      ..name = 'Bob'
      ..posts = Future.value([
        ManagedPost()
          ..title = 'Bob\'s First Post'
          ..content = 'Cross-DB cascade!',
        ManagedPost()
          ..title = 'Bob\'s Second Post'
          ..content = 'It just works.',
      ]);

    await userRepo.save(bob);
    print('Saved Bob and his posts via cascading.');

    final bobPosts = await bob.posts;
    print('Bob\'s posts in MySQL: ${bobPosts?.length}');
    for (final p in bobPosts ?? []) {
      print(' - ${p.title} (ID: ${p.id}, Author ID: ${p.authorId})');
    }

    // 10. Test Cascading Delete
    print('\nTesting Cascading Delete...');
    await userRepo.delete(bob.id!);
    print(
        'Deleted Bob from Postgres (Cascading should have deleted his posts in MySQL).');

    final bobPostsAfterDelete =
        await (postRepo as dynamic).findByAuthorId(bob.id!);
    print('Bob\'s posts in MySQL after delete: ${bobPostsAfterDelete.length}');
  } catch (e, s) {
    print('Error: $e');
    print(s);
  } finally {
    // Close all
    await Databases.get('postgres_db').close();
    await Databases.get('mysql_db').close();
    await Databases.get('sqlite_db').close();
    print('\nDone.');
  }
}
