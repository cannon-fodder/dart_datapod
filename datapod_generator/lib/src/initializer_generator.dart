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
import 'dart:io';
import 'sql_generator.dart';

class InitializerGenerator extends Builder {
  @override
  final Map<String, List<String>> buildExtensions = const {
    r'$lib$': ['datapod_init.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final repos = <Map<String, String>>[];
    final entities = <Map<String, String>>[];
    final contexts = <Map<String, dynamic>>[];

    final repoChecker = TypeChecker.fromUrl(
      'package:datapod_api/annotations.dart#Repository',
    );
    final entityChecker = TypeChecker.fromUrl(
      'package:datapod_api/annotations.dart#Entity',
    );
    final dbChecker = TypeChecker.fromUrl(
      'package:datapod_api/annotations.dart#Database',
    );
    final pluginDefChecker = TypeChecker.fromUrl(
      'package:datapod_api/annotations.dart#DatapodPluginDef',
    );
    final contextChecker = TypeChecker.fromUrl(
      'package:datapod_api/annotations.dart#DatapodDatabaseContext',
    );

    final discoveredPlugins = <String, Map<String, String>>{};

    await for (final asset in buildStep.findAssets(Glob('lib/**.dart'))) {
      if (!await buildStep.resolver.isLibrary(asset)) {
        continue;
      }
      final library = await buildStep.resolver.libraryFor(asset);
      final reader = LibraryReader(library);

      for (final annotated in reader.annotatedWith(repoChecker)) {
        if (annotated.element is ClassElement) {
          final element = annotated.element as ClassElement;
          final superType = element.allSupertypes.firstWhere(
            (t) => t.element.name == 'BaseRepository',
            orElse: () => throw InvalidGenerationSourceError(
              'Repository must extend BaseRepository<E, K>',
              element: element,
            ),
          );
          final entityType = superType.typeArguments[0];
          final keyType = superType.typeArguments[1];
          String? dbName;
          if (dbChecker.hasAnnotationOf(element)) {
            final dbAnnot = dbChecker.firstAnnotationOf(element);
            dbName = dbAnnot?.getField('name')?.toStringValue() ?? '';
          }
          repos.add({
            'name': element.name!,
            'import': asset.uri.toString(),
            'entity': entityType.getDisplayString(),
            'key': keyType.getDisplayString(),
            if (dbName != null) 'database': dbName,
          });
        }
      }

      for (final annotated in reader.annotatedWith(entityChecker)) {
        if (annotated.element is ClassElement) {
          final element = annotated.element as ClassElement;
          final metadata = SqlGenerator.parseEntity(element);
          final tableDef = SqlGenerator.generateTableDefinition(metadata);
          entities.add({
            'name': element.name!,
            'import': asset.uri.toString(),
            'tableDef': _generateTableDefCode(tableDef),
          });
        }
      }

      for (final annotated in reader.annotatedWith(pluginDefChecker)) {
        if (annotated.element is ClassElement) {
          final element = annotated.element as ClassElement;
          final pluginName = annotated.annotation.read('name').stringValue;
          discoveredPlugins[pluginName] = {
            'class': element.name!,
            'import': asset.uri.toString(),
          };
        }
      }

      for (final annotated in reader.annotatedWith(contextChecker)) {
        if (annotated.element is ClassElement) {
          final element = annotated.element as ClassElement;
          final repositories = annotated.annotation
              .read('repositories')
              .listValue
              .map((o) => o.toTypeValue()?.element?.name)
              .whereType<String>()
              .toList();

          // Infer database name from context name (e.g. IdentityContext -> identity_db)
          // or allow it to be specified? For now, we'll try to map it or default.
          // In the sample: IdentityContext -> identity_db.
          // Strategy: Convert ContextName to snake_case and append _db if not present??
          // Or just assume the user maps it manually in the init?
          // Better: Check for @Database annotation on the Context class itself?
          // The Annotation doesn't have a db name.
          // Let's use a convention: ContextName (minus Context) + _db, converted to snake case.
          // e.g. IdentityContext -> Identity -> identity_db
          var dbName = _toCamelCase(element.name!);
          if (dbName.endsWith('Context')) {
            dbName = dbName.substring(0, dbName.length - 7);
          }
          dbName = '${dbName}_db'; // Default convention

          // Allow override via @Database annotation on the context class
          if (dbChecker.hasAnnotationOf(element)) {
            final dbAnnot = dbChecker.firstAnnotationOf(element);
            dbName = dbAnnot?.getField('name')?.toStringValue() ?? dbName;
          }

          contexts.add({
            'name': element.name!,
            'import': asset.uri.toString(),
            'repositories': repositories,
            'database': dbName,
            'isAbstract': element.isAbstract,
          });
        }
      }
    }

    if (repos.isEmpty && entities.isEmpty && contexts.isEmpty) return;

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
    } else {
      // Fallback: Try reading from file system directly
      final file = File('databases.yaml');
      if (await file.exists()) {
        final content = await file.readAsString();
        databasesYaml = loadYaml(content) as YamlMap?;
      }
    }

    final result = StringBuffer();
    result.writeln("// ignore_for_file: unused_import");
    result.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
    result.writeln("//");
    result.writeln(
      "// This software is provided \"as is\", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.",
    );
    result.writeln();
    result.writeln("import 'dart:io';");
    result.writeln("import 'package:datapod_api/datapod_api.dart';");
    result.writeln("import 'package:datapod_engine/datapod_engine.dart';");

    final allImports = {
      ...repos.map((r) => r['import']!),
      ...entities.map((e) => e['import']!),
      ...contexts.map((c) => c['import'] as String),
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
      if (discoveredPlugins.containsKey(plugin)) {
        allImports.add(discoveredPlugins[plugin]!['import']!);
      } else {
        result.writeln("import 'package:$plugin/$plugin.dart';");
      }
    }

    for (final imp in allImports) {
      result.writeln("import '$imp';");
    }

    result.writeln();
    result.writeln("class DatapodInitializer {");
    result.writeln("  static Future<DatapodContext> initialize({");
    result.writeln("    String databasesPath = 'databases.yaml',");
    result.writeln("    String connectionsPath = 'connections.yaml',");
    result.writeln("    String? databasesYamlContent,");
    result.writeln("    String? connectionsYamlContent,");
    result.writeln("  }) async {");
    result.writeln("    List<DatabaseConfig> dbConfigs = [];");
    result.writeln("    List<ConnectionConfig> connConfigs = [];");
    result.writeln();
    result.writeln("    if (databasesYamlContent != null) {");
    result.writeln(
      "      dbConfigs = DatabaseConfig.parse(databasesYamlContent);",
    );
    result.writeln("    } else {");
    result.writeln("      final databasesFile = File(databasesPath);");
    result.writeln("      if (!await databasesFile.exists()) {");
    result.writeln(
      "        throw ConfigurationException('databases.yaml not found at \$databasesPath');",
    );
    result.writeln("      }");
    result.writeln(
      "      dbConfigs = await DatabaseConfig.load(databasesPath);",
    );
    result.writeln("    }");
    result.writeln();
    result.writeln("    if (connectionsYamlContent != null) {");
    result.writeln(
      "      connConfigs = ConnectionConfig.parse(connectionsYamlContent);",
    );
    result.writeln("    } else {");
    result.writeln("      final connectionsFile = File(connectionsPath);");
    result.writeln("      if (!await connectionsFile.exists()) {");
    result.writeln(
      "        throw ConfigurationException('connections.yaml not found at \$connectionsPath');",
    );
    result.writeln("      }");
    result.writeln(
      "      connConfigs = await ConnectionConfig.load(connectionsPath);",
    );
    result.writeln("    }");
    result.writeln();
    result.writeln(
      "    // Shared context (registry) for cross-database references",
    );
    result.writeln("    final sharedContext = RelationshipContextImpl();");
    result.writeln();

    final repoInstances = <String, String>{}; // repoName -> accessString
    final dbInstances = <String, String>{}; // dbName -> dbVar

    // Track which repositories are already initialized by contexts
    final initializedRepos = <String>{};

    if (databasesYaml != null && databasesYaml['databases'] != null) {
      for (final db in databasesYaml['databases']) {
        if (db is! YamlMap) continue;
        final dbName = db['name'] as String;
        final pluginName = db['plugin'] as String;
        String pluginClassName;
        if (discoveredPlugins.containsKey(pluginName)) {
          pluginClassName = discoveredPlugins[pluginName]!['class']!;
        } else {
          pluginClassName = '${_toPascalCase(pluginName)}Plugin';
        }

        result.writeln("    // Initialize $dbName");
        final pluginVar = _toCamelCase('plugin_$dbName');
        final dbConfigVar = _toCamelCase('dbConfig_$dbName');
        final connConfigVar = _toCamelCase('connConfig_$dbName');
        final databaseVar = _toCamelCase('database_$dbName');
        dbInstances[dbName] = databaseVar;

        result.writeln("    final $pluginVar = $pluginClassName();");
        result.writeln(
          "    final $dbConfigVar = dbConfigs.firstWhere((c) => c.name == '$dbName');",
        );
        result.writeln(
          "    final $connConfigVar = connConfigs.firstWhere((c) => c.name == $dbConfigVar.connection);",
        );

        final migrationConnVar = _toCamelCase('migrationConn_$dbName');
        result.writeln("    ConnectionConfig? $migrationConnVar;");
        result.writeln("    if ($dbConfigVar.migrationConnection != null) {");
        result.writeln(
          "      $migrationConnVar = connConfigs.firstWhere((c) => c.name == $dbConfigVar.migrationConnection);",
        );
        result.writeln("    }");

        result.writeln(
          "    final $databaseVar = await $pluginVar.createDatabase($dbConfigVar, $connConfigVar, migrationConnConfig: $migrationConnVar);",
        );
        result.writeln();

        result.writeln(
          "    $databaseVar.schemaManager.setSchema(const SchemaDefinition(tables: [",
        );
        for (final entity in entities) {
          result.writeln("      ${entity['tableDef']},");
        }
        result.writeln("    ]));");
        result.writeln();

        // 1. Initialize Contexts bound to this DB
        final dbContexts = contexts
            .where((c) => c['database'] == dbName)
            .toList();
        for (final context in dbContexts) {
          final contextName = context['name'] as String;
          final isAbstract = context['isAbstract'] as bool? ?? false;
          final contextVar = _toCamelCase(contextName);
          final generatedContextName = isAbstract
              ? '${contextName}Impl'
              : contextName;
          final scopedContextVar = '${contextVar}ScopedContext';

          result.writeln("    // Initialize $contextName");
          result.writeln(
            "    final $scopedContextVar = ScopedRelationshipContext(sharedContext, $databaseVar);",
          );
          result.writeln(
            "    final $contextVar = $generatedContextName($scopedContextVar);",
          );

          for (final repoName in context['repositories'] as List<String>) {
            final repoField = _toCamelCase(repoName);
            repoInstances[repoName] = '$contextVar.$repoField';
            initializedRepos.add(repoName);
          }
          result.writeln();
        }

        // 2. Initialize remaining standalone repositories bound to this DB
        final allDbNames = (databasesYaml['databases'] as YamlList)
            .map((d) => d['name'] as String)
            .toList();
        final dbRepos = repos.where((r) {
          // Skip if already initialized via context
          if (initializedRepos.contains(r['name'])) return false;

          if (r.containsKey('database')) {
            return r['database'] == dbName;
          }
          final defaultDb = allDbNames.contains('postgres_db')
              ? 'postgres_db'
              : allDbNames.first;
          return dbName == defaultDb;
        }).toList();

        for (final repo in dbRepos) {
          final repoName = repo['name']!;
          final repoVar = _toCamelCase(repoName);
          final entityName = repo['entity']!;

          repoInstances[repoName] = repoVar;
          result.writeln(
            "    final ${repoVar}Ops = ${repoName}OperationsImpl($databaseVar, sharedContext);",
          );
          result.writeln(
            "    final ${repoVar}Mapper = ${entityName}MapperImpl();",
          );
          result.writeln(
            "    final $repoVar = ${repoName}Impl($databaseVar, ${repoVar}Ops, ${repoVar}Mapper, sharedContext);",
          );
        }
        result.writeln();
      }
    }

    if (dbInstances.isEmpty && repoInstances.isEmpty) {
      result.writeln("    return DatapodContext();");
    } else {
      result.writeln("    return DatapodContext(");
      for (final dbEntry in dbInstances.entries) {
        result.writeln("      ${_toCamelCase(dbEntry.key)}: ${dbEntry.value},");
      }
      for (final repoEntry in repoInstances.entries) {
        result.writeln(
          "      ${_toCamelCase(repoEntry.key)}: ${repoEntry.value},",
        );
      }
      result.writeln("    );");
    }
    result.writeln("  }");
    result.writeln("}");
    result.writeln();

    result.writeln("class DatapodContext {");
    for (final dbEntry in dbInstances.entries) {
      result.writeln("  final DatapodDatabase ${_toCamelCase(dbEntry.key)};");
    }
    for (final repoEntry in repoInstances.entries) {
      result.writeln(
        "  final ${repoEntry.key} ${_toCamelCase(repoEntry.key)};",
      );
    }
    result.writeln();
    if (dbInstances.isEmpty && repoInstances.isEmpty) {
      result.writeln("  DatapodContext();");
    } else {
      result.writeln("  DatapodContext({");
      for (final dbEntry in dbInstances.entries) {
        result.writeln("    required this.${_toCamelCase(dbEntry.key)},");
      }
      for (final repoEntry in repoInstances.entries) {
        result.writeln("    required this.${_toCamelCase(repoEntry.key)},");
      }
      result.writeln("  });");
    }
    result.writeln();
    result.writeln("  Future<void> close() async {");
    for (final dbEntry in dbInstances.entries) {
      result.writeln("    await ${_toCamelCase(dbEntry.key)}.close();");
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

  String _generateTableDefCode(api.TableDefinition def) {
    final columns = def.columns
        .map((c) {
          final values = c.enumValues != null
              ? '[${c.enumValues!.map((v) => "'$v'").join(', ')}]'
              : 'null';
          return "ColumnDefinition(name: '${c.name}', type: '${c.type}', isNullable: ${c.isNullable}, isAutoIncrement: ${c.isAutoIncrement}${c.defaultValue != null ? ", defaultValue: '${c.defaultValue}'" : ""}, enumValues: $values, isJson: ${c.isJson}, isList: ${c.isList})";
        })
        .join(', ');
    final pks = def.primaryKey.map((pk) => "'$pk'").join(', ');
    final fks = def.foreignKeys
        .map(
          (fk) =>
              "ForeignKeyDefinition(name: '${fk.name}', columns: [${fk.columns.map((c) => "'$c'").join(', ')}], referencedTable: '${fk.referencedTable}', referencedColumns: [${fk.referencedColumns.map((c) => "'$c'").join(', ')}]${fk.onDelete != null ? ", onDelete: '${fk.onDelete}'" : ""})",
        )
        .join(', ');
    final unique = def.uniqueConstraints
        .map(
          (u) =>
              "UniqueConstraintDefinition(name: '${u.name}', columns: [${u.columns.map((c) => "'$c'").join(', ')}])",
        )
        .join(', ');
    final indexes = def.indexes
        .map(
          (idx) =>
              "IndexDefinition(name: '${idx.name}', columns: [${idx.columns.map((c) => "'$c'").join(', ')}], unique: ${idx.unique})",
        )
        .join(', ');

    return "TableDefinition(name: '${def.name}', columns: [$columns], primaryKey: [$pks], foreignKeys: [$fks], uniqueConstraints: [$unique], indexes: [$indexes])";
  }
}
