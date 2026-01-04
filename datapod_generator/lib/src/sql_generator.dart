// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:source_gen/source_gen.dart';
import 'package:datapod_api/datapod_api.dart' show Sort, Direction;
import 'package:datapod_api/datapod_api.dart' as api;

class EntitySqlMetadata {
  final String tableName;
  final List<ColumnMetadata> columns;
  final ColumnMetadata? idColumn;
  final List<UniqueConstraintMetadata> uniqueConstraints;
  final List<IndexMetadata> indexes;

  EntitySqlMetadata({
    required this.tableName,
    required this.columns,
    this.idColumn,
    this.uniqueConstraints = const [],
    this.indexes = const [],
  });
}

class IndexMetadata {
  final String? name;
  final List<String> columns;
  final bool unique;

  IndexMetadata({this.name, required this.columns, this.unique = false});
}

class UniqueConstraintMetadata {
  final String? name;
  final List<String> columns;

  UniqueConstraintMetadata({this.name, required this.columns});
}

class JoinMetadata {
  final String property;
  final String tableName;
  final String joinColumn;
  final String referencedColumn;
  final String alias;
  final List<ColumnMetadata> columns;

  JoinMetadata({
    required this.property,
    required this.tableName,
    required this.joinColumn,
    required this.referencedColumn,
    required this.alias,
    required this.columns,
  });
}

class ColumnMetadata {
  final String fieldName;
  final String columnName;
  final bool isId;
  final bool autoIncrement;
  final String fieldType;
  final String? relatedTable;
  final String? relationType; // ManyToOne, OneToMany, OneToOne
  final String? relatedEntityType;
  final String? mappedBy;
  final bool cascadePersist;
  final bool cascadeRemove;
  final bool isJson;
  final bool isList;
  final List<String>? enumValues;
  final bool isNullable;
  final bool isCreatedAt;
  final bool isUpdatedAt;
  final String? converterType;

  ColumnMetadata({
    required this.fieldName,
    required this.columnName,
    required this.fieldType,
    this.isId = false,
    this.autoIncrement = false,
    this.relatedTable,
    this.relationType,
    this.relatedEntityType,
    this.mappedBy,
    this.cascadePersist = false,
    this.cascadeRemove = false,
    this.isJson = false,
    this.isList = false,
    this.enumValues,
    this.isNullable = true,
    this.isCreatedAt = false,
    this.isUpdatedAt = false,
    this.converterType,
  });
}

