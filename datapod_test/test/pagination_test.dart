// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

import 'package:test/test.dart';
import 'package:datapod_api/datapod_api.dart';
import 'package:datapod_test/datapod_init.dart';
import 'package:datapod_test/test_entities.dart';
import 'package:datapod_test/repositories/test_entity_repository.dart';

void main() {
  late DatapodContext context;

  setUpAll(() async {
    context = await DatapodInitializer.initialize(
      databasesPath: 'databases.yaml',
      connectionsPath: 'connections.yaml',
    );

    // Initialize schemas
    await context.postgresTest.connection.schemaManager.initializeSchema();
    await context.mysqlTest.connection.schemaManager.initializeSchema();
  });

  tearDownAll(() async {
    await context.close();
  });

  group('Pagination & Sorting', () {
    test('PostgreSQL Pagination', () async {
      final repo = context.testEntityRepository;
      await context.postgresTest.connection
          .execute('DELETE FROM test_entities');

      // Create 50 entities
      for (var i = 1; i <= 50; i++) {
        await repo.save(TestEntity()
          ..name = 'Entity ${i.toString().padLeft(2, "0")}'
          ..value = i
          ..flag = true);
      }

      // Test Page 0
      var page0 = await repo.findByNameContaining(
          'Entity', Pageable(page: 0, size: 10, sort: [Sort.asc('name')]));
      expect(page0.items.length, equals(10));
      expect(page0.totalElements, equals(50));
      expect(page0.items.first.name, equals('Entity 01'));
      expect(page0.items.last.name, equals('Entity 10'));

      // Test Page 2 (20-29)
      var page2 = await repo.findByNameContaining(
          'Entity', Pageable(page: 2, size: 10, sort: [Sort.asc('name')]));
      expect(page2.items.length, equals(10));
      expect(page2.items.first.name, equals('Entity 21'));
      expect(page2.items.last.name, equals('Entity 30'));

      // Test Sorting Desc
      var sortedDesc = await repo.findByFlagTrue([Sort.desc('value')]);
      expect(sortedDesc.first.value, equals(50));
      expect(sortedDesc.last.value, equals(1));
    });

    test('MySQL Pagination', () async {
      // Manually create MySQL repo
      final relCtx = RelationshipContextImpl();
      final mysqlRepo = TestEntityRepositoryImpl(
          context.mysqlTest,
          TestEntityRepositoryOperationsImpl(context.mysqlTest, relCtx),
          TestEntityMapperImpl(),
          relCtx);

      await context.mysqlTest.connection.execute('DELETE FROM test_entities');

      // Create 25 entities
      for (var i = 1; i <= 25; i++) {
        await mysqlRepo.save(TestEntity()
          ..name = 'MySQL ${i.toString().padLeft(2, "0")}'
          ..value = i
          ..flag = true);
      }

      // Test Page 1 (size 10 -> items 11-20)
      var page1 = await mysqlRepo.findByNameContaining(
          'MySQL', Pageable(page: 1, size: 10, sort: [Sort.asc('name')]));
      expect(page1.items.length, equals(10));
      expect(page1.totalElements, equals(25));
      expect(page1.items.first.name, equals('MySQL 11'));
      expect(page1.items.last.name, equals('MySQL 20'));
    });
  });
}
