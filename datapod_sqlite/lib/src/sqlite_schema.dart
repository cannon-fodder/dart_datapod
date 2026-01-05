// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:datapod_api/datapod_api.dart';
import 'sqlite_connection.dart';

class SqliteSchemaManager implements SchemaManager {
  final SqliteConnection _connection;

  SqliteSchemaManager(this._connection);

  SchemaDefinition? _schema;

  @override
  void setSchema(SchemaDefinition schema) {
    _schema = schema;
  }

  @override
  Future<void> initializeSchema() async {
    if (_schema == null) return;

    for (final table in _schema!.tables) {
      final columnStrings = table.columns.map((c) {
        String type = _mapType(c);
        final pk = table.primaryKey.contains(c.name) ? ' PRIMARY KEY' : '';
        final autoInc =
            (c.isAutoIncrement && pk.isNotEmpty) ? ' AUTOINCREMENT' : '';
        final nullable = c.isNullable ? '' : ' NOT NULL';
        return '${c.name} $type$pk$autoInc$nullable';
      }).toList();

      for (final unique in table.uniqueConstraints) {
        final cols = unique.columns.join(', ');
        columnStrings.add('UNIQUE ($cols)');
      }

      for (final fk in table.foreignKeys) {
        final cols = fk.columns.join(', ');
        final refTable = fk.referencedTable;
        final refCols = fk.referencedColumns.join(', ');
        final onDel = fk.onDelete != null ? ' ON DELETE ${fk.onDelete}' : '';
        columnStrings
            .add('FOREIGN KEY ($cols) REFERENCES $refTable ($refCols)$onDel');
      }

      final columns = columnStrings.join(', ');
      await _connection
          .execute('CREATE TABLE IF NOT EXISTS ${table.name} ($columns)');

      // Add indexes
      for (final index in table.indexes) {
        final cols = index.columns.join(', ');
        final unique = index.unique ? 'UNIQUE ' : '';
        await _connection.execute(
            'CREATE ${unique}INDEX IF NOT EXISTS ${index.name} ON ${table.name} ($cols)');
      }
    }
  }

  String _mapType(ColumnDefinition c) {
    if (c.isJson || c.isList || c.enumValues != null) {
      return 'TEXT';
    }
    switch (c.type) {
      case 'int':
        return 'INTEGER';
      case 'double':
        return 'REAL';
      case 'bool':
        return 'INTEGER';
      case 'DateTime':
        return 'TEXT';
      case 'String':
      default:
        return 'TEXT';
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

  @override
  Future<List<TableMetadata>> getTables() async {
    final result = await _connection.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");

    final tables = <TableMetadata>[];
    for (final row in result.rows) {
      final tableName = row['name'] as String;
      final columns = await _getColumns(tableName);
      tables.add(TableMetadata(tableName, columns));
    }
    return tables;
  }

  Future<List<ColumnMetadata>> _getColumns(String tableName) async {
    final result = await _connection.execute("PRAGMA table_info('$tableName')");
    return result.rows.map((row) {
      return ColumnMetadata(
        name: row['name'] as String,
        type: row['type'] as String,
        isNullable: row['notnull'] == 0,
        isPrimaryKey: row['pk'] == 1,
      );
    }).toList();
  }

  @override
  Future<String> generateSchemaScript() async {
    if (_schema == null) return '';
    final buffer = StringBuffer();

    for (final table in _schema!.tables) {
      final columnStrings = table.columns.map((c) {
        String type = _mapType(c);
        final pk = table.primaryKey.contains(c.name) ? ' PRIMARY KEY' : '';
        final autoInc =
            (c.isAutoIncrement && pk.isNotEmpty) ? ' AUTOINCREMENT' : '';
        final nullable = c.isNullable ? '' : ' NOT NULL';
        return '${c.name} $type$pk$autoInc$nullable';
      }).toList();

      for (final unique in table.uniqueConstraints) {
        final cols = unique.columns.join(', ');
        columnStrings.add('UNIQUE ($cols)');
      }

      for (final fk in table.foreignKeys) {
        final cols = fk.columns.join(', ');
        final refTable = fk.referencedTable;
        final refCols = fk.referencedColumns.join(', ');
        final onDel = fk.onDelete != null ? ' ON DELETE ${fk.onDelete}' : '';
        columnStrings
            .add('FOREIGN KEY ($cols) REFERENCES $refTable ($refCols)$onDel');
      }

      final columns = columnStrings.join(', ');
      buffer.writeln('CREATE TABLE IF NOT EXISTS ${table.name} ($columns);');

      // Add indexes
      for (final index in table.indexes) {
        final cols = index.columns.join(', ');
        final unique = index.unique ? 'UNIQUE ' : '';
        buffer.writeln(
            'CREATE ${unique}INDEX IF NOT EXISTS ${index.name} ON ${table.name} ($cols);');
      }
    }

    return buffer.toString();
  }
}