class SqlGenerator {
  static EntitySqlMetadata parseEntity(ClassElement element) {
    final entityAnnotation =
        const TypeChecker.fromRuntime(api.Entity).firstAnnotationOf(element);
    final reader = ConstantReader(entityAnnotation);
    final tableName =
        reader.peek('tableName')?.stringValue ?? _camelToSnake(element.name);

    final columns = <ColumnMetadata>[];
    ColumnMetadata? idColumn;
    final uniqueConstraints = <UniqueConstraintMetadata>[];
    final indexes = <IndexMetadata>[];

    // Class-level unique constraints
    final classUniqueAnns = const TypeChecker.fromRuntime(api.Unique)
        .annotationsOf(element)
        .map((a) => ConstantReader(a));
    for (final ann in classUniqueAnns) {
      final columns = ann
          .peek('columns')
          ?.listValue
          .map((v) => v.toStringValue()!)
          .toList();
      if (columns != null && columns.isNotEmpty) {
        uniqueConstraints.add(UniqueConstraintMetadata(
          name: ann.peek('name')?.stringValue,
          columns: columns,
        ));
      }
    }

    for (final field in element.fields) {
      if (field.isStatic || field.isSynthetic) continue;

      final columnAnn =
          const TypeChecker.fromRuntime(api.Column).firstAnnotationOf(field);
      final idAnn =
          const TypeChecker.fromRuntime(api.Id).firstAnnotationOf(field);
      final manyToOne =
          const TypeChecker.fromRuntime(api.ManyToOne).firstAnnotationOf(field);
      final oneToOne =
          const TypeChecker.fromRuntime(api.OneToOne).firstAnnotationOf(field);
      final oneToMany =
          const TypeChecker.fromRuntime(api.OneToMany).firstAnnotationOf(field);
      final createdAt =
          const TypeChecker.fromRuntime(api.CreatedAt).firstAnnotationOf(field);
      final updatedAt =
          const TypeChecker.fromRuntime(api.UpdatedAt).firstAnnotationOf(field);
      final convertAnn =
          const TypeChecker.fromRuntime(api.Convert).firstAnnotationOf(field);

      if (columnAnn == null &&
          idAnn == null &&
          manyToOne == null &&
          oneToOne == null &&
          oneToMany == null &&
          createdAt == null &&
          updatedAt == null &&
          convertAnn == null &&
          !_isPrimitive(field.type)) {
        continue; // Only process relevant fields
      }

      final colReader = ConstantReader(columnAnn);
      final idReader = ConstantReader(idAnn);

      final colName =
          colReader.peek('name')?.stringValue ?? _camelToSnake(field.name);
      final isId = idAnn != null;
      final autoIncrement =
          isId ? (idReader.peek('autoIncrement')?.boolValue ?? true) : false;

      String? relationType;
      String? relatedEntityType;
      String? mappedBy;
      bool cascadePersist = false;
      bool cascadeRemove = false;

      final relAnn = manyToOne ?? oneToOne ?? oneToMany;
      if (relAnn != null) {
        if (manyToOne != null) relationType = 'ManyToOne';
        if (oneToOne != null) relationType = 'OneToOne';
        if (oneToMany != null) relationType = 'OneToMany';

        final relReader = ConstantReader(relAnn);
        mappedBy = relReader.peek('mappedBy')?.stringValue;

        // Extract related entity type
        final type = field.type;
        if (type is InterfaceType) {
          if (type.isDartCoreList ||
              (type.isDartAsyncFuture &&
                  type.typeArguments.first is InterfaceType &&
                  (type.typeArguments.first as InterfaceType).isDartCoreList)) {
            // List<T> or Future<List<T>>
            final listType = type.isDartCoreList
                ? type
                : type.typeArguments.first as InterfaceType;
            relatedEntityType = listType.typeArguments.first.element?.name;
          } else if (type.isDartAsyncFuture) {
            relatedEntityType = type.typeArguments.first.element?.name;
          } else {
            relatedEntityType = type.element.name;
          }
        }

        final cascade = relReader.peek('cascade')?.listValue ?? [];
        for (final c in cascade) {
          final enumValue = c.getField('index')?.toIntValue();
          if (enumValue == 0) {
            // all
            cascadePersist = true;
            cascadeRemove = true;
          } else if (enumValue == 1) {
            // persist
            cascadePersist = true;
          } else if (enumValue == 2) {
            // remove
            cascadeRemove = true;
          }
        }
      }

      // OneToMany doesn't have a column in this table
      if (relationType == 'OneToMany') {
        final metadata = ColumnMetadata(
          fieldName: field.name,
          columnName: '', // No column
          fieldType: field.type.getDisplayString(withNullability: false),
          relationType: relationType,
          relatedEntityType: relatedEntityType,
          mappedBy: mappedBy,
          cascadePersist: cascadePersist,
          cascadeRemove: cascadeRemove,
          isNullable:
              field.type.nullabilitySuffix == NullabilitySuffix.question,
        );
        columns.add(metadata);
        continue;
      }

      final type = field.type;
      bool isList = false;
      bool isJson = false;
      List<String>? enumValues;
      String fieldTypeStr = type.getDisplayString(withNullability: false);

      if (type is InterfaceType) {
        if (type.element is EnumElement) {
          final enumElement = type.element as EnumElement;
          enumValues = enumElement.fields
              .where((f) => f.isEnumConstant)
              .map((f) => f.name)
              .toList();
        } else if (type.isDartCoreList || type.isDartCoreMap) {
          isJson = true;
          if (type.isDartCoreList) isList = true;
        } else if (!_isPrimitive(type) &&
            relationType == null &&
            convertAnn == null) {
          // Custom class not marked as entity, treat as JSON
          isJson = true;
        }
      }

      ColumnMetadata metadata = ColumnMetadata(
        fieldName: field.name,
        columnName:
            isId ? colName : (relationType != null ? '${colName}_id' : colName),
        fieldType: fieldTypeStr,
        isId: isId,
        autoIncrement: autoIncrement,
        relationType: relationType,
        relatedEntityType: relatedEntityType,
        relatedTable: relatedEntityType != null
            ? '${_camelToSnake(relatedEntityType)}s'
            : null, // Basic assumption for example project
        mappedBy: mappedBy,
        cascadePersist: cascadePersist,
        cascadeRemove: cascadeRemove,
        isJson: isJson,
        isList: isList,
        enumValues: enumValues,
        isNullable: field.type.nullabilitySuffix == NullabilitySuffix.question,
        isCreatedAt: createdAt != null,
        isUpdatedAt: updatedAt != null,
        converterType: convertAnn != null
            ? ConstantReader(convertAnn)
                .peek('converter')
                ?.typeValue
                .getDisplayString(withNullability: false)
            : null,
      );

      if (metadata.converterType != null) {
        final convertType =
            ConstantReader(convertAnn).peek('converter')!.typeValue;
        if (convertType is InterfaceType) {
          final converterBase = convertType.allSupertypes.firstWhere(
            (s) => s.element.name == 'AttributeConverter',
          );
          final dbType = converterBase.typeArguments[1]
              .getDisplayString(withNullability: false);

          // Update metadata with the database type
          final updated = ColumnMetadata(
            fieldName: metadata.fieldName,
            columnName: metadata.columnName,
            fieldType: dbType, // Use DB type for schema generation
            isId: metadata.isId,
            autoIncrement: metadata.autoIncrement,
            relationType: metadata.relationType,
            relatedEntityType: metadata.relatedEntityType,
            relatedTable: metadata.relatedTable,
            mappedBy: metadata.mappedBy,
            cascadePersist: metadata.cascadePersist,
            cascadeRemove: metadata.cascadeRemove,
            isJson: metadata.isJson,
            isList: metadata.isList,
            enumValues: metadata.enumValues,
            isNullable: metadata.isNullable,
            isCreatedAt: metadata.isCreatedAt,
            isUpdatedAt: metadata.isUpdatedAt,
            converterType: metadata.converterType,
          );
          columns.add(updated);
        } else {
          columns.add(metadata);
        }
      } else {
        columns.add(metadata);
      }

      final uniqueAnn =
          const TypeChecker.fromRuntime(api.Unique).firstAnnotationOf(field);
      if (uniqueAnn != null) {
        final reader = ConstantReader(uniqueAnn);
        uniqueConstraints.add(UniqueConstraintMetadata(
          name: reader.peek('name')?.stringValue,
          columns: [_camelToSnake(field.name)],
        ));
      }

      final indexAnn =
          const TypeChecker.fromRuntime(api.Index).firstAnnotationOf(field);
      if (indexAnn != null) {
        final reader = ConstantReader(indexAnn);
        indexes.add(IndexMetadata(
          name: reader.peek('name')?.stringValue,
          columns: [_camelToSnake(field.name)],
          unique: reader.peek('unique')?.boolValue ?? false,
        ));
      }

      if (isId) idColumn = columns.last;
    }

    // Class-level indexes
    final classIndexAnns = const TypeChecker.fromRuntime(api.Index)
        .annotationsOf(element)
        .map((a) => ConstantReader(a));
    for (final ann in classIndexAnns) {
      final cols = ann
          .peek('columns')
          ?.listValue
          .map((v) => v.toStringValue())
          .whereType<String>()
          .map((c) => _camelToSnake(c))
          .toList();
      if (cols != null && cols.isNotEmpty) {
        indexes.add(IndexMetadata(
          name: ann.peek('name')?.stringValue,
          columns: cols,
          unique: ann.peek('unique')?.boolValue ?? false,
        ));
      }
    }

    return EntitySqlMetadata(
      tableName: tableName,
      columns: columns,
      idColumn: idColumn,
      uniqueConstraints: uniqueConstraints,
      indexes: indexes,
    );
  }

