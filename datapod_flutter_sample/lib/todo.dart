import 'package:datapod_api/datapod_api.dart';

part 'todo.datapod.dart';

@Entity()
class Todo {
  @Id()
  int? id;

  String? title;
  bool isDone = false;
}
