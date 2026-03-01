import 'package:flutter_test/flutter_test.dart';
import 'package:datapod_flutter_sample/main.dart';
import 'package:datapod_flutter_sample/datapod_init.dart';
import 'package:datapod_flutter_sample/todo.dart';
import 'package:datapod_api/datapod_api.dart';

import 'package:datapod_flutter_sample/todo_repository.dart';

class FakeDatapodDatabase implements DatapodDatabase {
  @override
  String get name => 'fake_db';

  String get pluginName => 'fake';

  @override
  DatabaseConnection get connection => throw UnimplementedError();

  @override
  DatabaseConnection? get migrationConnection => null;

  @override
  TransactionManager get transactionManager => throw UnimplementedError();

  @override
  SchemaManager get schemaManager => throw UnimplementedError();

  Future<void> Function()? onClosed;

  @override
  Future<void> close() async {}
}

class FakeTodoRepository extends TodoRepository {
  FakeTodoRepository() : super(RelationshipContextImpl());

  @override
  Future<Todo> save(Todo entity) async => entity;

  @override
  Future<List<Todo>> saveAll(List<Todo> entities) async => entities;

  @override
  Future<void> delete(int id) async {}

  @override
  Future<List<Todo>> findAll({List<Sort>? sort}) async => [];

  @override
  Future<Page<Todo>> findAllPaged(Pageable pageable) async => Page(
    items: [],
    totalElements: 0,
    pageNumber: pageable.page,
    pageSize: pageable.size,
  );

  @override
  Future<Todo?> findById(int id) async => null;
}

void main() {
  testWidgets('Todo list smoke test', (WidgetTester tester) async {
    final context = DatapodContext(
      sampleDb: FakeDatapodDatabase(),
      todoRepository: FakeTodoRepository(),
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(context: context));
    await tester.pumpAndSettle();

    // Verify that the empty state is shown.
    expect(find.text('No todos yet. Add one!'), findsOneWidget);
  });
}
