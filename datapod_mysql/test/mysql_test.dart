// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:test/test.dart';
import 'package:datapod_engine/datapod_engine.dart';
import 'package:datapod_mysql/datapod_mysql.dart';

void main() {
  group('MySqlPlugin', () {
    test('should connect and execute queries', () async {
      final plugin = MySqlPlugin();
      final db = await plugin.createDatabase(
        const DatabaseConfig(
          name: 'test_db',
          plugin: 'datapod_mysql',
          connection: 'test_conn',
        ),
        const ConnectionConfig(
          name: 'test_conn',
          attributes: {
            'host': '127.0.0.1',
            'port': 3307,
            'username': 'datapod',
            'password': 'datapod',
            'database': 'datapod_test',
          },
        ),
      );

      expect(db.name, 'test_db');

      // Create table
      await db.connection.execute('DROP TABLE IF EXISTS test_plugin_users');
      await db.connection.execute(
        'CREATE TABLE test_plugin_users (id INTEGER AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255), UNIQUE INDEX (name))',
      );

      // Insert
      final result = await db.connection.execute(
        'INSERT INTO test_plugin_users (name) VALUES (@name)',
        {'name': 'Alice'},
      );
      expect(result.affectedRows, 1);

      // Query
      final query = await db.connection.execute(
        'SELECT * FROM test_plugin_users',
      );
      expect(query.rows.length, 1);
      expect(query.rows.first['name'], 'Alice');

      await db.close();
    });
  });
}
