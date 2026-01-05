// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:test/test.dart';
import 'package:datapod_postgres/datapod_postgres.dart';
import 'package:datapod_engine/datapod_engine.dart';
import 'package:datapod_api/datapod_api.dart';

// Minimal Schema for testing script generation
const testSchema = SchemaDefinition(
  tables: [
    TableDefinition(
      name: 'test_table',
      columns: [
        ColumnDefinition(
            name: 'id', type: 'int', isNullable: false, isAutoIncrement: true),
        ColumnDefinition(
            name: 'name',
            type: 'String',
            isNullable: false,
            isAutoIncrement: false),
      ],
      primaryKey: ['id'],
      foreignKeys: [],
      uniqueConstraints: [],
      indexes: [],
    ),
  ],
);

void main() {
  group('Migration Enhancements', () {
    test('Should parse migration_connection from databases.yaml', () async {
      final configs = await DatabaseConfig.load('databases.yaml');
      final dbConfig = configs.firstWhere((c) => c.name == 'migration_test_db');

      expect(dbConfig.migrationConnection, equals('migration_postgres'));
    });

    test('Should initialize database with migration connection', () async {
      final dbConfig = (await DatabaseConfig.load('databases.yaml'))
          .firstWhere((c) => c.name == 'migration_test_db');
      final connConfigs = await ConnectionConfig.load('connections.yaml');

      final mainConnConfig =
          connConfigs.firstWhere((c) => c.name == dbConfig.connection);
      final migrationConnConfig =
          connConfigs.firstWhere((c) => c.name == dbConfig.migrationConnection);

      final plugin = PostgresPlugin();
      final db = await plugin.createDatabase(dbConfig, mainConnConfig,
          migrationConnConfig: migrationConnConfig);

      expect(db.migrationConnection, isNotNull);

      // Clean up
      await db.close();
    });

    test('Should generate schema script', () async {
      final dbConfig = (await DatabaseConfig.load('databases.yaml'))
          .firstWhere((c) => c.name == 'migration_test_db');
      final connConfigs = await ConnectionConfig.load('connections.yaml');
      final mainConnConfig =
          connConfigs.firstWhere((c) => c.name == dbConfig.connection);

      // Use Postgres for script gen test
      final plugin = PostgresPlugin();

      // We don't necessarily need a real migration connection for script gen if it just uses internal logic,
      // but the plugin requires a connection to be created.
      final db = await plugin.createDatabase(dbConfig, mainConnConfig);

      db.connection.schemaManager.setSchema(testSchema);

      final script = await db.connection.schemaManager.generateSchemaScript();

      print('Generated Script:\n$script');

      expect(script, contains('CREATE TABLE IF NOT EXISTS test_table'));
      expect(script, contains('id SERIAL NOT NULL PRIMARY KEY'));
      expect(script, contains('name TEXT NOT NULL'));

      await db.close();
    });
  });
}
