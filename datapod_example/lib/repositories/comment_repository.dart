// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>

import 'package:datapod_api/datapod_api.dart';
import '../entities/comment.dart';

part 'comment_repository.datapod.dart';

@Repository()
@Database('mysql_db')
abstract class CommentRepository extends BaseRepository<Comment, int> {
  CommentRepository(super.relationshipContext);
}
