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
      // For now, assuming simple positional or raw SQL if mapping isn't fully ready.
      // TODO: Implement named parameter to positional conversion.

      final result = await _connection.query(sql, params?.values.toList());

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
