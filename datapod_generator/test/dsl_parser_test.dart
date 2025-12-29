// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:datapod_generator/src/dsl_parser.dart';
import 'package:test/test.dart';

void main() {
  group('DSLParser Tests', () {
    test('Basic field match', () {
      final results = DSLParser.parse('countByName');
      expect(results.length, 1);
      expect(results[0].field, 'name');
      expect(results[0].operator, 'Equal');
    });

    test('And condition', () {
      final results = DSLParser.parse('countByNameAndEmail');
      expect(results.length, 2);
      expect(results[0].field, 'name');
      expect(results[0].operator, 'Equal');
      expect(results[0].isOr, isFalse);
      expect(results[1].field, 'email');
      expect(results[1].operator, 'Equal');
      expect(results[1].isOr, isFalse);
    });

    test('Or condition', () {
      final results = DSLParser.parse('findByNameOrEmail');
      expect(results.length, 2);
      expect(results[1].isOr, isTrue);
      expect(results[1].field, 'email');
    });

    test('Contains operator', () {
      final results = DSLParser.parse('countByNameContains');
      expect(results[0].operator, 'Contains');
      expect(results[0].field, 'name');
    });

    test('IsNotNull operator', () {
      final results = DSLParser.parse('countByNameIsNotNull');
      expect(results[0].operator, 'IsNotNull');
      expect(results[0].field, 'name');
    });

    test('Complex operators', () {
      final results = DSLParser.parse('countByAgeBetweenAndActiveTrue');
      expect(results.length, 2);
      expect(results[0].field, 'age');
      expect(results[0].operator, 'Between');
      expect(results[1].field, 'active');
      expect(results[1].operator, 'True');
    });
  });
}
