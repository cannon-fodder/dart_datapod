// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'database.dart';
import 'relationship_context.dart';

/// Interface for entities that are managed by the Datapod ORM.
///
/// Managed entities carry additional state information used for persistence
/// orchestration, such as dirty tracking and persistence status. This allows
/// Datapod to efficiently decide between `INSERT` and `UPDATE` operations
/// when [save] is called on a repository.
///
/// Datapod automatically generates [ManagedEntity] implementations for your
/// entity classes during the build process. You typically do not need to
/// implement this interface manually.
abstract interface class ManagedEntity {
  /// Whether the entity is currently managed by the ORM.
  bool get isManaged;

  /// Whether the entity represents a persistent record in the database.
  ///
  /// Persistent entities will be updated on [save], while non-persistent
  /// ones will be inserted.
  bool get isPersistent;

  /// Whether the entity has unsaved changes.
  ///
  /// Dirty entities will be processed during update operations.
  bool get isDirty;

  /// The value of the primary key field for this entity.
  dynamic get $id;

  /// Marks the entity as managed and persistent (e.g., after a successful insert).
  void markPersistent();

  /// Marks the entity as having unsaved changes.
  void markDirty();

  /// Resets the dirty state of the entity.
  void clearDirty();

  /// The database instance that manages this entity.
  ///
  /// This is used internally for lazy loading of relationships.
  DatapodDatabase? get $database;
  set $database(DatapodDatabase? value);

  /// The relationship context used for orchestrating associations.
  RelationshipContext? get $relationshipContext;
  set $relationshipContext(RelationshipContext? value);
}
