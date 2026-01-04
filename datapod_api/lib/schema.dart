// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

/// Interface for schema management and migrations.
abstract interface class SchemaManager {
  /// Sets the desired schema for the database.
  void setSchema(SchemaDefinition schema);

  /// Initializes the schema based on entity definitions.
  Future<void> initializeSchema();

  /// Migrates the schema to the latest version.
  Future<void> migrateSchema();

  /// Inspects the current database schema.
  Future<List<TableMetadata>> getTables();
}

/// Represents the desired state of the database schema.
class SchemaDefinition {
  final List<TableDefinition> tables;

  const SchemaDefinition({required this.tables});
}

/// Represents the desired state of a database table.
class TableDefinition {
  final String name;
  final List<ColumnDefinition> columns;
  final List<String> primaryKey;
  final List<ForeignKeyDefinition> foreignKeys;
  final List<UniqueConstraintDefinition> uniqueConstraints;

  const TableDefinition({
    required this.name,
    required this.columns,
    this.primaryKey = const [],
    this.foreignKeys = const [],
    this.uniqueConstraints = const [],
  });
}

/// Represents a unique constraint definition.
class UniqueConstraintDefinition {
  final String name;
  final List<String> columns;

  const UniqueConstraintDefinition({
    required this.name,
    required this.columns,
  });
}

/// Represents the desired state of a database column.
class ColumnDefinition {
  final String name;
  final String type;
  final bool isNullable;
  final bool isAutoIncrement;
  final String? defaultValue;
  final List<String>? enumValues;
  final bool isJson;
  final bool isList;

  const ColumnDefinition({
    required this.name,
    required this.type,
    this.isNullable = true,
    this.isAutoIncrement = false,
    this.defaultValue,
    this.enumValues,
    this.isJson = false,
    this.isList = false,
  });
}

/// Represents a foreign key constraint.
class ForeignKeyDefinition {
  final String name;
  final List<String> columns;
  final String referencedTable;
  final List<String> referencedColumns;
  final String? onUpdate;
  final String? onDelete;

  const ForeignKeyDefinition({
    required this.name,
    required this.columns,
    required this.referencedTable,
    required this.referencedColumns,
    this.onUpdate,
    this.onDelete,
  });
}

/// Metadata about a database table (current state).
class TableMetadata {
  final String name;
  final List<ColumnMetadata> columns;

  const TableMetadata(this.name, this.columns);
}

/// Metadata about a database column (current state).
class ColumnMetadata {
  final String name;
  final String type;
  final bool isNullable;
  final bool isPrimaryKey;
  final bool isAutoIncrement;

  const ColumnMetadata({
    required this.name,
    required this.type,
    this.isNullable = true,
    this.isPrimaryKey = false,
    this.isAutoIncrement = false,
  });
}
