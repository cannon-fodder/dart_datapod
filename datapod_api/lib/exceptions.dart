// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

/// Base class for all Datapod exceptions.
sealed class DatapodException implements Exception {
  final String message;
  final Object? cause;

  const DatapodException(this.message, {this.cause});

  @override
  String toString() =>
      'DatapodException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Thrown when a database connection fails.
class ConnectionException extends DatapodException {
  const ConnectionException(super.message, {super.cause});
}

/// Thrown when a query execution fails.
class QueryException extends DatapodException {
  final String? sql;

  const QueryException(super.message, {this.sql, super.cause});

  @override
  String toString() => '${super.toString()}${sql != null ? '\nSQL: $sql' : ''}';
}

/// Thrown when a transaction operation fails.
class TransactionException extends DatapodException {
  const TransactionException(super.message, {super.cause});
}

/// Thrown when configuration is invalid.
class ConfigurationException extends DatapodException {
  const ConfigurationException(super.message, {super.cause});
}
