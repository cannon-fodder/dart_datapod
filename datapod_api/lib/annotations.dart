// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:meta/meta_meta.dart';

/// Indicates the database definition the annotated class is associated with.
///
/// This is used when multiple databases are configured to route the repository
/// to the correct connection.
///
/// Example:
/// ```dart
/// @Database('main_db')
/// @Entity()
/// class User { ... }
/// ```
@Target({TargetKind.classType})
class Database {
  /// The name of the database definition in `databases.yaml`.
  final String name;
  const Database(this.name);
}

/// Associates a class with a database table.
///
/// Datapod will generate a `ManagedEntity` wrapper for classes annotated with
/// this, enabling automated state tracking for persistence.
///
/// Example:
/// ```dart
/// @Entity(tableName: 'users_table')
/// class User {
///   @Id()
///   int? id;
///
///   @Column()
///   late String name;
/// }
/// ```
@Target({TargetKind.classType})
class Entity {
  /// Optional override for the table name. Defaults to snake_case of class name.
  final String? tableName;
  const Entity({this.tableName});
}

/// Associates a field with a database column.
///
/// Fields without this or relationship annotations are ignored by the ORM
/// unless they are basic primitive types.
///
/// Example:
/// ```dart
/// @Column(name: 'user_name', unique: true, nullable: false)
/// late String name;
/// ```
@Target({TargetKind.field})
class Column {
  /// Optional override for the column name. Defaults to snake_case of field name.
  final String? name;

  /// Optional override for the database type (e.g., 'TEXT', 'VARCHAR(255)').
  final String? type;

  /// Whether the column is unique.
  final bool unique;

  /// Whether the column is nullable.
  final bool nullable;

  const Column(
      {this.name, this.type, this.unique = false, this.nullable = true});
}

/// Indicates the primary key field.
///
/// Every [Entity] must have exactly one field annotated with [Id].
///
/// Example:
/// ```dart
/// @Id(autoIncrement: true)
/// int? id;
/// ```
@Target({TargetKind.field})
class Id {
  /// Whether the database should automatically increment this value.
  final bool autoIncrement;
  const Id({this.autoIncrement = true});
}

/// Indicates a custom SQL query to execute for a repository method.
///
/// Use named parameters (e.g., `@name`) to bind method arguments to the SQL.
///
/// Example:
/// ```dart
/// @Query('SELECT * FROM users WHERE email = @email')
/// Future<User?> findByEmail(String email);
/// ```
@Target({TargetKind.method})
class Query {
  /// The raw SQL query to execute.
  final String sql;
  const Query(this.sql);
}

/// Indicates a repository interface for code generation.
///
/// Annotated classes must be `abstract` and extend [BaseRepository].
/// Datapod generates the implementation based on method naming conventions
/// (DSL) or [Query] annotations.
///
/// Example:
/// ```dart
/// @Repository()
/// abstract class UserRepository extends BaseRepository<User, int> {
///   Future<List<User>> findByName(String name);
/// }
/// ```
@Target({TargetKind.classType})
class Repository {
  const Repository();
}

/// Strategy for fetching associated entities.
enum FetchType {
  /// Associated entities are fetched immediately as part of the query.
  eager,

  /// Associated entities are fetched on demand (lazy).
  ///
  /// Relationship fields using [lazy] fetch must be of type `Future<T>`.
  ///
  /// Example:
  /// ```dart
  /// @OneToMany(fetch: FetchType.lazy)
  /// late Future<List<Post>> posts;
  /// ```
  lazy,
}

/// Propagation of operations across relationships.
enum CascadeType {
  /// All operations (persist and remove) are cascaded.
  all,

  /// Only save/persist operations are cascaded.
  persist,

  /// Only delete/remove operations are cascaded.
  remove,
}

/// Defines a one-to-one relationship.
///
/// Example:
/// ```dart
/// @OneToOne(cascade: [CascadeType.all])
/// late Profile profile;
/// ```
@Target({TargetKind.field})
class OneToOne {
  /// The fetch strategy (eager or lazy).
  final FetchType fetch;

  /// The cascade strategies to apply.
  final List<CascadeType> cascade;

  /// The name of the field in the related entity that maps back to this one.
  final String? mappedBy;

  /// Whether the relationship is optional (nullable).
  final bool optional;

  const OneToOne({
    this.fetch = FetchType.lazy,
    this.cascade = const [],
    this.mappedBy,
    this.optional = true,
  });
}

