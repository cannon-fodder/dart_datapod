// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:datapod_api/datapod_api.dart';
import 'postgres_connection.dart';

class PostgresSchemaManager implements SchemaManager {
  final PostgresConnection _connection;

  PostgresSchemaManager(this._connection);

  @override
  Future<void> initializeSchema() async {
    // TODO: Implementation
  }

  @override
  Future<void> migrateSchema() async {
    // TODO: Implementation
  }

  @override
  Future<List<TableMetadata>> getTables() async {
    final result = await _connection.execute(
        "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'");

    final tables = <TableMetadata>[];
    for (final row in result.rows) {
      final tableName = row['table_name'] as String;
      final columns = await _getColumns(tableName);
      tables.add(TableMetadata(tableName, columns));
    }
    return tables;
  }

  Future<List<ColumnMetadata>> _getColumns(String tableName) async {
    final result = await _connection.execute(
      "SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_name = @table",
      {'table': tableName},
    );

    return result.rows.map((row) {
      return ColumnMetadata(
        name: row['column_name'] as String,
        type: row['data_type'] as String,
        isNullable: row['is_nullable'] == 'YES',
        // In PostgreSQL, primary key detection is more complex, typically via pg_index
        isPrimaryKey: false, // TODO: Implement PK detection
      );
    }).toList();
  }
}
