// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:datapod_api/datapod_api.dart';
import 'mysql_connection.dart';

class MySqlSchemaManager implements SchemaManager {
  final MySqlConnection _connection;

  MySqlSchemaManager(this._connection);

  @override
  Future<void> initializeSchema() async {
    // TODO: Implementation for creating tables based on entities
  }

  @override
  Future<void> migrateSchema() async {
    // TODO: Implementation for schema migrations
  }

  @override
  Future<List<TableMetadata>> getTables() async {
    final result = await _connection.execute('SHOW TABLES');
    final tables = <TableMetadata>[];

    for (final row in result.rows) {
      final tableName = row.values.first as String;
      final columns = await _getColumns(tableName);
      tables.add(TableMetadata(tableName, columns));
    }

    return tables;
  }

  Future<List<ColumnMetadata>> _getColumns(String tableName) async {
    final result = await _connection.execute('DESCRIBE `$tableName`');
    return result.rows.map((row) {
      return ColumnMetadata(
        name: row['Field'] as String,
        type: row['Type'] as String,
        isNullable: row['Null'] == 'YES',
        isPrimaryKey: row['Key'] == 'PRI',
      );
    }).toList();
  }
}
