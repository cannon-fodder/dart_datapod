// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:datapod_api/datapod_api.dart' as api;
import 'package:source_gen/source_gen.dart';
import 'package:code_builder/code_builder.dart';
import 'sql_generator.dart';

class EntityGenerator extends GeneratorForAnnotation<api.Entity> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) return '';

    final result = StringBuffer();
    result.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
    result.writeln("//");
    result.writeln(
      "// This software is provided \"as is\", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.",
    );
    result.writeln(
      '// ignore_for_file: prefer_interpolation_to_compose_strings, duplicate_ignore',
    );
    result.writeln();
    result.writeln(_generateManagedEntity(element));
    result.writeln();
    result.writeln(_generateMapper(element));

    return result.toString();
  }

  String _generateManagedEntity(ClassElement entityClass) {
    final metadata = SqlGenerator.parseEntity(entityClass);
    final className = 'Managed${entityClass.name!}';
    final managedClass = Class(
      (b) => b
        ..name = className
        ..extend = refer(entityClass.name!)
        ..implements.add(
          refer('ManagedEntity', 'package:datapod_api/datapod_api.dart'),
        )
        ..fields.addAll([
          Field(
            (f) => f
              ..name = '_isManaged'
              ..type = refer('bool')
              ..modifier = FieldModifier.final$
              ..assignment = Code('true'),
          ),
          Field(
            (f) => f
              ..name = '_isPersistent'
              ..type = refer('bool')
              ..assignment = Code('false'),
          ),
          Field(
            (f) => f
              ..name = '_isDirty'
              ..type = refer('bool')
              ..assignment = Code('false'),
          ),
          Field(
            (f) => f
              ..name = '_database'
              ..type = refer(
                'DatapodDatabase?',
                'package:datapod_api/datapod_api.dart',
              ),
          ),
          Field(
            (f) => f
              ..name = '_relationshipContext'
              ..type = refer(
                'RelationshipContext?',
                'package:datapod_api/datapod_api.dart',
              ),
          ),
          ..._generateRelationFields(entityClass),
        ])
        ..constructors.addAll([
          Constructor((c) => c),
          Constructor(
            (c) => c
              ..name = 'fromRow'
              ..requiredParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'row'
                    ..type = refer('Map<String, dynamic>'),
                ),
              )
              ..requiredParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'database'
                    ..type = refer(
                      'DatapodDatabase',
                      'package:datapod_api/datapod_api.dart',
                    ),
                ),
              )
              ..requiredParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'relationshipContext'
                    ..type = refer(
                      'RelationshipContext',
                      'package:datapod_api/datapod_api.dart',
                    ),
                ),
              )
              ..optionalParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'aliasPrefix'
                    ..type = refer('String')
                    ..named = true
                    ..defaultTo = Code("''"),
                ),
              )
              ..initializers.add(Code('_database = database'))
              ..initializers.add(
                Code('_relationshipContext = relationshipContext'),
              )
              ..body = Block.of([
                Code('_isPersistent = true;'),
                ...metadata.columns
                    .where(
                      (c) => c.columnName.isNotEmpty && c.relationType == null,
                    )
                    .map((c) {
                      final colName = c.columnName;
                      final fieldName = c.fieldName;
                      if (c.converterType != null) {
                        return Code(
                          'super.$fieldName = row[aliasPrefix + "$colName"] != null ? const ${c.converterType}().convertToEntityAttribute(row[aliasPrefix + "$colName"]) : null;',
                        );
                      }
                      if (c.fieldType == 'DateTime') {
                        return Code(
                          'super.$fieldName = row[aliasPrefix + "$colName"] is String ? DateTime.parse(row[aliasPrefix + "$colName"]) : row[aliasPrefix + "$colName"];',
                        );
                      }
                      if (c.fieldType == 'bool') {
                        return Code(
                          'super.$fieldName = row[aliasPrefix + "$colName"] is int ? row[aliasPrefix + "$colName"] == 1 : row[aliasPrefix + "$colName"];',
                        );
                      }
                      if (c.isJson || c.isList) {
                        if (c.isList) {
                          return Code(
                            'super.$fieldName = row[aliasPrefix + "$colName"] is String ? (jsonDecode(row[aliasPrefix + "$colName"]) as List?)?.cast<String>() : (row[aliasPrefix + "$colName"] != null ? List<String>.from(row[aliasPrefix + "$colName"]) : null);',
                          );
                        }
                        return Code(
                          'super.$fieldName = row[aliasPrefix + "$colName"] is String ? (jsonDecode(row[aliasPrefix + "$colName"]) as Map?)?.cast<String, dynamic>() : (row[aliasPrefix + "$colName"] != null ? Map<String, dynamic>.from(row[aliasPrefix + "$colName"]) : null);',
                        );
                      }
                      if (c.enumValues != null) {
                        return Code(
                          'super.$fieldName = row[aliasPrefix + "$colName"] != null ? ${c.fieldType.replaceAll('?', '')}.values.firstWhere((e) => e.name == row[aliasPrefix + "$colName"]) : super.$fieldName;',
                        );
                      }
                      return Code(
                        'super.$fieldName = row[aliasPrefix + "$colName"];',
                      );
                    }),
                ..._generateRelationFieldInitializers(
                  entityClass,
                  'aliasPrefix',
                ),
              ]),
          ),
          Constructor(
            (c) => c
              ..name = 'fromEntity'
              ..requiredParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'entity'
                    ..type = refer(entityClass.name!),
                ),
              )
              ..requiredParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'database'
                    ..type = refer(
                      'DatapodDatabase',
                      'package:datapod_api/datapod_api.dart',
                    ),
                ),
              )
              ..requiredParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'relationshipContext'
                    ..type = refer(
                      'RelationshipContext',
                      'package:datapod_api/datapod_api.dart',
                    ),
                ),
              )
              ..initializers.add(Code('_database = database'))
              ..initializers.add(
                Code('_relationshipContext = relationshipContext'),
              )
              ..body = Block.of([
                Code(
                  '_isPersistent = entity is ManagedEntity ? (entity as ManagedEntity).isPersistent : false;',
                ),
                ...entityClass.fields
                    .where(
                      (f) => !f.isStatic && !f.isSynthetic && !_isRelation(f),
                    )
                    .map((f) => Code('super.${f.name} = entity.${f.name};')),
                ..._generateRelationFieldCopyInitializers(entityClass),
              ]),
          ),
        ])
        ..methods.addAll([
          Method(
            (m) => m
              ..name = 'isManaged'
              ..type = MethodType.getter
              ..annotations.add(refer('override'))
              ..returns = refer('bool')
              ..body = refer('_isManaged').code,
          ),
          Method(
            (m) => m
              ..name = 'isPersistent'
              ..type = MethodType.getter
              ..annotations.add(refer('override'))
              ..returns = refer('bool')
              ..body = refer('_isPersistent').code,
          ),
          Method(
            (m) => m
              ..name = 'isDirty'
              ..type = MethodType.getter
              ..annotations.add(refer('override'))
              ..returns = refer('bool')
              ..body = refer('_isDirty').code,
          ),
          Method(
            (m) => m
              ..name = 'markPersistent'
              ..annotations.add(refer('override'))
              ..body = Code('_isPersistent = true;'),
          ),
          Method(
            (m) => m
              ..name = 'markDirty'
              ..annotations.add(refer('override'))
              ..body = Code('_isDirty = true;'),
          ),
          Method(
            (m) => m
              ..name = 'clearDirty'
              ..annotations.add(refer('override'))
              ..body = Code('_isDirty = false;'),
          ),
          Method(
            (m) => m
              ..name = '\$database'
              ..type = MethodType.getter
              ..annotations.add(refer('override'))
              ..returns = refer(
                'DatapodDatabase?',
                'package:datapod_api/datapod_api.dart',
              )
              ..body = refer('_database').code,
          ),
          Method(
            (m) => m
              ..name = '\$database'
              ..type = MethodType.setter
              ..annotations.add(refer('override'))
              ..requiredParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'value'
                    ..type = refer(
                      'DatapodDatabase?',
                      'package:datapod_api/datapod_api.dart',
                    ),
                ),
              )
              ..body = Code('_database = value;'),
          ),
          Method(
            (m) => m
              ..name = '\$relationshipContext'
              ..type = MethodType.getter
              ..annotations.add(refer('override'))
              ..returns = refer(
                'RelationshipContext?',
                'package:datapod_api/datapod_api.dart',
              )
              ..body = refer('_relationshipContext').code,
          ),
          Method(
            (m) => m
              ..name = '\$relationshipContext'
              ..type = MethodType.setter
              ..annotations.add(refer('override'))
              ..requiredParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'value'
                    ..type = refer(
                      'RelationshipContext?',
                      'package:datapod_api/datapod_api.dart',
                    ),
                ),
              )
              ..body = Code('_relationshipContext = value;'),
          ),
          Method(
            (m) => m
              ..name = r'$id'
              ..type = MethodType.getter
              ..annotations.add(refer('override'))
              ..returns = refer('dynamic')
              ..body = refer(metadata.idColumn?.fieldName ?? 'null').code,
          ),
          ...entityClass.fields
              .where((f) => !f.isStatic && !f.isSynthetic && !_isRelation(f))
              .map(
                (f) => Method(
                  (m) => m
                    ..name = f.name
                    ..type = MethodType.setter
                    ..annotations.add(refer('override'))
                    ..requiredParameters.add(
                      Parameter(
                        (p) => p
                          ..name = 'value'
                          ..type = refer(f.type.getDisplayString()),
                      ),
                    )
                    ..body = Block.of([
                      Code('if (value != super.${f.name}) {'),
                      Code('  _isDirty = true;'),
                      Code('  super.${f.name} = value;'),
                      Code('}'),
                    ]),
                ),
              ),
          ..._generateRelationMethods(entityClass),
        ]),
    );

    final emitter = DartEmitter();
    return managedClass.accept(emitter).toString();
  }

  Iterable<Method> _generateRelationMethods(ClassElement entityClass) {
    final methods = <Method>[];
    for (final field in entityClass.fields) {
      if (field.isStatic || field.isSynthetic) continue;

      final isManyToOne = TypeChecker.fromUrl(
        'package:datapod_api/annotations.dart#ManyToOne',
      ).hasAnnotationOfExact(field);
      final oneToMany = TypeChecker.fromUrl(
        'package:datapod_api/annotations.dart#OneToMany',
      ).firstAnnotationOf(field);
      final oneToOne = TypeChecker.fromUrl(
        'package:datapod_api/annotations.dart#OneToOne',
      ).firstAnnotationOf(field);

      if (isManyToOne || oneToMany != null || oneToOne != null) {
        final isLazy = _isFuture(field.type);
        final relatedType = _getRelatedType(field.type);

        if (isManyToOne) {
          methods.addAll(
            _generateManyToOneMethods(field, relatedType, isLazy, entityClass),
          );
        } else if (oneToMany != null) {
          methods.addAll(
            _generateOneToManyMethods(field, relatedType, isLazy, entityClass),
          );
        } else if (oneToOne != null) {
          methods.addAll(
            _generateOneToOneMethods(field, relatedType, isLazy, entityClass),
          );
        }
      }
    }
    return methods;
  }

  bool _isFuture(DartType type) {
    return type.isDartAsyncFuture || type.isDartAsyncFutureOr;
  }

  DartType _getRelatedType(DartType type) {
    if (_isFuture(type) &&
        type is InterfaceType &&
        type.typeArguments.isNotEmpty) {
      final inner = type.typeArguments[0];
      if (inner is InterfaceType &&
          inner.isDartCoreList &&
          inner.typeArguments.isNotEmpty) {
        return inner.typeArguments[0];
      }
      return inner;
    }
    if (type is InterfaceType &&
        type.isDartCoreList &&
        type.typeArguments.isNotEmpty) {
      return type.typeArguments[0];
    }
    return type;
  }

  Iterable<Method> _generateManyToOneMethods(
    FieldElement field,
    DartType relatedType,
    bool isLazy,
    ClassElement owningEntity,
  ) {
    final methods = <Method>[];
    final foreignKeyField = '${field.name}Id';
    final loadedField =
        '_loaded${(field.name!)[0].toUpperCase()}${(field.name!).substring(1)}';

    methods.add(
      Method(
        (m) => m
          ..name = field.name
          ..type = MethodType.getter
          ..annotations.add(refer('override'))
          ..returns = refer(field.type.getDisplayString())
          ..body = Block.of([
            Code('final context = \$relationshipContext;'),
            Code('final db = \$database;'),
            Code(
              'if ($loadedField == null  && context != null && db != null) {',
            ),
            Code(
              '  final ops = context.getOperations<${relatedType.element?.name}, dynamic>();',
            ),
            Code(
              '  final mapper = context.getMapper<${relatedType.element?.name}>();',
            ),
            Code('  if ($foreignKeyField == null) {'),
            Code(
              '    $loadedField = Future<${relatedType.getDisplayString()}>.value(null);',
            ),
            Code('  } else {'),
            Code(
              '    $loadedField = ops.findById($foreignKeyField).then<${relatedType.getDisplayString()}>((result) {',
            ),
            Code('      if (result.isNotEmpty) {'),
            Code(
              '        return mapper.mapRow(result.rows.first, db, context);',
            ),
            Code('      }'),
            Code('      return null;'),
            Code('    });'),
            Code('  }'),
            Code('}'),
            Code('return $loadedField;'),
          ]),
      ),
    );

    methods.add(
      Method(
        (m) => m
          ..name = field.name
          ..type = MethodType.setter
          ..annotations.add(refer('override'))
          ..requiredParameters.add(
            Parameter(
              (p) => p
                ..name = 'value'
                ..type = refer(field.type.getDisplayString()),
            ),
          )
          ..body = Block.of([
            Code('if (value != $loadedField) {'),
            Code('  $loadedField = value;'),
            Code('  _isDirty = true;'),
            if (!isLazy) ...[
              Code('  if (value is ManagedEntity && value.isPersistent) {'),
              Code('    $foreignKeyField = value.\$id;'),
              Code('  }'),
            ],
            Code('}'),
          ]),
      ),
    );

    return methods;
  }

  Iterable<Method> _generateOneToManyMethods(
    FieldElement field,
    DartType relatedType,
    bool isLazy,
    ClassElement owningEntity,
  ) {
    final methods = <Method>[];
    final loadedField =
        '_loaded${(field.name!)[0].toUpperCase()}${(field.name!).substring(1)}';

    final oneToManyAnn = TypeChecker.fromUrl(
      'package:datapod_api/annotations.dart#OneToMany',
    ).firstAnnotationOf(field);
    final mappedBy = oneToManyAnn?.getField('mappedBy')?.toStringValue();
    final lookupField = mappedBy ?? (owningEntity.name!).toLowerCase();
    final methodName =
        'findBy${lookupField[0].toUpperCase()}${lookupField.substring(1)}Id';

    methods.add(
      Method(
        (m) => m
          ..name = field.name
          ..type = MethodType.getter
          ..annotations.add(refer('override'))
          ..returns = refer(field.type.getDisplayString())
          ..body = Block.of([
            Code('final context = \$relationshipContext;'),
            Code('final db = \$database;'),
            Code(
              'if ($loadedField == null  && context != null && db != null) {',
            ),
            Code(
              '  final ops = context.getOperations<${relatedType.element?.name}, dynamic>();',
            ),
            Code(
              '  final mapper = context.getMapper<${relatedType.element?.name}>();',
            ),
            Code('  if (id == null) {'),
            Code(
              '    $loadedField = Future<List<${relatedType.getDisplayString()}>>.value([]);',
            ),
            Code('  } else {'),
            Code(
              '    $loadedField = (ops as dynamic).$methodName(id!).then<List<${relatedType.getDisplayString()}>>((result) {',
            ),
            Code('      return mapper.mapRows(result.rows, db, context);'),
            Code('    });'),
            Code('  }'),
            Code('}'),
            Code('return $loadedField;'),
          ]),
      ),
    );

    methods.add(
      Method(
        (m) => m
          ..name = field.name
          ..type = MethodType.setter
          ..annotations.add(refer('override'))
          ..requiredParameters.add(Parameter((p) => p..name = 'value'))
          ..body = Block.of([
            Code('if ($loadedField != value) {'),
            Code('  $loadedField = value;'),
            Code('  markDirty();'),
            Code('}'),
          ]),
      ),
    );

    return methods;
  }

  Iterable<Method> _generateOneToOneMethods(
    FieldElement field,
    DartType relatedType,
    bool isLazy,
    ClassElement owningEntity,
  ) {
    return _generateManyToOneMethods(field, relatedType, isLazy, owningEntity);
  }

  bool _isRelation(FieldElement field) {
    return TypeChecker.fromUrl(
          'package:datapod_api/annotations.dart#ManyToOne',
        ).hasAnnotationOf(field) ||
        TypeChecker.fromUrl(
          'package:datapod_api/annotations.dart#OneToMany',
        ).hasAnnotationOf(field) ||
        TypeChecker.fromUrl(
          'package:datapod_api/annotations.dart#OneToOne',
        ).hasAnnotationOf(field);
  }

  Iterable<Field> _generateRelationFields(ClassElement entityClass) {
    final fields = <Field>[];
    for (final field in entityClass.fields) {
      if (field.isStatic || field.isSynthetic || !_isRelation(field)) continue;

      final loadedField =
          '_loaded${(field.name!)[0].toUpperCase()}${(field.name!).substring(1)}';
      fields.add(
        Field(
          (f) => f
            ..name = loadedField
            ..type = refer(field.type.getDisplayString()),
        ),
      );

      if (TypeChecker.fromUrl(
            'package:datapod_api/annotations.dart#ManyToOne',
          ).hasAnnotationOf(field) ||
          TypeChecker.fromUrl(
            'package:datapod_api/annotations.dart#OneToOne',
          ).hasAnnotationOf(field)) {
        final foreignKeyField = '${field.name}Id';
        fields.add(
          Field(
            (f) => f
              ..name = foreignKeyField
              ..type = refer('dynamic'),
          ),
        );
      }
    }
    return fields;
  }

  Iterable<Code> _generateRelationFieldInitializers(
    ClassElement entityClass,
    String aliasPrefix,
  ) {
    final codes = <Code>[];
    for (final field in entityClass.fields) {
      if (field.isStatic || field.isSynthetic || !_isRelation(field)) continue;

      if (TypeChecker.fromUrl(
            'package:datapod_api/annotations.dart#ManyToOne',
          ).hasAnnotationOf(field) ||
          TypeChecker.fromUrl(
            'package:datapod_api/annotations.dart#OneToOne',
          ).hasAnnotationOf(field)) {
        final colName = SqlGenerator.parseColumn(field).columnName;
        codes.add(
          Code(
            '${field.name}Id = row[aliasPrefix + "$colName"] ?? row["${field.name}Id"];',
          ),
        );
      }
    }
    return codes;
  }

  Iterable<Code> _generateRelationFieldCopyInitializers(
    ClassElement entityClass,
  ) {
    final codes = <Code>[];
    for (final field in entityClass.fields) {
      if (field.isStatic || field.isSynthetic || !_isRelation(field)) continue;

      codes.add(Code('${field.name} = entity.${field.name};'));

      if (TypeChecker.fromUrl(
            'package:datapod_api/annotations.dart#ManyToOne',
          ).hasAnnotationOf(field) ||
          TypeChecker.fromUrl(
            'package:datapod_api/annotations.dart#OneToOne',
          ).hasAnnotationOf(field)) {
        codes.add(
          Code(
            'if (entity is ManagedEntity) { ${field.name}Id = (entity as dynamic).${field.name}Id; }',
          ),
        );
      }
    }
    return codes;
  }

  String _generateMapper(ClassElement entityClass) {
    final className = '${entityClass.name!}MapperImpl';
    final mapperClass = Class(
      (b) => b
        ..name = className
        ..extend = refer(
          'EntityMapper<${entityClass.name!}>',
          'package:datapod_api/datapod_api.dart',
        )
        ..methods.add(
          Method(
            (m) => m
              ..name = 'mapRow'
              ..annotations.add(refer('override'))
              ..returns = refer(entityClass.name!)
              ..requiredParameters.addAll([
                Parameter(
                  (p) => p
                    ..name = 'row'
                    ..type = refer('Map<String, dynamic>'),
                ),
                Parameter(
                  (p) => p
                    ..name = 'database'
                    ..type = refer(
                      'DatapodDatabase',
                      'package:datapod_api/datapod_api.dart',
                    ),
                ),
                Parameter(
                  (p) => p
                    ..name = 'relationshipContext'
                    ..type = refer(
                      'RelationshipContext',
                      'package:datapod_api/datapod_api.dart',
                    ),
                ),
              ])
              ..optionalParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'aliasPrefix'
                    ..type = refer('String')
                    ..named = true
                    ..defaultTo = Code("''"),
                ),
              )
              ..body = Code(
                'return Managed${entityClass.name!}.fromRow(row, database, relationshipContext, aliasPrefix: aliasPrefix);',
              ),
          ),
        ),
    );

    final emitter = DartEmitter();
    return mapperClass.accept(emitter).toString();
  }
}
