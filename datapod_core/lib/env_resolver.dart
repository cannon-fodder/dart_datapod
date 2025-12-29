// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'dart:io';

/// Resolves environment variables in a configuration value.
///
/// Syntax supported: ${VAR_NAME}
class EnvResolver {
  static final RegExp _envRegExp = RegExp(r'\$\{([^}]+)\}');

  static String resolve(String value) {
    return value.replaceAllMapped(_envRegExp, (match) {
      final varName = match.group(1)!;
      return Platform.environment[varName] ?? '';
    });
  }

  static dynamic resolveValue(dynamic value) {
    if (value is String) {
      return resolve(value);
    } else if (value is Map) {
      return value.map((k, v) => MapEntry(k, resolveValue(v)));
    } else if (value is List) {
      return value.map((v) => resolveValue(v)).toList();
    }
    return value;
  }
}
