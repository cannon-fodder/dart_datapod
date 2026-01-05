// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:datapod_api/datapod_api.dart';
import 'package:datapod_engine/datapod_engine.dart';
import 'package:postgres/postgres.dart' as pg;
import 'postgres_database.dart';
import 'postgres_connection.dart';

class PostgresPlugin implements DatapodPlugin {
  @override
  String get name => 'datapod_postgres';

  @override
  Future<DatapodDatabase> createDatabase(
    DatabaseConfig dbConfig,
    ConnectionConfig connConfig, {
    ConnectionConfig? migrationConnConfig,
  }) async {
    final endpoint = pg.Endpoint(
      host: connConfig.host ?? 'localhost',
      port: connConfig.port ?? 5432,
      database: connConfig.database ?? 'postgres',
      username: connConfig.username,
      password: connConfig.password,
    );

    PostgresConnection mainConnection;
    if (connConfig.maxConnections > 1) {
      final pool = pg.Pool.withEndpoints(
        [endpoint],
        settings: pg.PoolSettings(
          maxConnectionCount: connConfig.maxConnections,
          sslMode: pg.SslMode.disable,
        ),
      );
      mainConnection = PostgresConnection(pool, onClose: () => pool.close());
    } else {
      final conn = await pg.Connection.open(
        endpoint,
        settings: pg.ConnectionSettings(sslMode: pg.SslMode.disable),
      );
      mainConnection = PostgresConnection(conn);
    }

    PostgresConnection? migrationConnection;
    if (migrationConnConfig != null) {
      // Create separate connection for migrations
      final migrationEndpoint = pg.Endpoint(
        host: migrationConnConfig.host ?? endpoint.host,
        port: migrationConnConfig.port ?? endpoint.port,
        database: migrationConnConfig.database ?? endpoint.database,
        username: migrationConnConfig.username,
        password: migrationConnConfig.password,
      );

      // Migrations are typically single-threaded, so a single connection is fine
      final conn = await pg.Connection.open(
        migrationEndpoint,
        settings: pg.ConnectionSettings(sslMode: pg.SslMode.disable),
      );
      migrationConnection = PostgresConnection(conn);
    }

    return PostgresDatabase(
      dbConfig.name,
      mainConnection,
      migrationConnection: migrationConnection,
    );
  }
}
