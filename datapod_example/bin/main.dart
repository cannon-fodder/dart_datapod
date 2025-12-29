// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:datapod_core/datapod_core.dart';
import 'package:datapod_engine/datapod_engine.dart';
import 'package:datapod_postgres/datapod_postgres.dart';
import 'package:datapod_example/entities/user.dart';
import 'package:datapod_example/entities/post.dart';
import 'package:datapod_example/repositories/user_repository.dart';
import 'package:datapod_example/repositories/post_repository.dart';

void main() async {
  print('--- Datapod ORM Example ---');

  // 1. Initialize Database Connection (Directly for now)
  final dbConfig = DatabaseConfig(
      name: 'datapod', plugin: 'datapod_postgres', connection: 'datapod');
  final connConfig = ConnectionConfig(name: 'datapod', attributes: {
    'host': 'localhost',
    'port': 5432,
    'username': 'datapod',
    'password': 'datapod_dba',
    'database': 'datapod',
  });

  final plugin = PostgresPlugin();
  final database =
      await plugin.createDatabase(dbConfig, connConfig) as DatapodDatabaseBase;

  // 2. Register Repositories
  final userRepo = UserRepositoryImpl(database);
  final postRepo = PostRepositoryImpl(database);
  database.registerRepository<UserRepository>(userRepo);
  database.registerRepository<PostRepository>(postRepo);
  database.registerEntityRepository<User>(userRepo);
  database.registerEntityRepository<Post>(postRepo);

  try {
    // 3. Setup Schema (Manual for now)
    print('Dropping existing tables...');
    await database.connection.execute('DROP TABLE IF EXISTS posts');
    await database.connection.execute('DROP TABLE IF EXISTS users');

    print('Creating tables...');
    await database.connection.execute('''
      CREATE TABLE users (
        id SERIAL PRIMARY KEY,
        name TEXT
      )
    ''');
    await database.connection.execute('''
      CREATE TABLE posts (
        id SERIAL PRIMARY KEY,
        title TEXT,
        content TEXT,
        author_id INTEGER REFERENCES users(id)
      )
    ''');

    // 4. Test Persistence
    print('\nCreating User...');
    final user = ManagedUser()..name = 'Alice';

    final savedUser = await database.repository<UserRepository>().save(user);
    print('Saved User: ${savedUser.name} (ID: ${savedUser.id})');

    print('\nCreating Posts...');
    final post1 = ManagedPost()
      ..title = 'Hello Datapod'
      ..content = 'This is my first post'
      ..authorId = savedUser.id;

    final post2 = ManagedPost()
      ..title = 'Relationships'
      ..content = 'Lazy loading is cool'
      ..authorId = savedUser.id;

    await database.repository<PostRepository>().save(post1);
    await database.repository<PostRepository>().save(post2);
    print('Saved 2 posts for User ${savedUser.id}');

    // 5. Test Lazy Loading (ManyToOne)
    print('\nTesting Lazy Loading (Post -> Author)...');
    final fetchedPost =
        await database.repository<PostRepository>().findById(post1.id!);
    if (fetchedPost != null) {
      print('Fetched Post: ${fetchedPost.title}');
      final author = await fetchedPost.author;
      print('Author name: ${author?.name}');
    }

    // 6. Test Lazy Loading (OneToMany)
    print('\nTesting Lazy Loading (User -> Posts)...');
    final fetchedUser =
        await database.repository<UserRepository>().findById(savedUser.id!);
    if (fetchedUser != null) {
      print('Fetched User: ${fetchedUser.name}');
      final posts = await fetchedUser.posts;
      print('Number of posts: ${posts?.length}');
      for (final p in posts ?? []) {
        print(' - ${p.title}');
      }
    }

    // 8. Test DSL Queries
    print('\nTesting DSL Queries...');
    final alice = await userRepo.findByName('Alice');
    print('findByName(\'Alice\'): ${alice?.name} (ID: ${alice?.id})');

    final datapodPosts = await postRepo.findByTitleContains('Datapod');
    print('findByTitleContains(\'Datapod\'): ${datapodPosts.length} posts');
    for (final p in datapodPosts) {
      print(' - ${p.title}');
    }

    final postCount = await postRepo.countByTitle('Relationships');
    print('countByTitle(\'Relationships\'): $postCount');

    // 9. Test Cascading Save
    print('\nTesting Cascading Save...');
    final bob = ManagedUser()
      ..name = 'Bob'
      ..posts = Future.value([
        ManagedPost()
          ..title = 'Bob\'s First Post'
          ..content = 'Hello from Bob!',
        ManagedPost()
          ..title = 'Bob\'s Second Post'
          ..content = 'Scaling Datapod',
      ]);

    await userRepo.save(bob);
    print('Saved Bob and his posts via cascading.');

    final bobPosts = await bob.posts;
    print('Bob\'s posts in DB: ${bobPosts?.length}');
    for (final p in bobPosts ?? []) {
      print(' - ${p.title} (ID: ${p.id}, Author ID: ${p.authorId})');
    }

    // 10. Test Cascading Delete
    print('\nTesting Cascading Delete...');
    await userRepo.delete(bob.id!);
    print('Deleted Bob (Cascading should have deleted his posts).');

    final bobPostsAfterDelete = await postRepo.findByAuthorId(bob.id!);
    print('Bob\'s posts after delete: ${bobPostsAfterDelete.length}');
  } finally {
    await database.close();
    print('\nDone.');
  }
}
