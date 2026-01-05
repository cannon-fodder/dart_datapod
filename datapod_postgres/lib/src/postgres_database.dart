// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:datapod_api/datapod_api.dart';
import 'package:datapod_engine/datapod_engine.dart';
import 'postgres_connection.dart';
import 'postgres_schema.dart';

class PostgresDatabase extends DatapodDatabaseBase {
  final PostgresConnection? _migrationConnection;

  PostgresDatabase(
    String name,
    PostgresConnection connection, {
    PostgresConnection? migrationConnection,
  })  : _migrationConnection = migrationConnection,
        super(
          name,
          connection,
          PostgresTransactionManager(connection),
        );

  @override
  DatabaseConnection? get migrationConnection => _migrationConnection;

  @override
  SchemaManager get schemaManager => PostgresSchemaManager(
        _migrationConnection ?? connection as PostgresConnection,
      );
}

class PostgresTransactionManager extends BaseTransactionManager {
  final PostgresConnection _connection;

  PostgresTransactionManager(this._connection);

  @override
  Future<Transaction> beginTransaction() => _connection.beginTransaction();
}
