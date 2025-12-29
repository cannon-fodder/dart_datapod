// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'dart:async';

/// Base repository interface for entity operations.
///
/// [E] is the entity type, and [K] is the primary key type.
abstract class BaseRepository<E, K> {
  /// Saves the given [entity] to the database.
  ///
  /// Returns the saved entity, which may be a managed version of the original.
  Future<E> save(E entity);

  /// Saves all given [entities] to the database.
  ///
  /// Returns the list of saved entities.
  Future<List<E>> saveAll(List<E> entities);

  /// Deletes the entity with the given [id] from the database.
  Future<void> delete(K id);

  /// Finds an entity by its [id].
  ///
  /// Returns the entity if found, otherwise `null`.
  Future<E?> findById(K id);

  /// Find all entities of this type.
  ///
  /// Note: This is an optional method that is only generated if requested in the design.
  /// By default, Repository interfaces can define this.
  // Future<List<E>> findAll();
}
