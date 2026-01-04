// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

/// The core execution engine for the Datapod ORM.
///
/// This library provides the fundamental runtime components for Datapod, including:
/// *   **Database Abstraction**: Interfaces for database drivers and connections.
/// *   **Plugin System**: Mechanisms for registering and managing database plugins.
/// *   **Configuration**: Classes for parsing and validating database configurations (`datapod.yaml`).
/// *   **Environment Resolution**: Utilities for resolving environment variables in configurations.
/// *   **Transaction Management**: Core logic for handling transactions across unified or disparate databases.
library datapod_engine;

export 'database_base.dart';
export 'plugin.dart';
export 'src/transaction_manager.dart';
export 'config.dart';
export 'env_resolver.dart';
