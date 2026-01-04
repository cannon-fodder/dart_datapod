// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:test/test.dart';
import 'package:datapod_test/datapod_init.dart';
import 'package:datapod_test/test_entities.dart';

void main() {
  late DatapodContext context;

  setUpAll(() async {
    context = await DatapodInitializer.initialize(
      databasesPath: 'databases.yaml',
      connectionsPath: 'connections.yaml',
    );

    // Initialize schemas (will also create columns for auditing)
    await context.postgresTest.connection
        .execute('DROP TABLE IF EXISTS unique_entities CASCADE');
    await context.postgresTest.connection
        .execute('DROP TABLE IF EXISTS test_entities CASCADE');
    await context.postgresTest.connection.schemaManager.initializeSchema();
  });

  tearDownAll(() async {
    await context.close();
  });

  group('Auditing', () {
    test('CreatedAt and UpdatedAt are automatically populated', () async {
      final repo = context.testEntityRepository;

      final entity = TestEntity()..name = 'Audit Test';

      final beforeSave = DateTime.now();
      final saved = await repo.save(entity);
      final afterSave = DateTime.now();

      expect(saved.createdAt, isNotNull);
      expect(saved.updatedAt, isNotNull);

      // Should be within the time range of the test
      expect(
          saved.createdAt!
              .isAfter(beforeSave.subtract(const Duration(seconds: 1))),
          isTrue);
      expect(
          saved.createdAt!.isBefore(afterSave.add(const Duration(seconds: 1))),
          isTrue);

      expect(saved.updatedAt, equals(saved.createdAt));

      // Wait a bit to ensure timestamp differs
      await Future.delayed(const Duration(milliseconds: 100));

      final beforeUpdate = DateTime.now();
      saved.name = 'Updated Audit';
      final updated = await repo.save(saved);
      final afterUpdate = DateTime.now();

      expect(updated.createdAt, equals(saved.createdAt));
      expect(
          updated.updatedAt!
              .isAfter(beforeUpdate.subtract(const Duration(seconds: 1))),
          isTrue);
      expect(
          updated.updatedAt!
              .isBefore(afterUpdate.add(const Duration(seconds: 1))),
          isTrue);
      expect(updated.updatedAt!.isAfter(updated.createdAt!), isTrue);
    });
  });
}
