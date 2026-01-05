// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:test/test.dart';
import 'package:datapod_api/datapod_api.dart';

void main() {
  group('Pagination Tests', () {
    group('Direction', () {
      test('isAscending/isDescending should work correctly', () {
        expect(Direction.asc.isAscending, isTrue);
        expect(Direction.asc.isDescending, isFalse);
        expect(Direction.desc.isAscending, isFalse);
        expect(Direction.desc.isDescending, isTrue);
      });
    });

    group('Sort', () {
      test('Constructors should set fields correctly', () {
        const s1 = Sort('name');
        expect(s1.field, 'name');
        expect(s1.direction, Direction.asc);

        const s2 = Sort('age', Direction.desc);
        expect(s2.field, 'age');
        expect(s2.direction, Direction.desc);

        const s3 = Sort.asc('title');
        expect(s3.field, 'title');
        expect(s3.direction, Direction.asc);

        const s4 = Sort.desc('created');
        expect(s4.field, 'created');
        expect(s4.direction, Direction.desc);
      });
    });

    group('Pageable', () {
      test('defaults should be correct', () {
        const p = Pageable();
        expect(p.page, 0);
        expect(p.size, 20);
        expect(p.sort, isNull);
        expect(p.offset, 0);
      });

      test('custom values should be respected', () {
        const p = Pageable(page: 2, size: 10);
        expect(p.page, 2);
        expect(p.size, 10);
        expect(p.offset, 20);
      });

      test('withPage should return new instance with updated page', () {
        const p1 = Pageable(page: 1, size: 50);
        final p2 = p1.withPage(5);
        expect(p2.page, 5);
        expect(p2.size, 50);
        expect(p2.offset, 250);
      });
    });

    group('Page', () {
      test('properties should be calculated correctly', () {
        const page = Page(
          items: ['a', 'b'],
          totalElements: 10,
          pageNumber: 0,
          pageSize: 2,
        );
        expect(page.totalPages, 5);
        expect(page.hasNext, isTrue);
        expect(page.hasPrevious, isFalse);
      });

      test('edge case calculations', () {
        const page = Page(
          items: [],
          totalElements: 9,
          pageNumber: 2,
          pageSize: 3,
        );
        // Pages: 0, 1, 2. Total 3 pages. Current is last.
        expect(page.totalPages, 3);
        expect(page.hasNext, isFalse);
        expect(page.hasPrevious, isTrue);
      });
    });

    group('applyPagination', () {
      test('should append LIMIT and OFFSET', () {
        final sql = applyPagination('SELECT * FROM t', limit: 10, offset: 5);
        expect(sql, endsWith(' LIMIT 10 OFFSET 5'));
      });

      test('should append ORDER BY', () {
        final sql = applyPagination('SELECT * FROM t', sort: [Sort.desc('id')]);
        expect(sql, endsWith(' ORDER BY id DESC'));
      });

      test('should map fields to columns', () {
        final sql = applyPagination(
          'SELECT * FROM t',
          sort: [Sort.asc('userName')],
          fieldToColumn: {'userName': 'user_name'},
        );
        expect(sql, endsWith(' ORDER BY user_name ASC'));
      });

      test('should combine all clauses', () {
        final sql = applyPagination(
          'SELECT * FROM t',
          sort: [Sort.asc('a')],
          limit: 10,
          offset: 0,
        );
        expect(sql, contains('ORDER BY a ASC'));
        expect(sql, contains('LIMIT 10'));
        expect(sql, contains('OFFSET 0'));
      });
    });
  });
}
