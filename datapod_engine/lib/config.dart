// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'dart:io';
import 'package:yaml/yaml.dart';

/// Represents a database definition in databases.yml.
class DatabaseConfig {
  final String name;
  final String plugin;
  final String connection;
  final String? migrationConnection;
  final Map<String, dynamic> attributes;

  const DatabaseConfig({
    required this.name,
    required this.plugin,
    required this.connection,
    this.migrationConnection,
    this.attributes = const {},
  });

  factory DatabaseConfig.fromYaml(Map<dynamic, dynamic> yaml) {
    return DatabaseConfig(
      name: yaml['name'] as String,
      plugin: yaml['plugin'] as String,
      connection: (yaml['connection'] ?? yaml['name']) as String,
      migrationConnection: yaml['migration_connection'] as String?,
      attributes: (yaml['attributes'] as Map<dynamic, dynamic>? ?? {})
          .cast<String, dynamic>(),
    );
  }

  static List<DatabaseConfig> parse(String content) {
    final yaml = loadYaml(content);
    if (yaml is! YamlMap || yaml['databases'] == null) return [];
    return (yaml['databases'] as YamlList)
        .map((db) => DatabaseConfig.fromYaml(db as YamlMap))
        .toList();
  }

  static Future<List<DatabaseConfig>> load(String path) async {
    final file = File(path);
    if (!await file.exists()) return [];
    final content = await file.readAsString();
    return parse(content);
  }
}

/// Represents a connection definition in connections.yml.
class ConnectionConfig {
  final String name;
  final Map<String, dynamic> attributes;

  const ConnectionConfig({required this.name, this.attributes = const {}});

  String? get host => attributes['host']?.toString();
  int? get port => attributes['port'] as int?;
  String? get username =>
      (attributes['username'] ?? attributes['user'])?.toString();
  String? get password => attributes['password']?.toString();
  String? get database =>
      (attributes['database'] ?? attributes['db'])?.toString();

  int get minConnections => attributes['minConnections'] as int? ?? 1;
  int get maxConnections => attributes['maxConnections'] as int? ?? 5;
  int get idleTimeout => attributes['idleTimeout'] as int? ?? 30;

  factory ConnectionConfig.fromYaml(Map<dynamic, dynamic> yaml) {
    final Map<String, dynamic> attrs = {};
    yaml.forEach((key, value) {
      if (key != 'name') {
        attrs[key.toString()] = value;
      }
    });

    return ConnectionConfig(name: yaml['name'] as String, attributes: attrs);
  }

  static List<ConnectionConfig> parse(String content) {
    final yaml = loadYaml(content);
    if (yaml is! YamlMap || yaml['connections'] == null) return [];
    return (yaml['connections'] as YamlList)
        .map((conn) => ConnectionConfig.fromYaml(conn as YamlMap))
        .toList();
  }

  static Future<List<ConnectionConfig>> load(String path) async {
    final file = File(path);
    if (!await file.exists()) return [];
    final content = await file.readAsString();
    return parse(content);
  }
}
