// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>

import 'package:datapod_api/datapod_api.dart';
import 'post.dart';

part 'comment.datapod.dart';

@Entity(tableName: 'comments')
class Comment {
  @Id()
  int? id;

  @Column()
  String? content;

  @ManyToOne()
  @JoinColumn('post_id')
  Future<Post?>? post;
}
