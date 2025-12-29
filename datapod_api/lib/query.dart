// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

/// Represents the result of a database query.
class QueryResult {
  /// The rows returned by the query.
  /// Each row is a map of column names to values.
  final List<Map<String, dynamic>> rows;

  /// The number of rows affected by the query (for INSERT/UPDATE/DELETE).
  final int affectedRows;

  /// The last inserted ID (if applicable).
  final dynamic lastInsertId;

  const QueryResult({
    this.rows = const [],
    this.affectedRows = 0,
    this.lastInsertId,
  });

  bool get isEmpty => rows.isEmpty;
  bool get isNotEmpty => rows.isNotEmpty;
}
