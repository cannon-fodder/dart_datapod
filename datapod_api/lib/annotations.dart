// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:meta/meta_meta.dart';

/// Indicates the database definition the annotated class is associated with.
@Target({TargetKind.classType})
class Database {
  final String name;
  const Database(this.name);
}

/// Associates a class with a database table.
@Target({TargetKind.classType})
class Entity {
  final String? tableName;
  const Entity({this.tableName});
}

/// Associates a field with a database column.
@Target({TargetKind.field})
class Column {
  final String? name;
  final String? type;
  const Column({this.name, this.type});
}

/// Indicates the primary key field.
@Target({TargetKind.field})
class Id {
  final bool autoIncrement;
  const Id({this.autoIncrement = true});
}

/// Indicates a custom query to execute.
@Target({TargetKind.method})
class Query {
  final String sql;
  const Query(this.sql);
}

/// Indicates a repository interface for code generation.
@Target({TargetKind.classType})
class Repository {
  const Repository();
}

/// Strategy for fetching associated entities.
enum FetchType {
  /// Associated entities are fetched immediately.
  eager,

  /// Associated entities are fetched on demand.
  lazy,
}

/// Propagation of operations across relationships.
enum CascadeType {
  /// All operations are cascaded.
  all,

  /// Only save/persist is cascaded.
  persist,

  /// Only delete/remove is cascaded.
  remove,
}

/// Defines a one-to-one relationship.
@Target({TargetKind.field})
class OneToOne {
  final FetchType fetch;
  final List<CascadeType> cascade;
  final String? mappedBy;
  final bool optional;

  const OneToOne({
    this.fetch = FetchType.lazy,
    this.cascade = const [],
    this.mappedBy,
    this.optional = true,
  });
}

/// Defines a one-to-many relationship.
@Target({TargetKind.field})
class OneToMany {
  final FetchType fetch;
  final List<CascadeType> cascade;
  final String? mappedBy;

  const OneToMany({
    this.fetch = FetchType.lazy,
    this.cascade = const [],
    this.mappedBy,
  });
}

/// Defines a many-to-one relationship.
@Target({TargetKind.field})
class ManyToOne {
  final FetchType fetch;
  final List<CascadeType> cascade;
  final bool optional;

  const ManyToOne({
    this.fetch = FetchType.eager,
    this.cascade = const [],
    this.optional = false,
  });
}

/// Overrides default foreign key column naming.
@Target({TargetKind.field})
class JoinColumn {
  final String name;
  final bool nullable;
  const JoinColumn(this.name, {this.nullable = true});
}
