// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:datapod_api/datapod_api.dart';
import 'package:postgres/postgres.dart' as pg;
import 'postgres_schema.dart';
import 'postgres_transaction.dart';

class PostgresConnection implements DatabaseConnection {
  final pg.Connection _connection;
  late final PostgresSchemaManager _schemaManager;

  PostgresConnection(this._connection) {
    _schemaManager = PostgresSchemaManager(this);
  }

  @override
  Future<QueryResult> execute(String sql,
      [Map<String, dynamic>? params]) async {
    try {
      final paramRegex = RegExp(r'@([a-zA-Z0-9_]+)');
      final usedParams =
          paramRegex.allMatches(sql).map((m) => m.group(1)).toSet();
      final filteredParams = params != null
          ? Map.fromEntries(
              params.entries.where((e) => usedParams.contains(e.key)))
          : null;

      final result = filteredParams != null && filteredParams.isNotEmpty
          ? await _connection.execute(pg.Sql.named(sql),
              parameters: filteredParams)
          : await _connection.execute(sql);

      dynamic lastId;
      if (sql.toUpperCase().contains('RETURNING')) {
        lastId = result.isNotEmpty ? result.first[0] : null;
      }

      return QueryResult(
        rows: result.map((row) => row.toColumnMap()).toList(),
        affectedRows: result.affectedRows,
        lastInsertId: lastId,
      );
    } catch (e) {
      throw QueryException('Postgres Error: $e', sql: sql, cause: e);
    }
  }

  @override
  Future<Transaction> beginTransaction() async {
    await execute('BEGIN');
    return PostgresTransaction(
      () => execute('COMMIT'),
      () => execute('ROLLBACK'),
    );
  }

  @override
  Future<void> close() => _connection.close();

  @override
  SchemaManager get schemaManager => _schemaManager;

  pg.Connection get rawConnection => _connection;
}
