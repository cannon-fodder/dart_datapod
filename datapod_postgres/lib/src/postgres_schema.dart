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
        if (c.isAutoIncrement) {
          type = 'SERIAL';
        }
        final nullable = c.isNullable ? '' : ' NOT NULL';
        final pk = table.primaryKey.contains(c.name) ? ' PRIMARY KEY' : '';
        return '${c.name} $type$nullable$pk';
      }).join(', ');

      await _connection
          .execute('CREATE TABLE IF NOT EXISTS ${table.name} ($columns)');

      // Add unique constraints
      for (final unique in table.uniqueConstraints) {
        final cols = unique.columns.join(', ');
        try {
          await _connection.execute(
              'ALTER TABLE ${table.name} ADD CONSTRAINT ${unique.name} UNIQUE ($cols)');
        } catch (_) {
          // Ignore if constraint already exists
        }
      }

      for (final fk in table.foreignKeys) {
        final fkName = fk.name;
        final cols = fk.columns.join(', ');
        final refTable = fk.referencedTable;
        final refCols = fk.referencedColumns.join(', ');
        final onDel = fk.onDelete != null ? ' ON DELETE ${fk.onDelete}' : '';

        try {
          await _connection.execute(
              'ALTER TABLE ${table.name} ADD CONSTRAINT $fkName FOREIGN KEY ($cols) REFERENCES $refTable ($refCols)$onDel');
        } catch (_) {
          // Ignore if constraint already exists
        }
      }

      // Add indexes
      for (final index in table.indexes) {
        final cols = index.columns.join(', ');
        final unique = index.unique ? 'UNIQUE ' : '';
        try {
          await _connection.execute(
              'CREATE ${unique}INDEX IF NOT EXISTS ${index.name} ON ${table.name} ($cols)');
        } catch (_) {
          // Ignore if index already exists
        }
      }
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
              'ALTER TABLE ${table.name} ADD COLUMN ${column.name} $type$nullable');
        }
      }
    }
  }

  String _mapType(ColumnDefinition c) {
    if (c.isJson || c.isList) {
      return 'JSONB';
    }
    switch (c.type) {
      case 'int':
        return 'INTEGER';
      case 'double':
        return 'DOUBLE PRECISION';
      case 'bool':
        return 'BOOLEAN';
      case 'DateTime':
        return 'TIMESTAMP';
      case 'String':
      default:
        return 'TEXT';
    }
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
    final columnsResult = await _connection.execute(
      "SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_name = @table",
      {'table': tableName},
    );

    final pkResult = await _connection.execute(
      "SELECT kcu.column_name FROM information_schema.table_constraints tc "
      "JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name AND tc.table_schema = kcu.table_schema "
      "WHERE tc.constraint_type = 'PRIMARY KEY' AND tc.table_name = @table",
      {'table': tableName},
    );

    final pkColumns =
        pkResult.rows.map((r) => r['column_name'] as String).toSet();

    return columnsResult.rows.map((row) {
      final name = row['column_name'] as String;
      return ColumnMetadata(
        name: name,
        type: row['data_type'] as String,
        isNullable: row['is_nullable'] == 'YES',
        isPrimaryKey: pkColumns.contains(name),
      );
    }).toList();
  }
}
