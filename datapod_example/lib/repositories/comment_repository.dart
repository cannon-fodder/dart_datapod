// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>

import 'package:datapod_api/datapod_api.dart';
import '../entities/comment.dart';
import '../entities/post.dart';

part 'comment_repository.datapod.dart';

@Repository()
@Database('content_db')
abstract class CommentRepository extends BaseRepository<Comment, int> {
  CommentRepository(super.relationshipContext);

  @FetchJoin('post')
  @override
  Future<Comment?> findById(int id);
}