  static api.TableDefinition generateTableDefinition(
      EntitySqlMetadata metadata) {
    return api.TableDefinition(
      name: metadata.tableName,
      columns: metadata.columns
          .where((c) => c.columnName.isNotEmpty)
          .map((c) => api.ColumnDefinition(
                name: c.columnName,
                type: c.relationType != null ? 'int' : c.fieldType,
                isNullable: c.isNullable,
                isAutoIncrement: c.autoIncrement,
                enumValues: c.enumValues,
                isJson: c.isJson,
                isList: c.isList,
              ))
          .toList(),
      primaryKey:
          metadata.idColumn != null ? [metadata.idColumn!.columnName] : [],
      foreignKeys: metadata.columns
          .where((c) => c.relationType != null && c.columnName.isNotEmpty)
          .map((c) => api.ForeignKeyDefinition(
                name: 'fk_${metadata.tableName}_${c.columnName}',
                columns: [c.columnName],
                referencedTable: c.relatedTable!,
                referencedColumns: ['id'],
                onDelete: c.cascadeRemove ? 'CASCADE' : null,
              ))
          .toList(),
      uniqueConstraints: metadata.uniqueConstraints.map((u) {
        final rawName = 'uidx_${metadata.tableName}_${u.columns.join('_')}';
        final name = u.name ??
            (rawName.length > 63 ? rawName.substring(0, 63) : rawName);
        return api.UniqueConstraintDefinition(
          name: name,
          columns: u.columns,
        );
      }).toList(),
      indexes: metadata.indexes.map((idx) {
        final rawName = 'idx_${metadata.tableName}_${idx.columns.join('_')}';
        final name = idx.name ??
            (rawName.length > 63 ? rawName.substring(0, 63) : rawName);
        return api.IndexDefinition(
          name: name,
          columns: idx.columns,
          unique: idx.unique,
        );
      }).toList(),
    );
  }

