// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'repository.dart';

/// A central registry for managing and looking up repository instances.
class RepositoryRegistry {
  static final Map<Type, dynamic> _repositories = {};
  static final Map<Type, dynamic> _repositoriesByEntity = {};

  /// Registers a repository of type [R].
  static void register<R>(dynamic repository) {
    _repositories[R] = repository;
  }

  /// Registers a repository as the default for entity type [E].
  static void registerForEntity<E extends Object>(
      BaseRepository<E, dynamic> repository) {
    _repositoriesByEntity[E] = repository;
  }

  /// Gets a repository of type [R].
  static R get<R>() {
    final repo = _repositories[R];
    if (repo == null) {
      throw Exception('Repository of type $R not registered.');
    }
    return repo as R;
  }

  /// Gets the repository that manages entities of type [E].
  static BaseRepository<E, dynamic> getForEntity<E extends Object>() {
    final repo = _repositoriesByEntity[E];
    if (repo == null) {
      throw Exception('No repository registered for entity type $E.');
    }
    return repo as BaseRepository<E, dynamic>;
  }

  /// Clears all registered repositories.
  static void clear() {
    _repositories.clear();
    _repositoriesByEntity.clear();
  }
}
