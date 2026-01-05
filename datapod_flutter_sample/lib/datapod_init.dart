// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'dart:io';
import 'package:datapod_api/datapod_api.dart';
import 'package:datapod_engine/datapod_engine.dart';
import 'package:datapod_postgres/datapod_postgres.dart';
import 'package:datapod_flutter_sample/todo_repository.dart';
import 'package:datapod_flutter_sample/todo.dart';

class DatapodInitializer {
  static Future<DatapodContext> initialize({
    String databasesPath = 'databases.yaml',
    String connectionsPath = 'connections.yaml',
    String? databasesYamlContent,
    String? connectionsYamlContent,
  }) async {
    List<DatabaseConfig> dbConfigs = [];
    List<ConnectionConfig> connConfigs = [];

    if (databasesYamlContent != null) {
      dbConfigs = DatabaseConfig.parse(databasesYamlContent);
    } else {
      final databasesFile = File(databasesPath);
      if (!await databasesFile.exists()) {
        throw ConfigurationException('databases.yaml not found at $databasesPath');
      }
      dbConfigs = await DatabaseConfig.load(databasesPath);
    }

    if (connectionsYamlContent != null) {
      connConfigs = ConnectionConfig.parse(connectionsYamlContent);
    } else {
      final connectionsFile = File(connectionsPath);
      if (!await connectionsFile.exists()) {
        throw ConfigurationException('connections.yaml not found at $connectionsPath');
      }
      connConfigs = await ConnectionConfig.load(connectionsPath);
    }

    final sharedContext = RelationshipContextImpl();

    // Initialize sample_db
    final pluginSampleDb = PostgresPlugin();
    final dbConfigSampleDb = dbConfigs.firstWhere((c) => c.name == 'sample_db');
    final connConfigSampleDb = connConfigs.firstWhere((c) => c.name == dbConfigSampleDb.connection);
    ConnectionConfig? migrationConnSampleDb;
    if (dbConfigSampleDb.migrationConnection != null) {
      migrationConnSampleDb = connConfigs.firstWhere((c) => c.name == dbConfigSampleDb.migrationConnection);
    }
    final databaseSampleDb = await pluginSampleDb.createDatabase(dbConfigSampleDb, connConfigSampleDb, migrationConnConfig: migrationConnSampleDb);

    databaseSampleDb.schemaManager.setSchema(const SchemaDefinition(tables: [
      TableDefinition(name: 'todo', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'title', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'is_done', type: 'bool', isNullable: false, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: [], indexes: []),
    ]));

    final todoRepositoryOps = TodoRepositoryOperationsImpl(databaseSampleDb, sharedContext);
    final todoRepositoryMapper = TodoMapperImpl();
    final todoRepository = TodoRepositoryImpl(databaseSampleDb, todoRepositoryOps, todoRepositoryMapper, sharedContext);
    sharedContext.registerOperations<Todo, int>(todoRepositoryOps);
    sharedContext.registerMapper<Todo>(todoRepositoryMapper);

    return DatapodContext(
      sampleDb: databaseSampleDb,
      todoRepository: todoRepository,
    );
  }
}

class DatapodContext {
  final DatapodDatabase sampleDb;
  final TodoRepository todoRepository;

  DatapodContext({
    required this.sampleDb,
    required this.todoRepository,
  });

  Future<void> close() async {
    await sampleDb.close();
  }
}
