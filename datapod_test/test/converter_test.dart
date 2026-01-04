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

    // Initialize schemas
    await context.postgresTest.connection
        .execute('DROP TABLE IF EXISTS test_entities CASCADE');
    await context.postgresTest.connection.schemaManager.initializeSchema();
  });

  tearDownAll(() async {
    await context.close();
  });

  group('Converters', () {
    test('Custom converter maps between Duration and int', () async {
      final repo = context.testEntityRepository;

      final entity = TestEntity()
        ..name = 'Converter Test'
        ..duration = const Duration(minutes: 5);

      final saved = await repo.save(entity);
      expect(saved.duration, equals(const Duration(minutes: 5)));

      // Verify it's stored as int (in milliseconds) in the database
      final result = await context.postgresTest.connection.execute(
        'SELECT duration FROM test_entities WHERE id = @id',
        {'id': saved.id},
      );
      // SQLite return int, Postgres return int, MySQL return int
      expect(result.rows.first['duration'], equals(300000));

      final found = await repo.findById(saved.id!);
      expect(found?.duration, equals(const Duration(minutes: 5)));
    });
  });
}
