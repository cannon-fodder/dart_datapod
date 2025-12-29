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

    final result = StringBuffer();
    result.writeln(_generateRepositoryImpl(element, entityClass, keyType));

    return result.toString();
  }

  String _generateRepositoryImpl(
      ClassElement repoInterface, ClassElement entityClass, DartType keyType) {
    final metadata = SqlGenerator.parseEntity(entityClass);
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
        ..requiredParameters.add(Parameter((p) => p
          ..name = 'database'
          ..toThis = true))))
      ..methods.addAll([
        _generateSaveMethod(entityClass, metadata),
        _generateSaveAllMethod(entityClass),
        _generateDeleteMethod(entityClass, keyType, metadata),
        _generateFindByIdMethod(entityClass, keyType, metadata),
        ..._generateQueryResultMethods(repoInterface, entityClass, metadata),
      ]));

    final emitter = DartEmitter();
    return repoClass.accept(emitter).toString();
  }

  Method _generateSaveMethod(
      ClassElement entityClass, EntitySqlMetadata metadata) {
    final cascadeBefore = metadata.columns
        .where((c) =>
            c.cascadePersist &&
            (c.relationType == 'ManyToOne' ||
                (c.relationType == 'OneToOne' && c.columnName.isNotEmpty)))
        .toList();
    final cascadeAfter = metadata.columns
        .where((c) =>
            c.cascadePersist &&
            (c.relationType == 'OneToMany' ||
                (c.relationType == 'OneToOne' && c.columnName.isEmpty)))
        .toList();

    return Method((m) => m
      ..name = 'save'
      ..annotations.add(refer('override'))
      ..returns = refer('Future<${entityClass.name}>')
      ..requiredParameters.add(Parameter((p) => p..name = 'entity'))
      ..modifier = MethodModifier.async
      ..body = Block.of([
        for (final col in cascadeBefore) ...[
          Code('final ${col.fieldName} = await entity.${col.fieldName};'),
          Code('if (${col.fieldName} != null) {'),
          Code(
              '  final related = await database.repositoryFor<${col.relatedEntityType}>().save(${col.fieldName});'),
          Code(
              '  (entity as dynamic).${col.fieldName}Id = (related as dynamic).id;'),
          Code('}'),
        ],
        Code('final params = <String, dynamic>{'),
        ...metadata.columns.map((c) {
          if (c.relationType != null && c.columnName.isNotEmpty) {
            return Code(
                "'${c.fieldName}Id': (entity is ManagedEntity) ? (entity as dynamic).${c.fieldName}Id : null,");
          }
          if (c.columnName.isEmpty) return Code(''); // Skip OneToMany
          return Code("'${c.fieldName}': entity.${c.fieldName},");
        }),
        Code('};'),
        Code('if (entity is ManagedEntity) {'),
        Code('  final managed = entity as ManagedEntity;'),
        Code('  if (managed.isPersistent) {'),
        Code('    if (managed.isDirty) {'),
        Code('      await database.connection.execute(_updateSql, params);'),
        Code('      managed.clearDirty();'),
        Code('    }'),
        Code('  } else {'),
        Code(
            '    final result = await database.connection.execute(_insertSql, params);'),
        Code('    managed.markPersistent();'),
        if (metadata.idColumn?.autoIncrement ?? false) ...[
          Code(
              '    (entity as dynamic).${metadata.idColumn!.fieldName} = result.lastInsertId;'),
        ],
        Code('    managed.clearDirty();'),
        Code('  }'),
        Code('} else {'),
        Code('  await database.connection.execute(_insertSql, params);'),
        Code('}'),
        for (final col in cascadeAfter) ...[
          Code('final ${col.fieldName} = await entity.${col.fieldName};'),
          if (col.relationType == 'OneToMany') ...[
            Code(
                'if (${col.fieldName} != null && ${col.fieldName}.isNotEmpty) {'),
            Code('  for (final child in ${col.fieldName}) {'),
            Code('    (child as dynamic).${col.mappedBy}Id = entity.id;'),
            Code(
                '    await database.repositoryFor<${col.relatedEntityType}>().save(child);'),
            Code('  }'),
            Code('}'),
          ] else ...[
            Code('if (${col.fieldName} != null) {'),
            Code(
                '  ( ${col.fieldName} as dynamic).${col.mappedBy}Id = entity.id;'),
            Code(
                '  await database.repositoryFor<${col.relatedEntityType}>().save(${col.fieldName});'),
            Code('}'),
          ],
        ],
        Code('return entity;'),
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
                  '      await database.repositoryFor<${col.relatedEntityType}>().delete((child as dynamic).id);'),
              Code('    }'),
              Code('  }'),
            ] else ...[
              Code('  if (${col.fieldName} != null) {'),
              Code(
                  '    await database.repositoryFor<${col.relatedEntityType}>().delete((${col.fieldName} as dynamic).id);'),
              Code('  }'),
            ],
          ],
          Code('}'),
        ],
        Code('await database.connection.execute(_deleteSql, {\'id\': id});'),
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
        Code(
            'final result = await database.connection.execute(_findByIdSql, {\'id\': id});'),
        Code('if (result.isEmpty) return null;'),
        Code(
            'return Managed${entityClass.name}.fromRow(result.rows.first, database);'),
      ]));
  }

  Iterable<Method> _generateQueryResultMethods(ClassElement repoInterface,
      ClassElement entityClass, EntitySqlMetadata metadata) {
    final methods = <Method>[];
    for (final method in repoInterface.methods) {
      if (recomputeMethod(method))
        continue; // Skip already implemented ones if any

      if (method.name.startsWith('findBy') ||
          method.name.startsWith('countBy') ||
          method.name.startsWith('existsBy') ||
          method.name.startsWith('deleteBy')) {
        methods.add(_generateDslMethod(method, entityClass, metadata));
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
            Code(
                "final sql = 'SELECT * FROM ${metadata.tableName} WHERE ${col.columnName} = @id';"),
            Code(
                "final result = await database.connection.execute(sql, {'id': id});"),
            Code(
                "return result.rows.map((row) => Managed${entityClass.name}.fromRow(row, database)).toList();"),
          ])));
      }
    }

    return methods;
  }

  bool recomputeMethod(MethodElement method) {
    return method.name == 'save' ||
        method.name == 'saveAll' ||
        method.name == 'delete';
  }

  Method _generateDslMethod(MethodElement method, ClassElement entityClass,
      EntitySqlMetadata metadata) {
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
          comp.operator == 'NotContains') {
        val = '\'%\$${param.name}%\'';
      }

      paramAssignments.add(Code('\'${param.name}\': $val,'));
    }

    final sql =
        SqlGenerator.generateDslQuery(metadata, components, type, paramNames);

    return Method((m) => m
      ..name = method.name
      ..annotations.add(refer('override'))
      ..returns =
          refer(method.returnType.getDisplayString(withNullability: true))
      ..requiredParameters
          .addAll(method.parameters.map((p) => Parameter((b) => b
            ..name = p.name
            ..type = refer(p.type.getDisplayString(withNullability: true)))))
      ..modifier = MethodModifier.async
      ..body = Block.of([
        Code('final params = <String, dynamic>{'),
        ...paramAssignments,
        Code('};'),
        Code(
            'final result = await database.connection.execute(\'$sql\', params);'),
        _generateDslReturn(type, method, entityClass),
      ]));
  }

  Code _generateDslReturn(
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

        if (isList) {
          return Code(
              'return result.rows.map((row) => Managed${entityClass.name}.fromRow(row, database)).toList();');
        } else {
          return Block.of([
            Code('if (result.isEmpty) return null;'),
            Code(
                'return Managed${entityClass.name}.fromRow(result.rows.first, database);'),
          ]);
        }
    }
  }
}
