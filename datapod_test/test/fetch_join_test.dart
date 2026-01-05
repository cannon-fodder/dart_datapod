import 'package:test/test.dart';
import 'package:datapod_api/datapod_api.dart';
import 'package:datapod_test/datapod_init.dart';
import 'package:datapod_test/test_entities.dart';
import 'package:datapod_test/repositories/test_entity_repository.dart';

void main() {
  late DatapodDatabase database;
  late TestEntityRepository testRepository;

  setUpAll(() async {
    // We assume the test environment has the necessary yaml files in the current directory or provide paths
    // For local tests, we might need to specify paths if running from package root
    final context = await DatapodInitializer.initialize(
      databasesPath: 'lib/databases.yaml',
      connectionsPath: 'lib/connections.yaml',
    );
    database = context.postgresTest;
    testRepository = context.testEntityRepository;

    // Sync schema (simplistic for test)
    try {
      await database.connection.execute('DROP TABLE IF EXISTS test_entities');
      await database.schemaManager.initializeSchema();
    } catch (e) {
      print('Error syncing schema: $e');
    }
  });

  tearDownAll(() async {
    await database.connection.close();
  });

  test('FetchJoin - ManyToOne eager loading', () async {
    // 1. Create parent
    final parent = TestEntity()
      ..name = 'Parent'
      ..value = 100;
    final savedParent = await testRepository.save(parent);

    // 2. Create child with parent
    final child = TestEntity()
      ..name = 'Child'
      ..value = 50;

    // Set parent relationship
    child.parent = Future.value(savedParent);

    final savedChild = await testRepository.save(child);

    // 3. Fetch child WITH FetchJoin('parent')
    final fetchedChild = await testRepository.findById(savedChild.id!);
    expect(fetchedChild, isNotNull);
    expect(fetchedChild!.name, equals('Child'));

    // 4. Verify parent is eagerly loaded
    final fetchedParent = await fetchedChild.parent;
    expect(fetchedParent, isNotNull);
    expect(fetchedParent!.id, equals(savedParent.id));
    expect(fetchedParent.name, equals('Parent'));
  });
}
