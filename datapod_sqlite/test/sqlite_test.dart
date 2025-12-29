// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'dart:ffi';
import 'dart:io';
import 'package:sqlite3/open.dart';
import 'package:test/test.dart';
import 'package:datapod_core/datapod_core.dart';
import 'package:datapod_sqlite/datapod_sqlite.dart';

void main() {
  if (Platform.isLinux) {
    open.overrideFor(OperatingSystem.linux, () {
      try {
        return DynamicLibrary.open('libsqlite3.so.0');
      } catch (_) {
        return DynamicLibrary.open('/usr/lib/x86_64-linux-gnu/libsqlite3.so.0');
      }
    });
  }
  group('SqlitePlugin', () {
    test('should create and use in-memory database', () async {
      final plugin = SqlitePlugin();
      final db = await plugin.createDatabase(
        const DatabaseConfig(
          name: 'test_db',
          plugin: 'datapod_sqlite',
          connection: 'test_conn',
        ),
        const ConnectionConfig(name: 'test_conn'), // in-memory
      );

      expect(db.name, 'test_db');

      // Create table
      await db.connection.execute(
        'CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)',
      );

      // Insert
      final result = await db.connection.execute(
        'INSERT INTO users (name) VALUES (?)',
        {'name': 'Alice'},
      );
      print(
          'Insert result: affectedRows=${result.affectedRows}, lastInsertId=${result.lastInsertId}');
      expect(result.affectedRows, 1);
      expect(result.lastInsertId, 1);

      // Query
      final query = await db.connection.execute('SELECT * FROM users');
      print('Query result: rows=${query.rows}');
      expect(query.rows.length, 1);
      expect(query.rows.first['name'], 'Alice');

      await db.close();
    });
  });
}
