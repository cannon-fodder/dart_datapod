import 'package:test/test.dart';
import 'package:datapod_postgres/datapod_postgres.dart';
import 'package:datapod_engine/datapod_engine.dart';
import 'package:datapod_api/datapod_api.dart';

// Minimal Schema for testing script generation
const testSchema = SchemaDefinition(
  tables: [
    TableDefinition(
      name: 'test_table',
      columns: [
        ColumnDefinition(
            name: 'id', type: 'int', isNullable: false, isAutoIncrement: true),
        ColumnDefinition(
            name: 'name',
            type: 'String',
            isNullable: false,
            isAutoIncrement: false),
      ],
      primaryKey: ['id'],
      foreignKeys: [],
      uniqueConstraints: [],
      indexes: [],
    ),
  ],
);

void main() {
  group('Migration Enhancements', () {
    test('Should parse migration_connection from databases.yaml', () async {
      final configs = await DatabaseConfig.load('databases.yaml');
      final dbConfig = configs.firstWhere((c) => c.name == 'migration_test_db');

      expect(dbConfig.migrationConnection, equals('migration_conn_admin'));
    });

    test('Should initialize database with migration connection', () async {
      final dbConfig = (await DatabaseConfig.load('databases.yaml'))
          .firstWhere((c) => c.name == 'migration_test_db');
      final connConfigs = await ConnectionConfig.load('connections.yaml');

      final mainConnConfig =
          connConfigs.firstWhere((c) => c.name == dbConfig.connection);
      final migrationConnConfig =
          connConfigs.firstWhere((c) => c.name == dbConfig.migrationConnection);

      final plugin = PostgresPlugin();
      final db = await plugin.createDatabase(dbConfig, mainConnConfig,
          migrationConnConfig: migrationConnConfig);

      expect(db.migrationConnection, isNotNull);

      // Clean up
      await db.close();
    });

    test('Should generate schema script', () async {
      final dbConfig = (await DatabaseConfig.load('databases.yaml'))
          .firstWhere((c) => c.name == 'migration_test_db');
      final connConfigs = await ConnectionConfig.load('connections.yaml');
      final mainConnConfig =
          connConfigs.firstWhere((c) => c.name == dbConfig.connection);

      // Use Postgres for script gen test
      final plugin = PostgresPlugin();

      // We don't necessarily need a real migration connection for script gen if it just uses internal logic,
      // but the plugin requires a connection to be created.
      final db = await plugin.createDatabase(dbConfig, mainConnConfig);

      db.connection.schemaManager.setSchema(testSchema);

      final script = await db.connection.schemaManager.generateSchemaScript();

      print('Generated Script:\n$script');

      expect(script, contains('CREATE TABLE IF NOT EXISTS test_table'));
      expect(script, contains('id SERIAL NOT NULL PRIMARY KEY'));
      expect(script, contains('name TEXT NOT NULL'));

      await db.close();
    });
  });
}
