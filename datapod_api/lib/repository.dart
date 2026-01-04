// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'dart:async';

import 'pagination.dart';
import 'relationship_context.dart';

/// Base repository interface for entity operations.
///
/// [E] is the entity type, and [K] is the primary key type.
///
/// Datapod generates implementations of this interface for classes annotated
/// with `@Repository()`.
///
/// ### Method Naming DSL (Derived Queries)
/// You can define repository methods by following naming conventions that the
/// generator will translate into SQL queries:
///
/// *   **Prefixes**: `find`, `read`, `query`, `get`.
/// *   **Filters**: use `By` followed by field names and optional operators.
/// *   **Operators**:
///     *   `Containing`: `findByNameContaining(String part)`
///     *   `StartingWith`: `findByEmailStartingWith(String prefix)`
///     *   `EndingWith`: `findByEmailEndingWith(String suffix)`
///     *   `GreaterThan`, `LessThan`: `findByAgeGreaterThan(int age)`
///     *   `IsNull`, `IsNotNull`: `findByProfileIsNull()`
/// *   **Logical Operators**: `And`, `Or` (e.g., `findByNameAndAge`).
///
/// Example:
/// ```dart
/// @Repository()
/// abstract class UserRepository extends BaseRepository<User, int> {
///   // Generated: SELECT * FROM user WHERE email = @email
///   Future<User?> findByEmail(String email);
///
///   // Generated: SELECT * FROM user WHERE age > @age AND active = true
///   Future<List<User>> findByAgeGreaterThanAndActiveTrue(int age);
/// }
/// ```
abstract class BaseRepository<E, K> {
  /// The context used for relationship orchestration and database access.
  final RelationshipContext relationshipContext;

  BaseRepository(this.relationshipContext);

  /// Saves the given [entity] to the database.
  ///
  /// If the entity is not persistent, it will be inserted.
  /// If it is already persistent and has been modified, it will be updated.
  ///
  /// Returns the saved entity, which is typically a [ManagedEntity] wrapper.
  Future<E> save(E entity);

  /// Saves all given [entities] to the database in a batch or sequential order.
  ///
  /// Returns the list of saved entities.
  Future<List<E>> saveAll(List<E> entities);

  /// Deletes the entity with the given [id] from the database.
  ///
  /// Throws an exception if the entity cannot be found or deleted.
  Future<void> delete(K id);

  /// Finds all entities.
  ///
  /// Optionally accepts [sort] to order the results.
  Future<List<E>> findAll({List<Sort>? sort});

  /// Finds a page of entities.
  Future<Page<E>> findAllPaged(Pageable pageable);

  /// Finds an entity by its primary key [id].
  ///
  /// Returns the entity if found, otherwise `null`.
  Future<E?> findById(K id);
}
