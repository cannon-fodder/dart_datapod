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
import 'dsl_parser.dart';

class RepositoryGenerator extends GeneratorForAnnotation<api.Repository> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement || !element.isAbstract) {
      throw InvalidGenerationSourceError(
        '@Repository can only be applied to abstract classes.',
        element: element,
      );
    }

    final superType = element.allSupertypes.firstWhere(
      (t) => t.element.name == 'BaseRepository',
      orElse: () => throw InvalidGenerationSourceError(
        'Repository must extend BaseRepository<E, K>',
        element: element,
      ),
    );

    final entityType = superType.typeArguments[0];
    final keyType = superType.typeArguments[1];
    final entityClass = entityType.element as ClassElement;

    final metadata = SqlGenerator.parseEntity(entityClass);
    final result = StringBuffer();
    result.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
    result.writeln("//");
    result.writeln(
        "// This software is provided \"as is\", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.");
    result.writeln();
    result.writeln(_generateOperationsImpl(element, entityClass, metadata));
    result.writeln();
    result.writeln(
        _generateRepositoryImpl(element, entityClass, keyType, metadata));

    return result.toString();
  }

  String _generateOperationsImpl(ClassElement repoInterface,
      ClassElement entityClass, EntitySqlMetadata metadata) {
    final className = '${repoInterface.name}OperationsImpl';
    final opsClass = Class((b) => b
      ..name = className
      ..implements.add(refer('DatabaseOperations<${entityClass.name}>',
          'package:datapod_api/datapod_api.dart'))
      ..fields.addAll([
        Field((f) => f
          ..name = 'database'
          ..type =
              refer('DatapodDatabase', 'package:datapod_api/datapod_api.dart')
          ..modifier = FieldModifier.final$),
        Field((f) => f
          ..name = 'relationshipContext'
          ..type = refer(
              'RelationshipContext', 'package:datapod_api/datapod_api.dart')
          ..modifier = FieldModifier.final$),
        Field((f) => f
          ..name = '_insertSql'
          ..static = true
          ..modifier = FieldModifier.constant
          ..assignment = Code("'${SqlGenerator.generateInsert(metadata)}'")),
        Field((f) => f
          ..name = '_updateSql'
          ..static = true
          ..modifier = FieldModifier.constant
          ..assignment = Code("'${SqlGenerator.generateUpdate(metadata)}'")),
        Field((f) => f
          ..name = '_deleteSql'
          ..static = true
          ..modifier = FieldModifier.constant
          ..assignment = Code("'${SqlGenerator.generateDelete(metadata)}'")),
        Field((f) => f
          ..name = '_findByIdSql'
          ..static = true
          ..modifier = FieldModifier.constant
          ..assignment = Code("'${SqlGenerator.generateFindById(metadata)}'")),
      ])
      ..constructors.add(Constructor((c) => c
        ..requiredParameters.addAll([
          Parameter((p) => p
            ..name = 'database'
            ..toThis = true),
          Parameter((p) => p
            ..name = 'relationshipContext'
            ..toThis = true),
        ])))
      ..methods.addAll([
        Method((m) => m
          ..name = 'findById'
          ..annotations.add(refer('override'))
          ..returns = refer(
              'Future<QueryResult>', 'package:datapod_api/datapod_api.dart')
          ..requiredParameters.add(Parameter((p) => p
            ..name = 'id'
            ..type = refer('dynamic')))
          ..body = refer('database.connection.execute')
              .call([refer('_findByIdSql'), refer('{\'id\': id}')]).code),
        Method((m) => m
          ..name = 'save'
          ..annotations.add(refer('override'))
          ..returns = refer(
              'Future<QueryResult>', 'package:datapod_api/datapod_api.dart')
          ..requiredParameters.add(Parameter((p) => p
            ..name = 'params'
            ..type = refer('Map<String, dynamic>')))
          ..optionalParameters.add(Parameter((p) => p
            ..name = 'isUpdate'
            ..type = refer('bool')
            ..named = true
            ..defaultTo = Code('false')))
          ..body = refer('database.connection.execute').call([
            refer('isUpdate ? _updateSql : _insertSql'),
            refer('params')
          ]).code),
        _generateOperationsSaveEntityMethod(entityClass, metadata),
        Method((m) => m
          ..name = 'delete'
          ..annotations.add(refer('override'))
          ..returns = refer('Future<void>')
          ..requiredParameters.add(Parameter((p) => p
            ..name = 'id'
            ..type = refer('dynamic')))
          ..body = refer('database.connection.execute')
              .call([refer('_deleteSql'), refer('{\'id\': id}')]).code),
        ..._generateOperationsQueryResultMethods(
            repoInterface, entityClass, metadata),
      ]));

    final emitter = DartEmitter();
    return opsClass.accept(emitter).toString();
  }

  String _generateRepositoryImpl(ClassElement repoInterface,
      ClassElement entityClass, DartType keyType, EntitySqlMetadata metadata) {
    final className = '${repoInterface.name}Impl';
    final repoClass = Class((b) => b
      ..name = className
      ..extend = refer(repoInterface.name)
      ..fields.addAll([
        Field((f) => f
          ..name = 'database'
          ..type =
              refer('DatapodDatabase', 'package:datapod_api/datapod_api.dart')
          ..modifier = FieldModifier.final$),
        Field((f) => f
          ..name = 'operations'
          ..type = refer('${repoInterface.name}OperationsImpl')
          ..modifier = FieldModifier.final$),
        Field((f) => f
          ..name = 'mapper'
          ..type = refer('${entityClass.name}MapperImpl')
          ..modifier = FieldModifier.final$),
      ])
      ..constructors.add(Constructor((c) => c
        ..requiredParameters.addAll([
          Parameter((p) => p
            ..name = 'database'
            ..toThis = true),
          Parameter((p) => p
            ..name = 'operations'
            ..toThis = true),
          Parameter((p) => p
            ..name = 'mapper'
            ..toThis = true),
          Parameter((p) => p
            ..name = 'relationshipContext'
            ..type = refer(
                'RelationshipContext', 'package:datapod_api/datapod_api.dart')),
        ])
        ..initializers
            .add(refer('super').call([refer('relationshipContext')]).code)))
      ..methods.addAll([
        _generateSaveMethod(entityClass, metadata),
        _generateSaveAllMethod(entityClass),
        _generateDeleteMethod(entityClass, keyType, metadata),
        _generateFindByIdMethod(entityClass, keyType, metadata),
        ..._generateRepoQueryResultMethods(
            repoInterface, entityClass, metadata),
      ]));

    final emitter = DartEmitter();
    return repoClass.accept(emitter).toString();
  }

  Method _generateSaveMethod(
      ClassElement entityClass, EntitySqlMetadata metadata) {
    return Method((m) => m
      ..name = 'save'
      ..annotations.add(refer('override'))
      ..returns = refer('Future<${entityClass.name}>')
      ..requiredParameters.add(Parameter((p) => p..name = 'entity'))
      ..modifier = MethodModifier.async
      ..body = Block.of([
        Code('return await operations.saveEntity(entity);'),
      ]));
  }

  Method _generateSaveAllMethod(ClassElement entityClass) {
    return Method((m) => m
      ..name = 'saveAll'
      ..annotations.add(refer('override'))
      ..returns = refer('Future<List<${entityClass.name}>>')
      ..requiredParameters.add(Parameter((p) => p..name = 'entities'))
      ..modifier = MethodModifier.async
      ..body = Block.of([
        Code('final saved = <${entityClass.name}>[];'),
        Code('for (final entity in entities) {'),
        Code('  saved.add(await save(entity));'),
        Code('}'),
        Code('return saved;'),
      ]));
  }

  Method _generateDeleteMethod(
      ClassElement entityClass, DartType keyType, EntitySqlMetadata metadata) {
    final cascadeRemove =
        metadata.columns.where((c) => c.cascadeRemove).toList();

    return Method((m) => m
      ..name = 'delete'
      ..annotations.add(refer('override'))
      ..returns = refer('Future<void>')
      ..requiredParameters.add(Parameter((p) => p..name = 'id'))
      ..modifier = MethodModifier.async
      ..body = Block.of([
        if (cascadeRemove.isNotEmpty) ...[
          Code('final entity = await findById(id);'),
          Code('if (entity != null) {'),
          for (final col in cascadeRemove) ...[
            Code('  final ${col.fieldName} = await entity.${col.fieldName};'),
            if (col.relationType == 'OneToMany') ...[
              Code('  if (${col.fieldName} != null) {'),
              Code('    for (final child in ${col.fieldName}) {'),
              Code(
                  '      await relationshipContext.getOperations<${col.relatedEntityType}>().delete((child as dynamic).id);'),
              Code('    }'),
              Code('  }'),
            ] else ...[
              Code('  if (${col.fieldName} != null) {'),
              Code(
                  '    await relationshipContext.getOperations<${col.relatedEntityType}>().delete((${col.fieldName} as dynamic).id);'),
              Code('  }'),
            ],
          ],
          Code('}'),
        ],
        Code('await operations.delete(id);'),
      ]));
  }

  Method _generateFindByIdMethod(
      ClassElement entityClass, DartType keyType, EntitySqlMetadata metadata) {
    return Method((m) => m
      ..name = 'findById'
      ..annotations.add(refer('override'))
      ..returns = refer('Future<${entityClass.name}?>')
      ..requiredParameters.add(Parameter((p) => p..name = 'id'))
      ..modifier = MethodModifier.async
      ..body = Block.of([
        Code('final result = await operations.findById(id);'),
        Code('if (result.isEmpty) return null;'),
        Code(
            'return mapper.mapRow(result.rows.first, database, relationshipContext);'),
      ]));
  }

  Iterable<Method> _generateOperationsQueryResultMethods(
      ClassElement repoInterface,
      ClassElement entityClass,
      EntitySqlMetadata metadata) {
    final methods = <Method>[];
    for (final method in repoInterface.methods) {
      if (recomputeMethod(method)) continue;

      if (method.name.startsWith('findBy') ||
          method.name.startsWith('countBy') ||
          method.name.startsWith('existsBy') ||
          method.name.startsWith('deleteBy')) {
        methods.add(_generateOperationsDslMethod(method, metadata));
      }
    }

    // Automatically generate findBy...Id for relationships
    for (final col in metadata.columns
        .where((c) => c.relationType != null && c.columnName.isNotEmpty)) {
      final methodName =
          'findBy${col.fieldName[0].toUpperCase()}${col.fieldName.substring(1)}Id';
      if (!methods.any((m) => m.name == methodName)) {
        methods.add(Method((m) => m
          ..name = methodName
          ..returns = refer(
              'Future<QueryResult>', 'package:datapod_api/datapod_api.dart')
          ..requiredParameters.add(Parameter((p) => p
            ..name = 'id'
            ..type = refer('dynamic')))
          ..body = Block.of([
            Code(
                "final sql = 'SELECT * FROM ${metadata.tableName} WHERE ${col.columnName} = @id';"),
            Code("return database.connection.execute(sql, {'id': id});"),
          ])));
      }
    }

    return methods;
  }

  Method _generateOperationsDslMethod(
      MethodElement method, EntitySqlMetadata metadata) {
    final components = DSLParser.parse(method.name);
    final type = method.name.startsWith('count')
        ? 'count'
        : method.name.startsWith('exists')
            ? 'exists'
            : method.name.startsWith('delete')
                ? 'delete'
                : 'find';

    final paramNames = <String>[];
    final paramAssignments = <Code>[];
    int compIdx = 0;
    for (final comp in components) {
      if (comp.operator == 'IsNull' ||
          comp.operator == 'IsNotNull' ||
          comp.operator == 'IsEmpty' ||
          comp.operator == 'IsNotEmpty' ||
          comp.operator == 'True' ||
          comp.operator == 'False') {
        paramNames.add('');
        continue;
      }

      if (compIdx >= method.parameters.length) {
        throw InvalidGenerationSourceError(
            'Method ${method.name} expects more parameters based on its name.',
            element: method);
      }
      final param = method.parameters[compIdx++];
      paramNames.add(param.name);

      String val = param.name;
      if (comp.operator == 'StartsWith') {
        val = '\'\$${param.name}%\'';
      } else if (comp.operator == 'EndsWith') {
        val = '\'%\$${param.name}\'';
      } else if (comp.operator == 'Contains' ||
          comp.operator == 'NotContains' ||
          comp.operator == 'Containing' ||
          comp.operator == 'NotContaining') {
        val = '\'%\$${param.name}%\'';
      }

      paramAssignments.add(Code('\'${param.name}\': $val,'));
    }

    final sql =
        SqlGenerator.generateDslQuery(metadata, components, type, paramNames);

    final returnType = method.returnType;
    final isStream =
        returnType is InterfaceType && returnType.isDartAsyncStream;

    return Method((m) => m
      ..name = method.name
      ..returns = isStream
          ? refer('Stream<Map<String, dynamic>>', 'dart:async')
          : refer('Future<QueryResult>', 'package:datapod_api/datapod_api.dart')
      ..requiredParameters
          .addAll(method.parameters.map((p) => Parameter((b) => b
            ..name = p.name
            ..type = refer(p.type.getDisplayString(withNullability: true)))))
      ..body = Block.of([
        Code('final params = <String, dynamic>{'),
        ...paramAssignments,
        Code('};'),
        isStream
            ? Code('return database.connection.stream(\'$sql\', params);')
            : Code('return database.connection.execute(\'$sql\', params);'),
      ]));
  }

  Method _generateOperationsSaveEntityMethod(
      ClassElement entityClass, EntitySqlMetadata metadata) {
    final cascadeAfter = metadata.columns
        .where((c) =>
            c.cascadePersist &&
            (c.relationType == 'OneToMany' ||
                (c.relationType == 'OneToOne' && c.columnName.isEmpty)))
        .toList();

    return Method((m) => m
      ..name = 'saveEntity'
      ..annotations.add(refer('override'))
      ..returns = refer('Future<E>')
      ..types.add(refer('E extends Object'))
      ..requiredParameters.add(Parameter((p) => p
        ..name = 'entity'
        ..type = refer('E')))
      ..modifier = MethodModifier.async
      ..body = Block.of([
        Code(
            'final managed = entity is ManagedEntity ? (entity as Managed${entityClass.name}) : Managed${entityClass.name}.fromEntity(entity as ${entityClass.name}, database, relationshipContext);'),
        for (final col in metadata.columns.where((c) =>
            c.relationType == 'ManyToOne' ||
            (c.relationType == 'OneToOne' && c.columnName.isNotEmpty))) ...[
          Code('final ${col.fieldName} = await managed.${col.fieldName};'),
          Code('if (${col.fieldName} != null) {'),
          if (col.cascadePersist) ...[
            Code(
                '  final related = await relationshipContext.getOperations<${col.relatedEntityType}>().saveEntity(${col.fieldName});'),
            Code('  managed.${col.fieldName}Id = (related as dynamic).id;'),
          ] else ...[
            Code('  if (${col.fieldName} is ManagedEntity) {'),
            Code(
                '    managed.${col.fieldName}Id = (${col.fieldName} as dynamic).id;'),
            Code('  }'),
          ],
          Code('}'),
        ],
        Code('final params = <String, dynamic>{'),
        ...metadata.columns.map((c) {
          if (c.relationType != null && c.columnName.isNotEmpty) {
            return Code("'${c.fieldName}Id': managed.${c.fieldName}Id,");
          }
          if (c.columnName.isEmpty) return Code(''); // Skip OneToMany
          if (c.isJson || c.isList) {
            return Code(
                "r'${c.fieldName}': jsonEncode(managed.${c.fieldName}),");
          }
          if (c.enumValues != null) {
            return Code("r'${c.fieldName}': managed.${c.fieldName}?.name,");
          }
          return Code("r'${c.fieldName}': managed.${c.fieldName},");
        }),
        Code('};'),
        Code('if (managed.isPersistent) {'),
        Code('  if (managed.isDirty) {'),
        Code('    await save(params, isUpdate: true);'),
        Code('    managed.clearDirty();'),
        Code('  }'),
        Code('} else {'),
        Code('  final result = await save(params, isUpdate: false);'),
        Code('  managed.markPersistent();'),
        if (metadata.idColumn?.autoIncrement ?? false) ...[
          Code(
              '  managed.${metadata.idColumn!.fieldName} = result.lastInsertId;'),
        ],
        Code('  managed.clearDirty();'),
        Code('}'),
        for (final col in cascadeAfter) ...[
          Code('var ${col.fieldName} = await managed.${col.fieldName};'),
          if (col.relationType == 'OneToMany') ...[
            Code(
                'if (${col.fieldName} != null && ${col.fieldName}.isNotEmpty) {'),
            Code('  for (var child in ${col.fieldName}) {'),
            Code('    if (child is! ManagedEntity) {'),
            Code(
                '      child = Managed${col.relatedEntityType}.fromEntity(child, database, relationshipContext);'),
            Code('    }'),
            Code('    (child as dynamic).${col.mappedBy}Id = managed.id;'),
            Code(
                '    await relationshipContext.getOperations<${col.relatedEntityType}>().saveEntity(child);'),
            Code('  }'),
            Code('}'),
          ] else ...[
            Code('if (${col.fieldName} != null) {'),
            Code('    var child = ${col.fieldName};'),
            Code('    if (child is! ManagedEntity) {'),
            Code(
                '      child = Managed${col.relatedEntityType}.fromEntity(child, database, relationshipContext);'),
            Code('    }'),
            Code('    (child as dynamic).${col.mappedBy}Id = managed.id;'),
            Code(
                '    await relationshipContext.getOperations<${col.relatedEntityType}>().saveEntity(child);'),
            Code('}'),
          ],
        ],
        Code('return managed as E;'),
      ]));
  }

  Iterable<Method> _generateRepoQueryResultMethods(ClassElement repoInterface,
      ClassElement entityClass, EntitySqlMetadata metadata) {
    final methods = <Method>[];
    for (final method in repoInterface.methods) {
      if (recomputeMethod(method)) continue;

      if (method.name.startsWith('findBy') ||
          method.name.startsWith('countBy') ||
          method.name.startsWith('existsBy') ||
          method.name.startsWith('deleteBy')) {
        methods.add(_generateRepoDslMethod(method, entityClass, metadata));
      }
    }

    // Automatically generate findBy...Id for relationships
    for (final col in metadata.columns
        .where((c) => c.relationType != null && c.columnName.isNotEmpty)) {
      final methodName =
          'findBy${col.fieldName[0].toUpperCase()}${col.fieldName.substring(1)}Id';
      if (!methods.any((m) => m.name == methodName)) {
        methods.add(Method((m) => m
          ..name = methodName
          ..returns = refer('Future<List<${entityClass.name}>>')
          ..requiredParameters.add(Parameter((p) => p..name = 'id'))
          ..modifier = MethodModifier.async
          ..body = Block.of([
            Code("final result = await operations.$methodName(id);"),
            Code(
                "return mapper.mapRows(result.rows, database, relationshipContext);"),
          ])));
      }
    }

    return methods;
  }

  Method _generateRepoDslMethod(MethodElement method, ClassElement entityClass,
      EntitySqlMetadata metadata) {
    final type = method.name.startsWith('count')
        ? 'count'
        : method.name.startsWith('exists')
            ? 'exists'
            : method.name.startsWith('delete')
                ? 'delete'
                : 'find';

    final isStream = method.returnType is InterfaceType &&
        (method.returnType as InterfaceType).isDartAsyncStream;

    return Method((m) => m
      ..name = method.name
      ..annotations.add(refer('override'))
      ..returns =
          refer(method.returnType.getDisplayString(withNullability: true))
      ..modifier = isStream ? null : MethodModifier.async
      ..requiredParameters
          .addAll(method.parameters.map((p) => Parameter((b) => b
            ..name = p.name
            ..type = refer(p.type.getDisplayString(withNullability: true)))))
      ..body = Block.of([
        isStream
            ? Code(
                'final result = operations.${method.name}(${method.parameters.map((p) => p.name).join(', ')});')
            : Code(
                'final result = await operations.${method.name}(${method.parameters.map((p) => p.name).join(', ')});'),
        _generateRepoDslReturn(type, method, entityClass),
      ]));
  }

  Code _generateRepoDslReturn(
      String type, MethodElement method, ClassElement entityClass) {
    switch (type) {
      case 'count':
        return Code('return result.rows.first.values.first as int;');
      case 'exists':
        return Code('return result.rows.first.values.first as bool;');
      case 'delete':
        return Code('return;');
      default:
        final returnType = method.returnType;
        final isList = returnType.isDartCoreList ||
            (returnType is InterfaceType &&
                returnType.isDartAsyncFuture &&
                returnType.typeArguments.first.isDartCoreList);
        final isStream =
            returnType is InterfaceType && returnType.isDartAsyncStream;

        if (isStream) {
          return Code(
              'return result.map((row) => mapper.mapRow(row, database, relationshipContext));');
        } else if (isList) {
          return Code(
              'return mapper.mapRows(result.rows, database, relationshipContext);');
        } else {
          return Block.of([
            Code('if (result.isEmpty) return null;'),
            Code(
                'return mapper.mapRow(result.rows.first, database, relationshipContext);'),
          ]);
        }
    }
  }

  bool recomputeMethod(MethodElement method) {
    return method.name == 'save' ||
        method.name == 'saveAll' ||
        method.name == 'delete' ||
        method.name == 'findById';
  }
}
