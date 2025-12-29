// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:test/test.dart';
import 'package:datapod_core/datapod_core.dart';

void main() {
  group('ConnectionConfig', () {
    test('should parse from YAML correctly', () {
      final yaml = {
        'name': 'test_conn',
        'host': 'localhost',
        'port': 5432,
        'username': 'user',
        'password': 'password',
        'database': 'test_db'
      };
      final config = ConnectionConfig.fromYaml(yaml);
      expect(config.name, 'test_conn');
      expect(config.host, 'localhost');
      expect(config.port, 5432);
      expect(config.username, 'user');
      expect(config.password, 'password');
      expect(config.database, 'test_db');
    });
  });

  group('DatabaseConfig', () {
    test('should parse from YAML correctly', () {
      final yaml = {
        'name': 'main',
        'plugin': 'postgres',
        'connection': 'test_conn'
      };
      final config = DatabaseConfig.fromYaml(yaml);
      expect(config.name, 'main');
      expect(config.plugin, 'postgres');
      expect(config.connection, 'test_conn');
    });
  });
}
