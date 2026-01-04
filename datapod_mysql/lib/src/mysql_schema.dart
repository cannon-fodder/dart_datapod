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

  SchemaDefinition? _schema;

  @override
  void setSchema(SchemaDefinition schema) {
    _schema = schema;
  }

  @override
  Future<void> initializeSchema() async {
    if (_schema == null) return;

    for (final table in _schema!.tables) {
      final columns = table.columns.map((c) {
        String type = _mapType(c);
        final autoInc = c.isAutoIncrement ? ' AUTO_INCREMENT' : '';
        final nullable = c.isNullable ? '' : ' NOT NULL';
        final pk = table.primaryKey.contains(c.name) ? ' PRIMARY KEY' : '';
        return '`${c.name}` $type$nullable$autoInc$pk';
      }).join(', ');

      await _connection
          .execute('CREATE TABLE IF NOT EXISTS `${table.name}` ($columns)');

      // Add unique constraints
      for (final unique in table.uniqueConstraints) {
        final cols = unique.columns.map((c) => '`$c`').join(', ');
        try {
          await _connection.execute(
              'ALTER TABLE `${table.name}` ADD CONSTRAINT `${unique.name}` UNIQUE ($cols)');
        } catch (_) {
          // Ignore if constraint already exists
        }
      }

      for (final fk in table.foreignKeys) {
        final fkName = fk.name;
        final cols = fk.columns.map((c) => '`$c`').join(', ');
        final refTable = fk.referencedTable;
        final refCols = fk.referencedColumns.map((c) => '`$c`').join(', ');
        final onDel = fk.onDelete != null ? ' ON DELETE ${fk.onDelete}' : '';

        try {
          await _connection.execute(
              'ALTER TABLE `${table.name}` ADD CONSTRAINT `$fkName` FOREIGN KEY ($cols) REFERENCES `$refTable` ($refCols)$onDel');
        } catch (_) {
          // Ignore if constraint already exists or other error
        }
      }
    }
  }

  String _mapType(ColumnDefinition c) {
    if (c.isJson || c.isList) {
      return 'JSON';
    }
    if (c.enumValues != null) {
      final values = c.enumValues!.map((v) => "'$v'").join(', ');
      return 'ENUM($values)';
    }
    switch (c.type) {
      case 'int':
        return 'INT';
      case 'double':
        return 'DOUBLE';
      case 'bool':
        return 'BOOLEAN';
      case 'DateTime':
        return 'DATETIME';
      case 'String':
      default:
        return 'VARCHAR(255)';
    }
  }

  @override
  Future<void> migrateSchema() async {
    if (_schema == null) return;

    // First ensure all tables exist
    await initializeSchema();

    final existingTables = await getTables();
    for (final table in _schema!.tables) {
      final existingTable =
          existingTables.firstWhere((t) => t.name == table.name);
      final existingColumnNames =
          existingTable.columns.map((c) => c.name).toSet();

      for (final column in table.columns) {
        if (!existingColumnNames.contains(column.name)) {
          final type = _mapType(column);
          final nullable = column.isNullable ? '' : ' NOT NULL';
          await _connection.execute(
              'ALTER TABLE `${table.name}` ADD COLUMN `${column.name}` $type$nullable');
        }
      }
    }
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
