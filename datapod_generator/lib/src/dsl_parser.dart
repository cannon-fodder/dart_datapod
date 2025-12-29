// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

/// Represents a parsed component of a repository method name DSL.
class QueryComponent {
  final String field;
  final String operator;
  final bool isOr;

  const QueryComponent({
    required this.field,
    required this.operator,
    this.isOr = false,
  });
}

/// Parses repository method names into structured query components.
class DSLParser {
  static const operators = [
    'IsNotNull',
    'IsNull',
    'IsNotEmpty',
    'IsEmpty',
    'NotLike',
    'Like',
    'StartsWith',
    'EndsWith',
    'Contains',
    'NotContains',
    'Between',
    'LessThanOrEqual',
    'LessThan',
    'GreaterThanOrEqual',
    'GreaterThan',
    'NotIn',
    'In',
    'Not',
    'Is',
    'True',
    'False',
  ];

  static List<QueryComponent> parse(String methodName) {
    // Remove prefixes like countBy, findBy, deleteBy, existsBy
    final raw = methodName.replaceFirst(
      RegExp(r'^(count|find|delete|exists)By'),
      '',
    );

    // Split by And/Or
    final parts = raw.split(RegExp(r'(?<=.)(?=And|Or)'));

    final components = <QueryComponent>[];
    for (final part in parts) {
      final isOr = part.startsWith('Or');
      final cleanPart = part.replaceFirst(RegExp(r'^(And|Or)'), '');

      String field = cleanPart;
      String operator = 'Equal'; // Default

      for (final op in operators) {
        if (cleanPart.endsWith(op)) {
          operator = op;
          field = cleanPart.substring(0, cleanPart.length - op.length);
          break;
        }
      }

      components.add(
        QueryComponent(
          field: _decapitalize(field),
          operator: operator,
          isOr: isOr,
        ),
      );
    }

    return components;
  }

  static String _decapitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toLowerCase() + s.substring(1);
  }
}
