import 'dart:io';
import 'package:test/test.dart';
import 'package:datapod_test/datapod_init.dart';

void main() {
  test('initialize DatapodContext from string configuration', () async {
    // Read files manually to simulate loading from assets/memory
    // Assuming the test runs from the package root or standard test location
    final dbContent = await File('databases.yaml').readAsString();
    final connContent = await File('connections.yaml').readAsString();

    final context = await DatapodInitializer.initialize(
      databasesYamlContent: dbContent,
      connectionsYamlContent: connContent,
    );

    addTearDown(() async {
      await context.close();
    });

    expect(context, isNotNull);

    // Check that we can execute a query on one of the initialized databases
    final result = await context.postgresTest.connection.execute('SELECT 1');
    expect(result.rows, isNotEmpty);
  });
}