/// Defines a one-to-many relationship.
///
/// Fields with this annotation must be of type `List<T>` or `Future<List<T>>`.
///
/// Example:
/// ```dart
/// @OneToMany(mappedBy: 'author')
/// late List<Book> books;
/// ```
@Target({TargetKind.field})
class OneToMany {
  /// The fetch strategy (eager or lazy).
  final FetchType fetch;

  /// The cascade strategies to apply.
  final List<CascadeType> cascade;

  /// The name of the field in the related entity that maps back to this one.
  final String? mappedBy;

  const OneToMany({
    this.fetch = FetchType.lazy,
    this.cascade = const [],
    this.mappedBy,
  });
}

/// Defines a many-to-one relationship.
///
/// Example:
/// ```dart
/// @ManyToOne()
/// late Department department;
/// ```
@Target({TargetKind.field})
class ManyToOne {
  /// The fetch strategy (eager or lazy).
  final FetchType fetch;

  /// The cascade strategies to apply.
  final List<CascadeType> cascade;

  /// Whether the relationship is optional (nullable).
  final bool optional;

  const ManyToOne({
    this.fetch = FetchType.eager,
    this.cascade = const [],
    this.optional = false,
  });
}

/// Overrides default foreign key column naming for a relationship.
///
/// Example:
/// ```dart
/// @ManyToOne()
/// @JoinColumn('author_id', nullable: false)
/// late User author;
/// ```
@Target({TargetKind.field})
class JoinColumn {
  /// The name of the foreign key column.
  final String name;

  /// Whether the foreign key column is nullable.
  final bool nullable;
  const JoinColumn(this.name, {this.nullable = true});
}

/// Indicates that a field or a combination of fields must be unique.
///
/// When applied to a field, that field alone will have a unique constraint.
/// When applied to a class, specify the [columns] that form a composite unique constraint.
///
/// Example (Field):
/// ```dart
/// @Entity()
/// class User {
///   @Unique()
///   @Column()
///   late String email;
/// }
/// ```
///
/// Example (Class - Composite):
/// ```dart
/// @Entity()
/// @Unique(name: 'uidx_name_org', columns: ['name', 'orgId'])
/// class Person {
///   @Column()
///   late String name;
///   @Column()
///   late int orgId;
/// }
/// ```
@Target({TargetKind.field, TargetKind.classType})
class Unique {
  /// Optional name for the unique constraint.
  final String? name;

  /// List of column names for composite unique constraints.
  /// Only used when applied to a class.
  final List<String>? columns;

  const Unique({this.name, this.columns});
}

/// Indicates a class is a Datapod plugin definition.
///
/// This is used by the code generator to discover and register database plugins.
@Target({TargetKind.classType})
class DatapodPluginDef {
  /// The name of the plugin as referred to in `databases.yaml`.
  final String name;
  const DatapodPluginDef(this.name);
}

/// Indicates that a field or a combination of fields should be indexed.
///
/// When applied to a field, that field alone will be indexed.
/// When applied to a class, specify the [columns] that form a composite index.
///
/// Example (Field):
/// ```dart
/// @Entity()
/// class User {
///   @Index()
///   @Column()
///   late String email;
/// }
/// ```
///
/// Example (Class - Composite):
/// ```dart
/// @Entity()
/// @Index(name: 'idx_name_org', columns: ['name', 'orgId'])
/// class Person {
///   @Column()
///   late String name;
///   @Column()
///   late int orgId;
/// }
/// ```
@Target({TargetKind.field, TargetKind.classType})
class Index {
  /// Optional name for the index.
  final String? name;

  /// List of column names for composite indexes.
  /// Only used when applied to a class.
  final List<String>? columns;

  /// Whether the index should be unique.
  final bool unique;

  const Index({this.name, this.columns, this.unique = false});
}

/// Indicates that a field should automatically store the creation timestamp.
///
/// The field must be of type `DateTime`.
@Target({TargetKind.field})
class CreatedAt {
  const CreatedAt();
}

/// Indicates that a field should automatically store the last update timestamp.
///
/// The field must be of type `DateTime`.
@Target({TargetKind.field})
class UpdatedAt {
  const UpdatedAt();
}

/// Specifies a custom converter for a field.
///
/// The converter must extend [AttributeConverter].
@Target({TargetKind.field})
class Convert {
  final Type converter;
  const Convert(this.converter);
}

/// Indicates that the specified property should be eagerly fetched using a JOIN.
@Target({TargetKind.method})
class FetchJoin {
  final String property;
  const FetchJoin(this.property);
}
