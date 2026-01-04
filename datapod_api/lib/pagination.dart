// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

/// Sorting direction.
enum Direction {
  /// Ascending order.
  asc,

  /// Descending order.
  desc;

  /// Returns whether this direction is ascending.
  bool get isAscending => this == Direction.asc;

  /// Returns whether this direction is descending.
  bool get isDescending => this == Direction.desc;
}

/// Defines sorting for a single field.
class Sort {
  /// The field to sort by.
  final String field;

  /// The direction to sort.
  final Direction direction;

  const Sort(this.field, [this.direction = Direction.asc]);

  /// Creates an ascending sort.
  const Sort.asc(this.field) : direction = Direction.asc;

  /// Creates a descending sort.
  const Sort.desc(this.field) : direction = Direction.desc;
}

/// Pagination information.
class Pageable {
  /// The page number (0-indexed).
  final int page;

  /// The size of the page.
  final int size;

  /// Optional sorting.
  final List<Sort>? sort;

  const Pageable({
    this.page = 0,
    this.size = 20,
    this.sort,
  });

  /// The offset for the database query.
  int get offset => page * size;

  /// Creates a new Pageable with the given page number.
  Pageable withPage(int page) => Pageable(page: page, size: size, sort: sort);
}

/// A page of data.
class Page<T> {
  /// The items in this page.
  final List<T> items;

  /// The total number of items across all pages.
  final int totalElements;

  /// The current page number.
  final int pageNumber;

  /// The size of each page.
  final int pageSize;

  const Page({
    required this.items,
    required this.totalElements,
    required this.pageNumber,
    required this.pageSize,
  });

  /// The total number of pages.
  int get totalPages => (totalElements / pageSize).ceil();

  /// Whether there are more pages.
  bool get hasNext => pageNumber < totalPages - 1;

  /// Whether there are previous pages.
  bool get hasPrevious => pageNumber > 0;
}

/// Helper to apply sorting and pagination to a SQL query at runtime.
String applyPagination(
  String sql, {
  List<Sort>? sort,
  int? limit,
  int? offset,
  Map<String, String>? fieldToColumn,
}) {
  var result = sql;
  if (sort != null && sort.isNotEmpty) {
    final orderClauses = sort.map((s) {
      final column = fieldToColumn?[s.field] ?? s.field;
      return '$column ${s.direction == Direction.asc ? 'ASC' : 'DESC'}';
    }).join(', ');
    result += ' ORDER BY $orderClauses';
  }
  if (limit != null) {
    result += ' LIMIT $limit';
  }
  if (offset != null) {
    result += ' OFFSET $offset';
  }
  return result;
}
