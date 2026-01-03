// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'dart:async';
import 'query.dart';

/// Interface for executing database operations for a specific entity.
abstract interface class DatabaseOperations<E extends Object> {
  /// Finds an entity by its primary key.
  Future<QueryResult> findById(dynamic id);

  /// Saves an entity (insert or update).
  Future<QueryResult> save(Map<String, dynamic> params,
      {bool isUpdate = false});

  /// Saves an entity (insert or update), handling conversion to/from managed state.
  Future<E> saveEntity<E extends Object>(E entity);

  /// Deletes an entity by its primary key.
  Future<void> delete(dynamic id);
}
