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
import 'package:datapod_test/repositories/unique_entity_repository.dart';
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
        .execute('DROP TABLE IF EXISTS unique_entities CASCADE');
    await context.postgresTest.connection
        .execute('DROP TABLE IF EXISTS test_entities CASCADE');
    await context.postgresTest.schemaManager.initializeSchema();

    print('Initializing MySQL schema...');
    await context.mysqlTest.connection
        .execute('DROP TABLE IF EXISTS unique_entities');
    await context.mysqlTest.connection
        .execute('DROP TABLE IF EXISTS test_entities');
    await context.mysqlTest.schemaManager.initializeSchema();
  });

  tearDownAll(() async {
    await context.close();
  });

  group('PostgreSQL Integration', () {
    setUp(() async {
      await context.postgresTest.connection
          .execute('DELETE FROM test_entities');
    });

    test('CRUD for TestEntity', () async {
      final repo = context.testEntityRepository;

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

    group('Transactions', () {
      test('runInTransaction commits on success', () async {
        final repo = context.testEntityRepository;
        final name = 'Trans Success ${DateTime.now().millisecondsSinceEpoch}';

        await context.postgresTest.transactionManager
            .runInTransaction(() async {
          await repo.save(TestEntity()..name = name);
          final inside = await repo.findByName(name);
          expect(inside, isNotNull);
        });

        final outside = await repo.findByName(name);
        expect(outside, isNotNull);
      });

      test('runInTransaction rolls back on error', () async {
        final repo = context.testEntityRepository;
        final name = 'Trans Rollback ${DateTime.now().millisecondsSinceEpoch}';

        try {
          await context.postgresTest.transactionManager
              .runInTransaction(() async {
            await repo.save(TestEntity()..name = name);
            throw Exception('Rollback please');
          });
        } catch (_) {}

        final outside = await repo.findByName(name);
        expect(outside, isNull);
      });

      test('Nested transactions use savepoints', () async {
        final repo = context.testEntityRepository;
        final outerName = 'Outer ${DateTime.now().millisecondsSinceEpoch}';
        final innerName = 'Inner ${DateTime.now().millisecondsSinceEpoch}';

        await context.postgresTest.transactionManager
            .runInTransaction(() async {
          await repo.save(TestEntity()..name = outerName);

          try {
            await context.postgresTest.transactionManager
                .runInTransaction(() async {
              await repo.save(TestEntity()..name = innerName);
              throw Exception('Inner rollback');
            });
          } catch (_) {}

          final innerInOuter = await repo.findByName(innerName);
          expect(innerInOuter, isNull, reason: 'Inner should be rolled back');

          final outerInOuter = await repo.findByName(outerName);
          expect(outerInOuter, isNotNull);
        });

        final outerOutside = await repo.findByName(outerName);
        expect(outerOutside, isNotNull, reason: 'Outer should be committed');
      });

      test('Manual transaction control', () async {
        final name = 'Manual Trans ${DateTime.now().millisecondsSinceEpoch}';

        final trans =
            await context.postgresTest.transactionManager.beginTransaction();
        // Since we are not in a Zone with this transaction, we'd need to pass it to the repo
        // But our repo uses the global context. For manual control to work with repositories,
        // we might need to expose a way to use a specific connection/transaction.
        // However, the current implementation of runInTransaction uses Zones.
        // Let's test if we can use it via runZoned if we wanted to, or just test the raw connection.

        await context.postgresTest.connection.execute(
            'INSERT INTO test_entities (name, value, rating, flag, type, created_at) VALUES (@name, 0, 0, false, 0, NOW())',
            {'name': name});
        await trans.rollback();

        final result = await context.postgresTest.connection.execute(
            'SELECT * FROM test_entities WHERE name = @name', {'name': name});
        expect(result, isEmpty);

        final trans2 =
            await context.postgresTest.transactionManager.beginTransaction();
        await context.postgresTest.connection.execute(
            'INSERT INTO test_entities (name, value, rating, flag, type, created_at) VALUES (@name, 0, 0, false, 0, NOW())',
            {'name': name});
        await trans2.commit();

        final result2 = await context.postgresTest.connection.execute(
            'SELECT * FROM test_entities WHERE name = @name', {'name': name});
        expect(result2.rows, isNotEmpty);
      });
    });

    group('Unique Constraints', () {
      setUp(() async {
        await context.postgresTest.connection
            .execute('DELETE FROM unique_entities');
      });

      test('Field-level unique constraint', () async {
        final repo = context.uniqueEntityRepository;
        await repo.save(UniqueEntity()
          ..code = 'U1'
          ..folder = 'f1'
          ..filename = 'file1');

        // Second insert with same code should fail
        expect(
          () => repo.save(UniqueEntity()
            ..code = 'U1'
            ..folder = 'f2'
            ..filename = 'file2'),
          throwsA(isA<QueryException>()),
        );
      });

      test('Composite unique constraint', () async {
        final repo = context.uniqueEntityRepository;
        await repo.save(UniqueEntity()
          ..code = 'U1'
          ..folder = 'same'
          ..filename = 'same');

        // Different folder/same name is OK
        await repo.save(UniqueEntity()
          ..code = 'U2'
          ..folder = 'other'
          ..filename = 'same');

        // Same folder/same name should fail
        expect(
          () => repo.save(UniqueEntity()
            ..code = 'U3'
            ..folder = 'same'
            ..filename = 'same'),
          throwsA(isA<QueryException>()),
        );
      });
    });
  });

  group('MySQL Integration', () {
    setUp(() async {
      await context.mysqlTest.connection.execute('DELETE FROM test_entities');
    });

    test('CRUD for TestEntity', () async {
      // We need a repository pointing to MySQL
      // In the generated init, testEntityRepository is using databasePostgresTest.
      // We can manually create one for MySQL for testing or update generator to provide both.
      // For now, let's manually create it.
      final relCtx = RelationshipContextImpl();
      final mysqlRepo = TestEntityRepositoryImpl(
          context.mysqlTest,
          TestEntityRepositoryOperationsImpl(context.mysqlTest, relCtx),
          TestEntityMapperImpl(),
          relCtx);

      // CREATE
      var entity = TestEntity()
        ..name = 'MySQL Test ${DateTime.now().millisecondsSinceEpoch}'
        ..value = 100
        ..rating = 3.14
        ..flag = false
        ..createdAt = DateTime.now()
        ..type = TestEnum.gamma
        ..data = {'mysql': 'is awesome'}
        ..tags = ['mysql', 'db'];

      final saved = await mysqlRepo.save(entity);
      expect(saved.id, isNotNull);
      expect(saved.name, startsWith('MySQL Test'));
      expect(saved.type, equals(TestEnum.gamma));

      // READ
      final found = await mysqlRepo.findById(saved.id!);
      expect(found, isNotNull);
      expect(found!.name, startsWith('MySQL Test'));
      expect(found.type, equals(TestEnum.gamma));
      expect(found.data?['mysql'], equals('is awesome'));
      expect(found.tags, equals(['mysql', 'db']));

      // UPDATE
      found.name = 'Updated MySQL ${DateTime.now().millisecondsSinceEpoch}';
      final updated = await mysqlRepo.save(found);
      expect(updated.name, startsWith('Updated MySQL'));

      // DELETE
      await mysqlRepo.delete(updated.id!);
      final foundDeleted = await mysqlRepo.findById(saved.id!);
      expect(foundDeleted, isNull);
    });

    group('Transactions', () {
      late TestEntityRepository mysqlRepo;
      setUp(() async {
        await context.mysqlTest.connection.execute('DELETE FROM test_entities');
        final relCtx = RelationshipContextImpl();
        mysqlRepo = TestEntityRepositoryImpl(
            context.mysqlTest,
            TestEntityRepositoryOperationsImpl(context.mysqlTest, relCtx),
            TestEntityMapperImpl(),
            relCtx);
      });

      test('runInTransaction commits on success', () async {
        final name =
            'MySQL Trans Success ${DateTime.now().millisecondsSinceEpoch}';

        await context.mysqlTest.transactionManager.runInTransaction(() async {
          await mysqlRepo.save(TestEntity()..name = name);
          final inside = await mysqlRepo.findByName(name);
          expect(inside, isNotNull);
        });

        final outside = await mysqlRepo.findByName(name);
        expect(outside, isNotNull);
      });

      test('runInTransaction rolls back on error', () async {
        final name =
            'MySQL Trans Rollback ${DateTime.now().millisecondsSinceEpoch}';

        try {
          await context.mysqlTest.transactionManager.runInTransaction(() async {
            await mysqlRepo.save(TestEntity()..name = name);
            throw Exception('Rollback please');
          });
        } catch (_) {}

        final outside = await mysqlRepo.findByName(name);
        expect(outside, isNull);
      });

      test('Nested transactions use savepoints', () async {
        final outerName = 'Outer ${DateTime.now().millisecondsSinceEpoch}';
        final innerName = 'Inner ${DateTime.now().millisecondsSinceEpoch}';

        await context.mysqlTest.transactionManager.runInTransaction(() async {
          await mysqlRepo.save(TestEntity()..name = outerName);

          try {
            await context.mysqlTest.transactionManager
                .runInTransaction(() async {
              await mysqlRepo.save(TestEntity()..name = innerName);
              throw Exception('Inner rollback');
            });
          } catch (_) {}

          final innerInOuter = await mysqlRepo.findByName(innerName);
          expect(innerInOuter, isNull, reason: 'Inner should be rolled back');

          final outerInOuter = await mysqlRepo.findByName(outerName);
          expect(outerInOuter, isNotNull);
        });

        final outerOutside = await mysqlRepo.findByName(outerName);
        expect(outerOutside, isNotNull, reason: 'Outer should be committed');
      });

      test('Manual transaction control', () async {
        final name =
            'Manual MySQL Trans ${DateTime.now().millisecondsSinceEpoch}';

        final trans =
            await context.mysqlTest.transactionManager.beginTransaction();
        await context.mysqlTest.connection.execute(
            "INSERT INTO test_entities (name, value, rating, flag, type, created_at) VALUES (@name, 0, 0, false, 'alpha', NOW())",
            {'name': name});
        await trans.rollback();

        final result = await context.mysqlTest.connection.execute(
            'SELECT * FROM test_entities WHERE name = @name', {'name': name});
        expect(result, isEmpty);

        final trans2 =
            await context.mysqlTest.transactionManager.beginTransaction();
        await context.mysqlTest.connection.execute(
            "INSERT INTO test_entities (name, value, rating, flag, type, created_at) VALUES (@name, 0, 0, false, 'alpha', NOW())",
            {'name': name});
        await trans2.commit();

        final result2 = await context.mysqlTest.connection.execute(
            'SELECT * FROM test_entities WHERE name = @name', {'name': name});
        expect(result2.rows, isNotEmpty);
      });
    });

    group('Unique Constraints', () {
      late UniqueEntityRepository mysqlUniqueRepo;
      setUp(() async {
        await context.mysqlTest.connection
            .execute('DELETE FROM unique_entities');
        final relCtx = RelationshipContextImpl();
        mysqlUniqueRepo = UniqueEntityRepositoryImpl(
            context.mysqlTest,
            UniqueEntityRepositoryOperationsImpl(context.mysqlTest, relCtx),
            UniqueEntityMapperImpl(),
            relCtx);
      });

      test('Field-level unique constraint', () async {
        await mysqlUniqueRepo.save(UniqueEntity()
          ..code = 'U1'
          ..folder = 'f1'
          ..filename = 'file1');

        // Second insert with same code should fail
        expect(
          () => mysqlUniqueRepo.save(UniqueEntity()
            ..code = 'U1'
            ..folder = 'f2'
            ..filename = 'file2'),
          throwsA(isA<QueryException>()),
        );
      });

      test('Composite unique constraint', () async {
        await mysqlUniqueRepo.save(UniqueEntity()
          ..code = 'U1'
          ..folder = 'same'
          ..filename = 'same');

        // Different folder/same name is OK
        await mysqlUniqueRepo.save(UniqueEntity()
          ..code = 'U2'
          ..folder = 'other'
          ..filename = 'same');

        // Same folder/same name should fail
        expect(
          () => mysqlUniqueRepo.save(UniqueEntity()
            ..code = 'U3'
            ..folder = 'same'
            ..filename = 'same'),
          throwsA(isA<QueryException>()),
        );
      });
    });
  });
}
