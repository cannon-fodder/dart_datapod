// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:test/test.dart';
import 'package:datapod_generator/src/sql_generator.dart';
import 'package:datapod_generator/src/dsl_parser.dart';

void main() {
  group('SqlGenerator Unit Tests', () {
    // Helper to create metadata
    EntitySqlMetadata createMeta({
      required String tableName,
      required List<ColumnMetadata> columns,
      ColumnMetadata? idColumn,
    }) {
      return EntitySqlMetadata(
        tableName: tableName,
        columns: columns,
        idColumn: idColumn,
      );
    }

    final simpleColumns = [
      ColumnMetadata(
          fieldName: 'id', columnName: 'id', fieldType: 'int', isId: true),
      ColumnMetadata(
          fieldName: 'name', columnName: 'name', fieldType: 'String'),
      ColumnMetadata(fieldName: 'age', columnName: 'age', fieldType: 'int'),
    ];

    final simpleMeta = createMeta(
      tableName: 'users',
      columns: simpleColumns,
      idColumn: simpleColumns[0],
    );

    test('generateInsert', () {
      final sql = SqlGenerator.generateInsert(simpleMeta);
      expect(sql, startsWith('INSERT INTO users'));
      expect(sql, contains('(id, name, age)'));
      expect(sql, contains('VALUES (@id, @name, @age)'));
    });

    test('generateInsert with autoIncrement ID', () {
      final aiColumns = [
        ColumnMetadata(
            fieldName: 'id',
            columnName: 'id',
            fieldType: 'int',
            isId: true,
            autoIncrement: true),
        ColumnMetadata(
            fieldName: 'name', columnName: 'name', fieldType: 'String'),
      ];
      final meta = createMeta(
          tableName: 'users', columns: aiColumns, idColumn: aiColumns[0]);

      final sql = SqlGenerator.generateInsert(meta);
      expect(sql, startsWith('INSERT INTO users'));
      expect(sql, contains('(name)'));
      expect(sql, contains('VALUES (@name)'));
      expect(sql, contains('RETURNING id'));
    });

    test('generateUpdate', () {
      final sql = SqlGenerator.generateUpdate(simpleMeta);
      expect(sql, startsWith('UPDATE users SET'));
      expect(sql, contains('name = @name'));
      expect(sql, contains('age = @age'));
      expect(sql, contains('WHERE id = @id'));
    });

    test('generateDelete', () {
      final sql = SqlGenerator.generateDelete(simpleMeta);
      expect(sql, 'DELETE FROM users WHERE id = @id');
    });

    test('generateFindById', () {
      final sql = SqlGenerator.generateFindById(simpleMeta);
      expect(sql, 'SELECT * FROM users WHERE id = @id');
    });

    group('generateDslQuery', () {
      test('Find by simple field', () {
        final dslComponents = [
          QueryComponent(field: 'name', operator: 'Equal', isOr: false)
        ];
        final sql = SqlGenerator.generateDslQuery(
            simpleMeta, dslComponents, 'find', ['name']);
        expect(sql, 'SELECT * FROM users WHERE name = @name');
      });

      test('Find by multiple fields (AND)', () {
        final dslComponents = [
          QueryComponent(field: 'name', operator: 'Equal', isOr: false),
          QueryComponent(field: 'age', operator: 'GreaterThan', isOr: false)
        ];
        final sql = SqlGenerator.generateDslQuery(
            simpleMeta, dslComponents, 'find', ['name', 'age']);
        expect(sql, 'SELECT * FROM users WHERE name = @name AND age > @age');
      });

      test('Count query', () {
        final dslComponents = [
          QueryComponent(field: 'age', operator: 'GreaterThan', isOr: false)
        ];
        final sql = SqlGenerator.generateDslQuery(
            simpleMeta, dslComponents, 'count', ['age']);
        expect(sql, 'SELECT COUNT(*) FROM users WHERE age > @age');
      });

      test('Delete query', () {
        final dslComponents = [
          QueryComponent(field: 'name', operator: 'Equal', isOr: false)
        ];
        final sql = SqlGenerator.generateDslQuery(
            simpleMeta, dslComponents, 'delete', ['name']);
        expect(sql, 'DELETE FROM users WHERE name = @name');
      });

      test('Exists query', () {
        final dslComponents = [
          QueryComponent(field: 'name', operator: 'Equal', isOr: false)
        ];
        final sql = SqlGenerator.generateDslQuery(
            simpleMeta, dslComponents, 'exists', ['name']);
        expect(sql, 'SELECT EXISTS(SELECT 1 FROM users WHERE name = @name)');
      });
    });
  });
}
