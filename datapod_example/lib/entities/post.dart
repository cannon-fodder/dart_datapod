// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'dart:convert';
import 'package:datapod_api/datapod_api.dart';
import 'user.dart';
import 'comment.dart';

part 'post.datapod.dart';

enum PostStatus { draft, published, archived }

class DurationConverter extends AttributeConverter<Duration, int> {
  const DurationConverter();

  @override
  int convertToDatabaseColumn(Duration entityValue) =>
      entityValue.inMilliseconds;

  @override
  Duration convertToEntityAttribute(int databaseValue) =>
      Duration(milliseconds: databaseValue);
}

@Entity(tableName: 'posts')
class Post {
  @Id()
  int? id;

  @Index()
  @Column()
  String? title;

  @Convert(DurationConverter)
  @Column()
  Duration? readingTime;

  @CreatedAt()
  @Column()
  DateTime? createdAt;

  @UpdatedAt()
  @Column()
  DateTime? updatedAt;

  @Column()
  String? content;

  @Column()
  PostStatus? status;

  @Column()
  Map<String, dynamic>? metadata;

  @Column()
  List<String>? tags;

  @ManyToOne()
  @JoinColumn('author_id')
  Future<User?>? author;

  @OneToMany(mappedBy: 'post', cascade: [CascadeType.all])
  Future<List<Comment>>? comments;
}
