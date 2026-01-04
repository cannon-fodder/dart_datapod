// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

/// Core API definitions for Datapod ORM.
///
/// This library exports the essential annotations, interfaces, and classes
/// required to use Datapod in your Dart applications.
///
/// Key components:
/// *   [Entity], [Column], [Id]: Annotations for defining data models.
/// *   [Repository]: Annotation for defining data access interfaces.
/// *   [BaseRepository]: The base class for all repositories.
/// *   [Pageable], [Page], [Sort]: Classes for pagination and sorting.
library datapod_api;

export 'annotations.dart';
export 'converters.dart';
export 'database.dart';
export 'entity.dart';
export 'exceptions.dart';
export 'repository.dart';
export 'relationship_context.dart';
export 'repository_registry.dart';
export 'mapper.dart';
export 'operations.dart';
export 'pagination.dart';
export 'query.dart';
export 'schema.dart';
export 'transaction.dart';
