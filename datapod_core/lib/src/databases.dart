// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'dart:io';
import 'package:datapod_api/datapod_api.dart';
import 'package:meta/meta.dart';

/// The entry point for the Datapod framework.
class Databases {
  static final Map<String, DatapodDatabase> _databases = {};

  /// Initializes the Datapod framework by loading configurations.
  ///
  /// [databasesPath] defaults to 'databases.yaml'.
  /// [connectionsPath] defaults to 'connections.yaml'.
  static Future<void> initialize({
    String databasesPath = 'databases.yaml',
    String connectionsPath = 'connections.yaml',
    bool migrate = true,
  }) async {
    final databasesFile = File(databasesPath);
    final connectionsFile = File(connectionsPath);

    if (!await databasesFile.exists()) {
      throw ConfigurationException('databases.yml not found at $databasesPath');
    }
    if (!await connectionsFile.exists()) {
      throw ConfigurationException(
        'connections.yml not found at $connectionsPath',
      );
    }

    // TODO: Plugin system to instantiate DatapodDatabase objects
    // This will be implemented in Phase 2 & 3.
  }

  /// Gets a database instance by name.
  static DatapodDatabase get(String name) {
    final db = _databases[name];
    if (db == null) {
      throw ConfigurationException('Database $name not initialized');
    }
    return db;
  }

  /// Internal method for plugins/generator to register databases.
  @internal
  static void register(String name, DatapodDatabase database) {
    _databases[name] = database;
  }
}
