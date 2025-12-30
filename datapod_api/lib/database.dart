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
abstract interface class DatapodDatabase {
  /// The name of this database as defined in configuration.
  String get name;

  /// The [TransactionManager] for this database.
  TransactionManager get transactionManager;

  /// The underlying connection provided by the plugin.
  DatabaseConnection get connection;

  /// Closes the database connection.
  Future<void> close();
}

/// Interface for database connections provided by plugins.
abstract interface class DatabaseConnection {
  /// Executes a raw SQL query and returns the results.
  Future<QueryResult> execute(String sql, [Map<String, dynamic>? params]);

  /// Starts a new transaction.
  Future<Transaction> beginTransaction();

  /// Closes the connection.
  Future<void> close();

  /// Provides access to schema management features.
  SchemaManager get schemaManager;
}
