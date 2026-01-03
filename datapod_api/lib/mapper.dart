// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'database.dart';
import 'relationship_context.dart';

/// Interface for mapping database rows to entities.
abstract class EntityMapper<E extends Object> {
  /// Maps a single database row to an entity.
  E mapRow(Map<String, dynamic> row, DatapodDatabase database,
      RelationshipContext relationshipContext);

  /// Maps a list of database rows to a list of entities.
  List<E> mapRows(Iterable<Map<String, dynamic>> rows, DatapodDatabase database,
      RelationshipContext relationshipContext) {
    return rows
        .map((row) => mapRow(row, database, relationshipContext))
        .toList();
  }
}
