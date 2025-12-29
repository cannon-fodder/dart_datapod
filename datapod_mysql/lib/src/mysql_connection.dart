// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:datapod_api/datapod_api.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'mysql_schema.dart';
import 'mysql_transaction.dart';

class MySqlConnection implements DatabaseConnection {
  final mysql.MySqlConnection _connection;
  late final MySqlSchemaManager _schemaManager;

  MySqlConnection(this._connection) {
    _schemaManager = MySqlSchemaManager(this);
  }

  @override
  Future<QueryResult> execute(String sql,
      [Map<String, dynamic>? params]) async {
    try {
      // mysql1 uses ? for params, we might need a converter if we use named params
      String processedSql = sql;
      List<dynamic> positionalParams = [];

      if (params != null && params.isNotEmpty) {
        final translation = _translateSql(sql, params);
        processedSql = translation.sql;
        positionalParams = translation.params;
      } else {
        processedSql = _stripReturning(sql);
      }

      final result = await _connection.query(processedSql, positionalParams);

      final rows = result.map((row) => row.fields).toList();

      return QueryResult(
        rows: rows,
        affectedRows: result.affectedRows ?? 0,
        lastInsertId: result.insertId,
      );
    } catch (e) {
      throw QueryException('MySQL Error: $e', sql: sql);
    }
  }

  ({String sql, List<dynamic> params}) _translateSql(
      String sql, Map<String, dynamic> params) {
    final paramRegex = RegExp(r'@([a-zA-Z0-9_]+)');
    final positionalParams = <dynamic>[];
    final translatedSql = sql.replaceAllMapped(paramRegex, (match) {
      final name = match.group(1)!;
      positionalParams.add(params[name]);
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
    // mysql1 uses a callback for transactions. To adapt to our imperative API,
    // we need to be careful. For now, we'll use raw SQL commands.
    await execute('START TRANSACTION');
    return MySqlTransaction(
      () => execute('COMMIT'),
      () => execute('ROLLBACK'),
    );
  }

  @override
  Future<void> close() => _connection.close();

  @override
  SchemaManager get schemaManager => _schemaManager;

  /// Internal access for schema manager to use the underlying mysql1 connection if needed.
  mysql.MySqlConnection get rawConnection => _connection;
}
