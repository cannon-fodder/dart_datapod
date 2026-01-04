// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'dart:async';
import 'package:datapod_api/datapod_api.dart';
import 'package:datapod_engine/datapod_engine.dart';

@DatapodPluginDef('memory')
class MemoryPlugin implements DatapodPlugin {
  @override
  String get name => 'memory';

  @override
  Future<DatapodDatabase> createDatabase(
    DatabaseConfig dbConfig,
    ConnectionConfig connConfig,
  ) async {
    return MemoryDatabase(dbConfig.name);
  }
}

class MemoryDatabase implements DatapodDatabase {
  @override
  final String name;
  @override
  late final TransactionManager transactionManager =
      TransactionManagerImpl(connection);
  @override
  final DatabaseConnection connection = MemoryConnection();

  MemoryDatabase(this.name);

  @override
  Future<void> close() async {}
}

class MemoryConnection implements DatabaseConnection {
  final Map<String, List<Map<String, dynamic>>> _storage = {};
  int _lastInsertId = 0;

  @override
  Future<QueryResult> execute(String sql,
      [Map<String, dynamic>? params]) async {
    // Very naive SQL parsing for demo purposes
    final cleanSql = sql.trim().toUpperCase();
    if (cleanSql.startsWith('INSERT INTO')) {
      final parts = sql.split(' ');
      final tableName = parts[2].toLowerCase();
      _storage.putIfAbsent(tableName, () => []);

      final row = Map<String, dynamic>.from(params ?? {});
      if (!row.containsKey('id')) {
        row['id'] = ++_lastInsertId;
      }
      _storage[tableName]!.add(row);

      return QueryResult(
        rows: [row],
        lastInsertId: row['id'],
      );
    } else if (cleanSql.startsWith('SELECT * FROM')) {
      final parts = sql.split(' ');
      final tableName = parts[3].toLowerCase();
      var rows = _storage[tableName] ?? [];

      if (cleanSql.contains('WHERE')) {
        // Naive single column WHERE id = @id
        final wherePart = cleanSql.split('WHERE')[1].trim();
        if (wherePart.contains('ID = @ID')) {
          final id = params?['id'];
          rows = rows.where((r) => r['id'] == id).toList();
        }
      }

      return QueryResult(
        rows: rows.map((r) => Map<String, dynamic>.from(r)).toList(),
      );
    } else if (cleanSql.startsWith('DELETE FROM')) {
      final parts = sql.split(' ');
      final tableName = parts[2].toLowerCase();
      if (cleanSql.contains('WHERE ID = @ID')) {
        final id = params?['id'];
        _storage[tableName]?.removeWhere((r) => r['id'] == id);
      } else {
        _storage[tableName]?.clear();
      }
      return QueryResult(rows: []);
    }

    return QueryResult(rows: []);
  }

  @override
  Stream<Map<String, dynamic>> stream(String sql,
      [Map<String, dynamic>? params]) async* {
    final cleanSql = sql.trim().toUpperCase();
    if (cleanSql.startsWith('SELECT * FROM')) {
      final parts = sql.split(' ');
      final tableName = parts[3].toLowerCase();
      var rows = _storage[tableName] ?? [];

      if (cleanSql.contains('WHERE')) {
        final wherePart = cleanSql.split('WHERE')[1].trim();
        if (wherePart.contains('ID = @ID')) {
          final id = params?['id'];
          rows = rows.where((r) => r['id'] == id).toList();
        }
      }

      for (final row in rows) {
        yield Map<String, dynamic>.from(row);
      }
    }
  }

  @override
  Future<Transaction> beginTransaction() async {
    return TransactionImpl(this);
  }

  @override
  Future<void> close() async {}

  @override
  SchemaManager get schemaManager => MemorySchemaManager();
}

class MemorySchemaManager implements SchemaManager {
  @override
  void setSchema(SchemaDefinition schema) {}

  @override
  Future<void> initializeSchema() async {}

  @override
  Future<void> migrateSchema() async {}

  @override
  Future<List<TableMetadata>> getTables() async => [];
}

class TransactionManagerImpl implements TransactionManager {
  final DatabaseConnection _connection;
  TransactionManagerImpl(this._connection);

  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) async {
    return await action();
  }

  @override
  Future<Transaction> beginTransaction() async {
    return TransactionImpl(_connection);
  }
}

class TransactionImpl implements Transaction {
  final DatabaseConnection connection;
  TransactionImpl(this.connection);

  @override
  Future<void> commit() async {}
  @override
  Future<void> rollback() async {}

  @override
  Future<void> createSavepoint(String name) async {}
  @override
  Future<void> releaseSavepoint(String name) async {}
  @override
  Future<void> rollbackToSavepoint(String name) async {}
}
