// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

/// Base class for custom type converters.
///
/// [T] is the Dart type, and [S] is the database type (e.g., String, int).
abstract class AttributeConverter<T, S> {
  const AttributeConverter();

  /// Converts the value from the database type [S] to the Dart type [T].
  T convertToEntityAttribute(S databaseValue);

  /// Converts the value from the Dart type [T] to the database type [S].
  S convertToDatabaseColumn(T entityValue);
}
