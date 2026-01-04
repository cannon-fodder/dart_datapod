// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'transaction.dart';
import 'query.dart';
import 'schema.dart';

/// Represents a database connection instance and provides access to its features.
///
/// This is the primary interface for interacting with a specific database backend
/// (e.g., Postgres, MySQL). It orchestrates transactions, schema management,
/// and low-level SQL execution.
abstract interface class DatapodDatabase {
  /// The name of this database as defined in `databases.yaml`.
  String get name;

  /// The [TransactionManager] for this database.
  ///
  /// Use this to execute blocks of code within a transaction.
  TransactionManager get transactionManager;

  /// The underlying connection provided by the plugin.
  ///
  /// This provides direct access to [DatabaseConnection.execute],
  /// [DatabaseConnection.stream], and schema features.
  DatabaseConnection get connection;

  /// Closes the database connection and releases any pooled resources.
  Future<void> close();
}

/// Interface for database connections provided by plugins.
///
/// Plugin authors must implement this interface to support new database backends.
abstract interface class DatabaseConnection {
  /// Executes a raw SQL query and returns the results as a [QueryResult].
  ///
  /// [sql] can contain named parameters like `@id`.
  /// [params] is an optional map of parameter names to values.
  Future<QueryResult> execute(String sql, [Map<String, dynamic>? params]);

  /// Executes a raw SQL query and returns a stream of rows.
  ///
  /// This is suitable for large result sets to avoid loading everything into memory.
  Stream<Map<String, dynamic>> stream(String sql,
      [Map<String, dynamic>? params]);

  /// Starts a new transaction manually.
  ///
  /// Consider using [TransactionManager.runInTransaction] instead for better
  /// nested transaction support and automatic commit/rollback.
  Future<Transaction> beginTransaction();

  /// Closes the underlying connection or pool.
  Future<void> close();

  /// Provides access to [SchemaManager] for DDL operations and migrations.
  SchemaManager get schemaManager;
}
