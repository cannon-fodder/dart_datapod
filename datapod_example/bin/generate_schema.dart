import 'package:datapod_example/datapod_init.dart';

Future<void> main(List<String> args) async {
  print('Loading configuration...');
  final context = await DatapodInitializer.initialize();

  print('Generating schema scripts...\n');

  print('--- identity_db (PostgreSQL) ---');
  final identityScript =
      await context.identityDb.schemaManager.generateSchemaScript();
  print(identityScript);
  print('\n');

  print('--- content_db (MySQL) ---');
  final contentScript =
      await context.contentDb.schemaManager.generateSchemaScript();
  print(contentScript);
  print('\n');

  print('--- config_db (SQLite) ---');
  final configScript =
      await context.configDb.schemaManager.generateSchemaScript();
  print(configScript);
  print('\n');

  await context.close();
  print('Done.');
}
