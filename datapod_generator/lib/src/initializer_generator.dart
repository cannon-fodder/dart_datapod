// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'dart:async';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:datapod_api/datapod_api.dart' as api;
import 'package:source_gen/source_gen.dart';
import 'package:yaml/yaml.dart';

class InitializerGenerator extends Builder {
  @override
  final Map<String, List<String>> buildExtensions = const {
    r'$lib$': ['datapod_init.dart']
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final repos = <Map<String, String>>[];
    final entities = <Map<String, String>>[];

    final repoChecker = const TypeChecker.fromRuntime(api.Repository);
    final entityChecker = const TypeChecker.fromRuntime(api.Entity);
    final dbChecker = const TypeChecker.fromRuntime(api.Database);

    await for (final asset in buildStep.findAssets(Glob('lib/**/*.dart'))) {
      if (!await buildStep.resolver.isLibrary(asset)) continue;
      final library = await buildStep.resolver.libraryFor(asset);
      final reader = LibraryReader(library);

      for (final annotated in reader.annotatedWith(repoChecker)) {
        if (annotated.element is ClassElement) {
          final element = annotated.element as ClassElement;
          String? dbName;
          if (dbChecker.hasAnnotationOf(element)) {
            final dbAnnot = dbChecker.firstAnnotationOf(element);
            dbName = dbAnnot?.getField('name')?.toStringValue();
          }
          repos.add({
            'name': element.name,
            'import': asset.uri.toString(),
            if (dbName != null) 'database': dbName,
          });
        }
      }
      // ... entities remains the same ...
      for (final annotated in reader.annotatedWith(entityChecker)) {
        if (annotated.element is ClassElement) {
          final element = annotated.element as ClassElement;
          entities.add({
            'name': element.name,
            'import': asset.uri.toString(),
          });
        }
      }
    }

    if (repos.isEmpty && entities.isEmpty) return;

    // ... YAML reading remains same ...
    YamlMap? databasesYaml;
    var databasesAsset = AssetId(buildStep.inputId.package, 'databases.yaml');
    if (!await buildStep.canRead(databasesAsset)) {
      await for (final asset in buildStep.findAssets(Glob('**.yaml'))) {
        if (asset.path.endsWith('databases.yaml')) {
          databasesAsset = asset;
          break;
        }
      }
    }

    if (await buildStep.canRead(databasesAsset)) {
      final content = await buildStep.readAsString(databasesAsset);
      databasesYaml = loadYaml(content) as YamlMap?;
    }

    final result = StringBuffer();
    // ... imports ...
    result.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
    result.writeln();
    result.writeln("import 'package:datapod_api/datapod_api.dart';");
    result.writeln("import 'package:datapod_core/datapod_core.dart';");

    final allImports = {
      ...repos.map((r) => r['import']!),
      ...entities.map((e) => e['import']!),
    };

    final plugins = <String>{};
    if (databasesYaml != null && databasesYaml['databases'] != null) {
      for (final db in databasesYaml['databases']) {
        if (db is YamlMap && db['plugin'] != null) {
          plugins.add(db['plugin'] as String);
        }
      }
    }

    for (final plugin in plugins) {
      result.writeln("import 'package:$plugin/$plugin.dart';");
    }

    for (final imp in allImports) {
      result.writeln("import '$imp';");
    }

    result.writeln();
    result.writeln("class DatapodInitializer {");
    result.writeln("  static Future<void> initialize({");
    result.writeln("    String databasesPath = 'databases.yaml',");
    result.writeln("    String connectionsPath = 'connections.yaml',");
    result.writeln("  }) async {");
    result.writeln("    await Databases.initialize(");
    result.writeln("      databasesPath: databasesPath,");
    result.writeln("      connectionsPath: connectionsPath,");
    result.writeln("    );");
    result.writeln();
    result.writeln("    final sharedContext = RelationshipContextImpl();");
    result.writeln();

    final repoInstances = <String, String>{}; // repoName -> repoVar

    if (databasesYaml != null && databasesYaml['databases'] != null) {
      for (final db in databasesYaml['databases']) {
        if (db is! YamlMap) continue;
        final dbName = db['name'];
        final pluginName = db['plugin'];
        final pluginClassName = _toPascalCase(pluginName) + 'Plugin';

        result.writeln("    // Initialize $dbName");
        final pluginVar = _toCamelCase('plugin_$dbName');
        final dbConfigVar = _toCamelCase('dbConfig_$dbName');
        final connConfigVar = _toCamelCase('connConfig_$dbName');
        final databaseVar = _toCamelCase('database_$dbName');

        result.writeln("    final $pluginVar = $pluginClassName();");
        result.writeln(
            "    final $dbConfigVar = (await DatabaseConfig.load(databasesPath)).firstWhere((c) => c.name == '$dbName');");
        result.writeln(
            "    final $connConfigVar = (await ConnectionConfig.load(connectionsPath)).firstWhere((c) => c.name == '$dbName');");
        result.writeln(
            "    final $databaseVar = await $pluginVar.createDatabase($dbConfigVar, $connConfigVar);");
        result.writeln("    Databases.register('$dbName', $databaseVar);");
        result.writeln();

        // Repositories mapped to this database via @Database(name) or default
        final dbRepos = repos.where((r) {
          if (r.containsKey('database')) {
            return r['database'] == dbName;
          }
          // Default logic if no annotation: assign to 'postgres_db' or single DB
          return dbName == 'postgres_db' ||
              databasesYaml?['databases'].length == 1;
        }).toList();

        for (final repo in dbRepos) {
          final repoName = repo['name']!;
          final repoVar = _toCamelCase(repoName);
          repoInstances[repoName] = repoVar;
          final databaseVar = _toCamelCase('database_$dbName');
          result.writeln(
              "    final $repoVar = ${repoName}Impl($databaseVar, sharedContext);");
        }
        result.writeln();
      }
    }

    // Register all instances in the shared context and global registry
    result.writeln("    // Register all repositories");
    for (final entry in repoInstances.entries) {
      final repoName = entry.key;
      final repoVar = entry.value;
      final entityName = _getEntityName(repoName, entities);
      result.writeln(
          "    sharedContext.registerForEntity<$entityName>($repoVar);");
      result.writeln("    RepositoryRegistry.register<$repoName>($repoVar);");
      result.writeln(
          "    RepositoryRegistry.registerForEntity<$entityName>($repoVar);");
    }

    result.writeln("  }");

    result.writeln("}");

    final output = AssetId(buildStep.inputId.package, 'lib/datapod_init.dart');
    await buildStep.writeAsString(output, result.toString());
  }

  String _toPascalCase(String s) {
    if (s.startsWith('datapod_')) {
      s = s.substring(8);
    }
    if (s == 'mysql') return 'MySql';
    if (s == 'sqlite') return 'Sqlite';
    if (s == 'postgres') return 'Postgres';
    return s
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join();
  }

  String _toCamelCase(String s) {
    final pascal = _toPascalCase(s);
    return pascal[0].toLowerCase() + pascal.substring(1);
  }

  String _getEntityName(String repoName, List<Map<String, String>> entities) {
    final entityName = repoName.replaceAll('Repository', '');
    if (entities.any((e) => e['name'] == entityName)) {
      return entityName;
    }
    return 'Object';
  }
}
