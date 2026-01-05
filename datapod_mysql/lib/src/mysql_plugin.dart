// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:datapod_api/datapod_api.dart';
import 'package:datapod_engine/datapod_engine.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'mysql_connection.dart';
import 'mysql_database.dart';
import 'mysql_pool.dart';

class MySqlPlugin implements DatapodPlugin {
  @override
  String get name => 'datapod_mysql';

  @override
  Future<DatapodDatabase> createDatabase(
    DatabaseConfig dbConfig,
    ConnectionConfig connConfig, {
    ConnectionConfig? migrationConnConfig,
  }) async {
    final settings = mysql.ConnectionSettings(
      host: connConfig.host ?? 'localhost',
      port: connConfig.port ?? 3306,
      user: connConfig.username,
      password: connConfig.password,
      db: connConfig.database,
    );

    MySqlConnection mainConnection;
    if (connConfig.maxConnections > 1) {
      final pool = await MySqlPool.connect(settings, connConfig.maxConnections);
      mainConnection = MySqlConnection(pool);
    } else {
      final conn = await mysql.MySqlConnection.connect(settings);
      mainConnection = MySqlConnection(SingleMySqlExecutor(conn));
    }

    MySqlConnection? migrationConnection;
    if (migrationConnConfig != null) {
      final migrationSettings = mysql.ConnectionSettings(
        host: migrationConnConfig.host ?? settings.host,
        port: migrationConnConfig.port ?? settings.port,
        user: migrationConnConfig.username,
        password: migrationConnConfig.password,
        db: migrationConnConfig.database ?? settings.db,
      );
      final conn = await mysql.MySqlConnection.connect(migrationSettings);
      migrationConnection = MySqlConnection(SingleMySqlExecutor(conn));
    }

    return MySqlDatabase(
      dbConfig.name,
      mainConnection,
      migrationConnection: migrationConnection,
    );
  }
}