  static String generateInsert(EntitySqlMetadata metadata) {
    final cols = metadata.columns
        .where((c) => !c.autoIncrement && c.columnName.isNotEmpty)
        .toList();
    final names = cols.map((c) => c.columnName).join(', ');
    final placeholders = cols.map((c) {
      if (c.relationType != null) {
        return '@${c.fieldName}Id';
      }
      return '@${c.fieldName}';
    }).join(', ');
    var sql =
        'INSERT INTO ${metadata.tableName} ($names) VALUES ($placeholders)';
    if (metadata.idColumn?.autoIncrement ?? false) {
      sql += ' RETURNING ${metadata.idColumn!.columnName}';
    }
    return sql;
  }

  static String generateUpdate(EntitySqlMetadata metadata) {
    if (metadata.idColumn == null) {
      throw Exception('Cannot update entity without ID');
    }
    final cols = metadata.columns
        .where((c) => !c.isId && c.columnName.isNotEmpty)
        .toList();
    final sets = cols.map((c) {
      if (c.relationType != null) {
        return '${c.columnName} = @${c.fieldName}Id';
      }
      return '${c.columnName} = @${c.fieldName}';
    }).join(', ');
    return 'UPDATE ${metadata.tableName} SET $sets WHERE ${metadata.idColumn!.columnName} = @${metadata.idColumn!.fieldName}';
  }

  static String generateDelete(EntitySqlMetadata metadata) {
    if (metadata.idColumn == null) {
      throw Exception('Cannot delete entity without ID');
    }
    return 'DELETE FROM ${metadata.tableName} WHERE ${metadata.idColumn!.columnName} = @id';
  }

  static String generateFindById(EntitySqlMetadata metadata) {
    if (metadata.idColumn == null) {
      throw Exception('Cannot find entity without ID');
    }
    return 'SELECT * FROM ${metadata.tableName} WHERE ${metadata.idColumn!.columnName} = @id';
  }

  static String generateDslQuery(
    EntitySqlMetadata metadata,
    List<dynamic> components,
    String type,
    List<String> parameterNames, {
    List<Sort>? sort,
    int? limit,
    int? offset,
    List<JoinMetadata>? joins,
  }) {
    String sql;
    final mainAlias = joins != null && joins.isNotEmpty ? 't0' : '';
    final selectAlias = mainAlias.isNotEmpty ? '$mainAlias.' : '';

    String selectClause;
    if (joins != null && joins.isNotEmpty) {
      final selectList = <String>[];
      // Select all from main table
      for (final col in metadata.columns) {
        if (col.columnName.isNotEmpty) {
          selectList.add('$mainAlias.${col.columnName} AS ${col.columnName}');
        }
      }
      // Select from joined tables
      for (final join in joins) {
        for (final col in join.columns) {
          if (col.columnName.isNotEmpty) {
            selectList.add(
                '${join.alias}.${col.columnName} AS ${join.alias}_${col.columnName}');
          }
        }
      }
      selectClause = selectList.join(', ');
    } else {
      selectClause = '*';
    }

    switch (type) {
      case 'count':
        sql = 'SELECT COUNT(*) FROM ${metadata.tableName}';
        break;
      case 'delete':
        sql = 'DELETE FROM ${metadata.tableName}';
        break;
      case 'exists':
        sql =
            'SELECT EXISTS(SELECT 1 FROM ${metadata.tableName}${mainAlias.isNotEmpty ? ' $mainAlias' : ''}';
        break;
      default:
        sql =
            'SELECT $selectClause FROM ${metadata.tableName}${mainAlias.isNotEmpty ? ' $mainAlias' : ''}';
    }

    if (joins != null && joins.isNotEmpty) {
      for (final join in joins) {
        sql +=
            ' LEFT JOIN ${join.tableName} ${join.alias} ON $mainAlias.${join.joinColumn} = ${join.alias}.${join.referencedColumn}';
      }
    }

    if (components.isNotEmpty) {
      sql += ' WHERE ';
      for (var i = 0; i < components.length; i++) {
        final comp = components[i];
        if (i > 0) {
          sql += comp.isOr ? ' OR ' : ' AND ';
        }

        final column = metadata.columns.firstWhere(
          (c) => c.fieldName == comp.field,
          orElse: () => throw Exception(
              'Field ${comp.field} not found in entity for table ${metadata.tableName}'),
        );

        final paramName = parameterNames[i];
        sql += _generateOperatorSql(
            '$selectAlias${column.columnName}', comp.operator, paramName);
      }
    }

    if (type == 'exists') {
      sql += ')';
    }

    if (sort != null && sort.isNotEmpty) {
      final orderClauses = <String>[];
      for (final s in sort) {
        final column = metadata.columns.firstWhere(
          (c) => c.fieldName == s.field,
          orElse: () => throw Exception(
              'Field ${s.field} not found in entity for table ${metadata.tableName}'),
        );
        orderClauses.add(
            '$selectAlias${column.columnName} ${s.direction == Direction.asc ? 'ASC' : 'DESC'}');
      }
      sql += ' ORDER BY ${orderClauses.join(', ')}';
    }

    if (limit != null) {
      sql += ' LIMIT $limit';
    }
    if (offset != null) {
      sql += ' OFFSET $offset';
    }

    return sql;
  }

