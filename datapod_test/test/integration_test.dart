// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:test/test.dart';
import 'package:datapod_api/datapod_api.dart';
import 'package:datapod_test/datapod_init.dart';
import 'package:datapod_test/test_entities.dart';
import 'package:datapod_test/repositories/test_entity_repository.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  late DatapodContext context;

  setUpAll(() async {
    context = await DatapodInitializer.initialize(
      databasesPath: 'databases.yaml',
      connectionsPath: 'connections.yaml',
    );

    // Initialize schemas
    print('Initializing Postgres schema...');
    await context.postgresTest.connection
        .execute('DROP TABLE IF EXISTS test_entities CASCADE');
    await context.postgresTest.connection.schemaManager.initializeSchema();

    print('Initializing MySQL schema...');
    await context.mysqlTest.connection
        .execute('DROP TABLE IF EXISTS test_entities');
    await context.mysqlTest.connection.schemaManager.initializeSchema();
  });

  tearDownAll(() async {
    await context.close();
  });

  group('PostgreSQL Integration', () {
    test('CRUD for TestEntity', () async {
      final repo = context
          .testEntityRepository; // Default points to postgres if not changed or if first

      // CREATE
      var entity = TestEntity()
        ..name = 'Postgres Test'
        ..value = 42
        ..rating = 4.5
        ..flag = true
        ..createdAt = DateTime.now()
        ..type = TestEnum.beta
        ..data = {
          'key': 'value',
          'nested': {'foo': 'bar'}
        }
        ..tags = ['a', 'b', 'c'];

      final saved = await repo.save(entity);
      expect(saved.id, isNotNull);
      expect(saved.name, equals('Postgres Test'));
      expect(saved.type, equals(TestEnum.beta));
      expect(saved.tags, containsAll(['a', 'b', 'c']));

      // READ
      final found = await repo.findById(saved.id!);
      expect(found, isNotNull);
      expect(found!.id, equals(saved.id));
      expect(found.name, equals('Postgres Test'));
      expect(found.value, equals(42));
      expect(found.rating, equals(4.5));
      expect(found.flag, isTrue);
      expect(found.type, equals(TestEnum.beta));
      expect(found.data?['nested']?['foo'], equals('bar'));
      expect(found.tags, equals(['a', 'b', 'c']));

      // UPDATE
      found.name = 'Updated Postgres';
      found.tags = ['d', 'e'];
      final updated = await repo.save(found);
      expect(updated.name, equals('Updated Postgres'));
      expect(updated.tags, equals(['d', 'e']));

      final foundUpdated = await repo.findById(saved.id!);
      expect(foundUpdated!.name, equals('Updated Postgres'));
      expect(foundUpdated.tags, equals(['d', 'e']));

      // DELETE
      await repo.delete(foundUpdated.id!);
      final foundDeleted = await repo.findById(saved.id!);
      expect(foundDeleted, isNull);
    });
  });

  group('MySQL Integration', () {
    test('CRUD for TestEntity', () async {
      // We need a repository pointing to MySQL
      // In the generated init, testEntityRepository is using databasePostgresTest.
      // We can manually create one for MySQL for testing or update generator to provide both.
      // For now, let's manually create it.
      final mysqlRepo = TestEntityRepositoryImpl(
          context.mysqlTest, RelationshipContextImpl());

      // CREATE
      var entity = TestEntity()
        ..name = 'MySQL Test'
        ..value = 100
        ..rating = 3.14
        ..flag = false
        ..createdAt = DateTime.now()
        ..type = TestEnum.gamma
        ..data = {'mysql': 'is awesome'}
        ..tags = ['mysql', 'db'];

      final saved = await mysqlRepo.save(entity);
      expect(saved.id, isNotNull);
      expect(saved.name, equals('MySQL Test'));
      expect(saved.type, equals(TestEnum.gamma));

      // READ
      final found = await mysqlRepo.findById(saved.id!);
      expect(found, isNotNull);
      expect(found!.name, equals('MySQL Test'));
      expect(found.type, equals(TestEnum.gamma));
      expect(found.data?['mysql'], equals('is awesome'));
      expect(found.tags, equals(['mysql', 'db']));

      // UPDATE
      found.name = 'Updated MySQL';
      final updated = await mysqlRepo.save(found);
      expect(updated.name, equals('Updated MySQL'));

      // DELETE
      await mysqlRepo.delete(updated.id!);
      final foundDeleted = await mysqlRepo.findById(saved.id!);
      expect(foundDeleted, isNull);
    });
  });
}
