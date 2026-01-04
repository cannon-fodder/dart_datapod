// GENERATED CODE - DO NOT MODIFY BY HAND
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'dart:io';
import 'package:datapod_api/datapod_api.dart';
import 'package:datapod_core/datapod_core.dart';
import 'package:datapod_postgres/datapod_postgres.dart';
import 'package:datapod_mysql/datapod_mysql.dart';
import 'package:datapod_test/repositories/test_entity_repository.dart';
import 'package:datapod_test/repositories/unique_entity_repository.dart';
import 'package:datapod_test/test_entities.dart';

class DatapodInitializer {
  static Future<DatapodContext> initialize({
    String databasesPath = 'databases.yaml',
    String connectionsPath = 'connections.yaml',
  }) async {
    final databasesFile = File(databasesPath);
    final connectionsFile = File(connectionsPath);

    if (!await databasesFile.exists()) {
      throw ConfigurationException('databases.yaml not found at $databasesPath');
    }
    if (!await connectionsFile.exists()) {
      throw ConfigurationException('connections.yaml not found at $connectionsPath');
    }

    final sharedContext = RelationshipContextImpl();

    // Initialize postgres_test
    final pluginPostgresTest = PostgresPlugin();
    final dbConfigPostgresTest = (await DatabaseConfig.load(databasesPath)).firstWhere((c) => c.name == 'postgres_test');
    final connConfigPostgresTest = (await ConnectionConfig.load(connectionsPath)).firstWhere((c) => c.name == 'postgres_test');
    final databasePostgresTest = await pluginPostgresTest.createDatabase(dbConfigPostgresTest, connConfigPostgresTest);

    databasePostgresTest.connection.schemaManager.setSchema(const SchemaDefinition(tables: [
      TableDefinition(name: 'test_entities', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'duration', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'value', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'rating', type: 'double', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'flag', type: 'bool', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'created_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'updated_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'type', type: 'TestEnum', isNullable: true, isAutoIncrement: false, enumValues: ['alpha', 'beta', 'gamma'], isJson: false, isList: false), ColumnDefinition(name: 'data', type: 'Map<String, dynamic>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: false), ColumnDefinition(name: 'tags', type: 'List<String>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: true), ColumnDefinition(name: 'parent_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_test_entities_parent_id', columns: ['parent_id'], referencedTable: 'test_entitys', referencedColumns: ['id'])], uniqueConstraints: [], indexes: [IndexDefinition(name: 'idx_test_entities_name', columns: ['name'], unique: false), IndexDefinition(name: 'idx_name', columns: ['name'], unique: false)]),
      TableDefinition(name: 'unique_entities', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'code', type: 'String', isNullable: false, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'folder', type: 'String', isNullable: false, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'filename', type: 'String', isNullable: false, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: [UniqueConstraintDefinition(name: 'uidx_composite', columns: ['folder', 'filename']), UniqueConstraintDefinition(name: 'uidx_unique_entities_code', columns: ['code'])], indexes: [IndexDefinition(name: 'idx_composite', columns: ['folder', 'filename'], unique: false)]),
    ]));

    final testEntityRepositoryOps = TestEntityRepositoryOperationsImpl(databasePostgresTest, sharedContext);
    final testEntityRepositoryMapper = TestEntityMapperImpl();
    final testEntityRepository = TestEntityRepositoryImpl(databasePostgresTest, testEntityRepositoryOps, testEntityRepositoryMapper, sharedContext);
    sharedContext.registerOperations<TestEntity, int>(testEntityRepositoryOps);
    sharedContext.registerMapper<TestEntity>(testEntityRepositoryMapper);
    final uniqueEntityRepositoryOps = UniqueEntityRepositoryOperationsImpl(databasePostgresTest, sharedContext);
    final uniqueEntityRepositoryMapper = UniqueEntityMapperImpl();
    final uniqueEntityRepository = UniqueEntityRepositoryImpl(databasePostgresTest, uniqueEntityRepositoryOps, uniqueEntityRepositoryMapper, sharedContext);
    sharedContext.registerOperations<UniqueEntity, int>(uniqueEntityRepositoryOps);
    sharedContext.registerMapper<UniqueEntity>(uniqueEntityRepositoryMapper);

    // Initialize mysql_test
    final pluginMysqlTest = MySqlPlugin();
    final dbConfigMysqlTest = (await DatabaseConfig.load(databasesPath)).firstWhere((c) => c.name == 'mysql_test');
    final connConfigMysqlTest = (await ConnectionConfig.load(connectionsPath)).firstWhere((c) => c.name == 'mysql_test');
    final databaseMysqlTest = await pluginMysqlTest.createDatabase(dbConfigMysqlTest, connConfigMysqlTest);

    databaseMysqlTest.connection.schemaManager.setSchema(const SchemaDefinition(tables: [
      TableDefinition(name: 'test_entities', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'duration', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'name', type: 'String', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'value', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'rating', type: 'double', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'flag', type: 'bool', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'created_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'updated_at', type: 'DateTime', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'type', type: 'TestEnum', isNullable: true, isAutoIncrement: false, enumValues: ['alpha', 'beta', 'gamma'], isJson: false, isList: false), ColumnDefinition(name: 'data', type: 'Map<String, dynamic>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: false), ColumnDefinition(name: 'tags', type: 'List<String>', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: true, isList: true), ColumnDefinition(name: 'parent_id', type: 'int', isNullable: true, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [ForeignKeyDefinition(name: 'fk_test_entities_parent_id', columns: ['parent_id'], referencedTable: 'test_entitys', referencedColumns: ['id'])], uniqueConstraints: [], indexes: [IndexDefinition(name: 'idx_test_entities_name', columns: ['name'], unique: false), IndexDefinition(name: 'idx_name', columns: ['name'], unique: false)]),
      TableDefinition(name: 'unique_entities', columns: [ColumnDefinition(name: 'id', type: 'int', isNullable: true, isAutoIncrement: true, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'code', type: 'String', isNullable: false, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'folder', type: 'String', isNullable: false, isAutoIncrement: false, enumValues: null, isJson: false, isList: false), ColumnDefinition(name: 'filename', type: 'String', isNullable: false, isAutoIncrement: false, enumValues: null, isJson: false, isList: false)], primaryKey: ['id'], foreignKeys: [], uniqueConstraints: [UniqueConstraintDefinition(name: 'uidx_composite', columns: ['folder', 'filename']), UniqueConstraintDefinition(name: 'uidx_unique_entities_code', columns: ['code'])], indexes: [IndexDefinition(name: 'idx_composite', columns: ['folder', 'filename'], unique: false)]),
    ]));


    return DatapodContext(
      postgresTest: databasePostgresTest,
      mysqlTest: databaseMysqlTest,
      testEntityRepository: testEntityRepository,
      uniqueEntityRepository: uniqueEntityRepository,
    );
  }
}

class DatapodContext {
  final DatapodDatabase postgresTest;
  final DatapodDatabase mysqlTest;
  final TestEntityRepository testEntityRepository;
  final UniqueEntityRepository uniqueEntityRepository;

  DatapodContext({
    required this.postgresTest,
    required this.mysqlTest,
    required this.testEntityRepository,
    required this.uniqueEntityRepository,
  });

  Future<void> close() async {
    await postgresTest.close();
    await mysqlTest.close();
  }
}
