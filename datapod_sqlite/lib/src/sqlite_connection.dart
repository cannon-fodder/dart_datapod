// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:logging/logging.dart';
import 'package:datapod_api/datapod_api.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'sqlite_schema.dart';
import 'sqlite_transaction.dart';

class SqliteConnection implements DatabaseConnection {
  final sqlite.Database _db;
  late final SqliteSchemaManager _schemaManager;
  final _log = Logger('Datapod.SQLite');

  SqliteConnection(this._db) {
    _schemaManager = SqliteSchemaManager(this);
  }

  @override
  Future<QueryResult> execute(String sql,
      [Map<String, dynamic>? params]) async {
    try {
      String processedSql = sql;
      List<dynamic> positionalParams = [];

      if (params != null && params.isNotEmpty) {
        final translation = _translateSql(sql, params);
        processedSql = translation.sql;
        positionalParams = translation.params;
      } else {
        // Even without params, we might need to strip RETURNING
        processedSql = _stripReturning(sql);
      }

      final isQuery =
          processedSql.trimLeft().toLowerCase().startsWith('select') ||
              processedSql.trimLeft().toLowerCase().startsWith('pragma');

      if (_log.isLoggable(Level.FINE)) {
        _log.fine('Executing SQL: $processedSql');
        if (positionalParams.isNotEmpty) {
          _log.fine('Parameters: $positionalParams');
        }
      }

      if (positionalParams.isNotEmpty) {
        final stmt = _db.prepare(processedSql);
        try {
          if (isQuery) {
            final result = stmt.select(positionalParams);
            return QueryResult(
              rows: result
                  .map<Map<String, dynamic>>(
                      (row) => Map<String, dynamic>.from(row))
                  .toList(),
              affectedRows: _db.updatedRows,
              lastInsertId: _db.lastInsertRowId,
            );
          } else {
            stmt.execute(positionalParams);
            return QueryResult(
              affectedRows: _db.updatedRows,
              lastInsertId: _db.lastInsertRowId,
            );
          }
        } finally {
          stmt.dispose();
        }
      } else {
        if (isQuery) {
          final result = _db.select(processedSql);
          return QueryResult(
            rows: result
                .map<Map<String, dynamic>>(
                    (row) => Map<String, dynamic>.from(row))
                .toList(),
            affectedRows: _db.updatedRows,
            lastInsertId: _db.lastInsertRowId,
          );
        } else {
          _db.execute(processedSql);
          return QueryResult(
            affectedRows: _db.updatedRows,
            lastInsertId: _db.lastInsertRowId,
          );
        }
      }
    } catch (e) {
      throw QueryException('SQLite Error: $e', sql: sql);
    }
  }

  ({String sql, List<dynamic> params}) _translateSql(
      String sql, Map<String, dynamic> params) {
    final paramRegex = RegExp(r'@([a-zA-Z0-9_]+)');
    final positionalParams = <dynamic>[];
    final translatedSql = sql.replaceAllMapped(paramRegex, (match) {
      final name = match.group(1)!;
      var val = params[name];
      if (val is DateTime) {
        val = val.toIso8601String();
      }
      positionalParams.add(val);
      return '?';
    });

    return (
      sql: _stripReturning(translatedSql),
      params: positionalParams,
    );
  }

  String _stripReturning(String sql) {
    final returningRegex = RegExp(r'\s+RETURNING\s+.*$', caseSensitive: false);
    return sql.replaceAll(returningRegex, '');
  }

  @override
  Future<Transaction> beginTransaction() async {
    await execute('BEGIN TRANSACTION');
    return SqliteTransaction(
      () => execute('COMMIT'),
      () => execute('ROLLBACK'),
    );
  }

  @override
  Future<void> close() async {
    _db.dispose();
  }

  @override
  SchemaManager get schemaManager => _schemaManager;

  sqlite.Database get rawDb => _db;
}
