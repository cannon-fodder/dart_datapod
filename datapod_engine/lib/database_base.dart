// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:datapod_api/datapod_api.dart';

/// Base class for [DatapodDatabase] implementations provided by plugins.
abstract class DatapodDatabaseBase implements DatapodDatabase {
  @override
  final String name;

  /// The underlying connection provided by the plugin.
  @override
  final DatabaseConnection connection;

  @override
  final TransactionManager transactionManager;

  final Map<Type, dynamic> _repositories = {};
  final Map<Type, dynamic> _repositoriesByEntity = {};

  DatapodDatabaseBase(this.name, this.connection, this.transactionManager);

  @override
  R repository<R>() {
    final repo = _repositories[R];
    if (repo == null) {
      throw ConfigurationException('Repository of type $R not registered.');
    }
    return repo as R;
  }

  @override
  BaseRepository<E, dynamic> repositoryFor<E extends Object>() {
    final repo = _repositoriesByEntity[E];
    if (repo == null) {
      throw ConfigurationException(
          'No repository registered for entity type $E.');
    }
    return repo as BaseRepository<E, dynamic>;
  }

  /// Internal method to register repositories during initialization.
  void registerRepository<R>(dynamic repository) {
    _repositories[R] = repository;
    if (repository is BaseRepository) {
      // This is a bit of a hack to get the entity type from the repository,
      // but in a real ORM we would have more metadata.
      // For now, we'll rely on the user registering it or we'll add an entityType getter to BaseRepository.
    }
  }

  /// Explicitly register a repository for an entity type.
  void registerEntityRepository<E extends Object>(
      BaseRepository<E, dynamic> repository) {
    _repositoriesByEntity[E] = repository;
  }

  @override
  Future<void> close() => connection.close();
}
