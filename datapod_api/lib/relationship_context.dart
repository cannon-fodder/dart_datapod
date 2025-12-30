// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'repository.dart';

/// Context for managing relationships between repositories.
///
/// This is used internally by repositories to find other repositories
/// they need for cascading and lazy loading.
abstract interface class RelationshipContext {
  /// Gets the repository that manages entities of type [E].
  BaseRepository<E, dynamic> getForEntity<E extends Object>();

  /// Registers a repository for an entity type.
  void registerForEntity<E extends Object>(
      BaseRepository<E, dynamic> repository);
}

/// A simple implementation of [RelationshipContext].
class RelationshipContextImpl implements RelationshipContext {
  final Map<Type, dynamic> _repositoriesByEntity = {};

  @override
  BaseRepository<E, dynamic> getForEntity<E extends Object>() {
    final repo = _repositoriesByEntity[E];
    if (repo == null) {
      throw StateError(
          'No repository registered for entity type $E in this context.');
    }
    return repo as BaseRepository<E, dynamic>;
  }

  @override
  void registerForEntity<E extends Object>(
      BaseRepository<E, dynamic> repository) {
    _repositoriesByEntity[E] = repository;
  }
}
