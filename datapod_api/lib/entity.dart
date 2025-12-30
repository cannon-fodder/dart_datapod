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
abstract interface class ManagedEntity {
  /// Whether the entity is currently managed by the ORM.
  bool get isManaged;

  /// Whether the entity represents a persistent record in the database.
  bool get isPersistent;

  /// Whether the entity has unsaved changes.
  bool get isDirty;

  /// Marks the entity as managed and persistent.
  void markPersistent();

  /// Marks the entity as dirty.
  void markDirty();

  /// Clears the dirty state of the entity.
  void clearDirty();

  /// The database this entity is managed by.
  ///
  /// This is used for lazy loading of relationships.
  DatapodDatabase? get $database;
  set $database(DatapodDatabase? value);

  RelationshipContext? get $relationshipContext;
  set $relationshipContext(RelationshipContext? value);
}
