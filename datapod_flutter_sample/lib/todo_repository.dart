import 'package:datapod_api/datapod_api.dart';

import 'todo.dart';

part 'todo_repository.datapod.dart';

@Repository()
@Database('sample_db')
abstract class TodoRepository extends BaseRepository<Todo, int> {
  TodoRepository(super.context);
}
