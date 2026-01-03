// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'mapper.dart';
import 'operations.dart';

/// Context for managing relationships between repositories.
///
/// This is used internally by repositories to find other repositories
/// they need for cascading and lazy loading.
abstract interface class RelationshipContext {
  /// Gets the mapper for an entity type.
  EntityMapper<E> getMapper<E extends Object>();

  /// Registers a mapper for an entity type.
  void registerMapper<E extends Object>(EntityMapper<E> mapper);

  /// Gets the operations for an entity type.
  DatabaseOperations<E> getOperations<E extends Object>();

  /// Registers operations for an entity type.
  void registerOperations<E extends Object>(DatabaseOperations<E> operations);
}

/// A simple implementation of [RelationshipContext].
class RelationshipContextImpl implements RelationshipContext {
  final Map<Type, dynamic> _mappersByEntity = {};
  final Map<Type, dynamic> _operationsByEntity = {};

  @override
  EntityMapper<E> getMapper<E extends Object>() {
    final mapper = _mappersByEntity[E];
    if (mapper == null) {
      throw StateError(
          'No mapper registered for entity type $E in this context.');
    }
    return mapper as EntityMapper<E>;
  }

  @override
  void registerMapper<E extends Object>(EntityMapper<E> mapper) {
    _mappersByEntity[E] = mapper;
  }

  @override
  DatabaseOperations<E> getOperations<E extends Object>() {
    final operations = _operationsByEntity[E];
    if (operations == null) {
      throw StateError(
          'No operations registered for entity type $E in this context.');
    }
    return operations as DatabaseOperations<E>;
  }

  @override
  void registerOperations<E extends Object>(DatabaseOperations<E> operations) {
    _operationsByEntity[E] = operations;
  }
}