  static String _generateOperatorSql(
      String column, String operator, String paramName) {
    switch (operator) {
      case 'IsNull':
        return '$column IS NULL';
      case 'IsNotNull':
        return '$column IS NOT NULL';
      case 'IsEmpty':
        return "$column = ''";
      case 'IsNotEmpty':
        return "$column != ''";
      case 'True':
        return '$column = TRUE';
      case 'False':
        return '$column = FALSE';
      case 'Like':
        return '$column LIKE @$paramName';
      case 'NotLike':
        return '$column NOT LIKE @$paramName';
      case 'StartsWith':
        return '$column LIKE @$paramName'; // Caller must append % to param
      case 'EndsWith':
        return '$column LIKE @$paramName'; // Caller must prepend % to param
      case 'Contains':
      case 'Containing':
        return '$column LIKE @$paramName'; // Caller must wrap with % to param
      case 'NotContains':
      case 'NotContaining':
        return '$column NOT LIKE @$paramName';
      case 'In':
        return '$column IN (@$paramName)';
      case 'NotIn':
        return '$column NOT IN (@$paramName)';
      case 'GreaterThan':
        return '$column > @$paramName';
      case 'GreaterThanOrEqual':
        return '$column >= @$paramName';
      case 'LessThan':
        return '$column < @$paramName';
      case 'LessThanOrEqual':
        return '$column <= @$paramName';
      case 'Not':
        return '$column != @$paramName';
      default:
        return '$column = @$paramName';
    }
  }

  static String _camelToSnake(String name) {
    return name
        .replaceAllMapped(
            RegExp(r'([a-z])([A-Z])'), (Match m) => '${m[1]}_${m[2]}')
        .toLowerCase();
  }

  static ColumnMetadata parseColumn(FieldElement field) {
    final columnAnn =
        const TypeChecker.fromRuntime(api.Column).firstAnnotationOf(field);
    final idAnn =
        const TypeChecker.fromRuntime(api.Id).firstAnnotationOf(field);
    final manyToOne =
        const TypeChecker.fromRuntime(api.ManyToOne).firstAnnotationOf(field);
    final oneToOne =
        const TypeChecker.fromRuntime(api.OneToOne).firstAnnotationOf(field);

    final colReader = ConstantReader(columnAnn);
    final idReader = ConstantReader(idAnn);

    final colName =
        colReader.peek('name')?.stringValue ?? _camelToSnake(field.name);
    final isId = idAnn != null;
    final autoIncrement = idReader.peek('autoIncrement')?.boolValue ?? true;

    String? relationType;
    if (manyToOne != null) relationType = 'ManyToOne';
    if (oneToOne != null) relationType = 'OneToOne';

    return ColumnMetadata(
      fieldName: field.name,
      columnName:
          isId ? colName : (relationType != null ? '${colName}_id' : colName),
      fieldType: field.type.getDisplayString(withNullability: false),
      isId: isId,
      autoIncrement: autoIncrement,
      relationType: relationType,
    );
  }

  static bool _isPrimitive(DartType type) {
    return type.isDartCoreInt ||
        type.isDartCoreDouble ||
        type.isDartCoreString ||
        type.isDartCoreBool ||
        type.getDisplayString(withNullability: false) == 'DateTime';
  }
}
