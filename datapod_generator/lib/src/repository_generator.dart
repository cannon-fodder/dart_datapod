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
    result.writeln(
        _generateOperationsImpl(element, entityClass, keyType, metadata));
    result.writeln();
    result.writeln(
        _generateRepositoryImpl(element, entityClass, keyType, metadata));

    return result.toString();
  }

  String _generateOperationsImpl(ClassElement repoInterface,
      ClassElement entityClass, DartType keyType, EntitySqlMetadata metadata) {
    final className = '${repoInterface.name}OperationsImpl';
    final fieldToColumnMap = metadata.columns
        .map((c) => "'${c.fieldName}': '${c.columnName}'")
        .join(', ');

    final methods = <Method>[];
    final seen = <String>{};

    void addMethod(Method m) {
      if (!seen.contains(m.name)) {
        seen.add(m.name!);
        methods.add(m);
      }
    }

    addMethod(_generateOperationsSaveMethod(entityClass, metadata));
    addMethod(_generateOperationsSaveEntityMethod(entityClass, metadata));
    addMethod(_generateOperationsFindAllMethod(entityClass, metadata));
    addMethod(_generateOperationsDeleteMethod(entityClass, keyType, metadata));
    addMethod(
        _generateOperationsFindByIdMethod(entityClass, keyType, metadata));
    for (final m in _generateOperationsQueryResultMethods(
        repoInterface, entityClass, metadata, seen)) {
      methods.add(m);
    }

    final opsClass = Class((b) => b
      ..name = className
      ..implements.add(TypeReference((tr) => tr
        ..symbol = 'DatabaseOperations'
        ..url = 'package:datapod_api/datapod_api.dart'
        ..types.addAll([
          refer(entityClass.name),
          refer(keyType.getDisplayString(withNullability: true)),
        ])))
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
          ..assignment =
              Code("'''${SqlGenerator.generateInsert(metadata)}'''")),
        Field((f) => f
          ..name = '_updateSql'
          ..static = true
          ..modifier = FieldModifier.constant
          ..assignment =
              Code("'''${SqlGenerator.generateUpdate(metadata)}'''")),
        Field((f) => f
          ..name = '_deleteSql'
          ..static = true
          ..modifier = FieldModifier.constant
          ..assignment =
              Code("'''${SqlGenerator.generateDelete(metadata)}'''")),
        Field((f) => f
          ..name = '_findByIdSql'
          ..static = true
          ..modifier = FieldModifier.constant
          ..assignment =
              Code("'''${SqlGenerator.generateFindById(metadata)}'''")),
        Field((f) => f
          ..name = '_fieldToColumn'
          ..static = true
          ..modifier = FieldModifier.constant
          ..assignment = Code("{$fieldToColumnMap}")),
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
      ..methods.addAll(methods));

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
        _generateFindAllMethod(repoInterface, entityClass, metadata),
        _generateFindAllPagedMethod(repoInterface, entityClass, metadata),
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
                  '      await relationshipContext.getOperations<${col.relatedEntityType}, dynamic>().delete((child as dynamic).id);'),
              Code('    }'),
              Code('  }'),
            ] else ...[
              Code('  if (${col.fieldName} != null) {'),
              Code(
                  '    await relationshipContext.getOperations<${col.relatedEntityType}, dynamic>().delete((${col.fieldName} as dynamic).id);'),
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
      ..returns = TypeReference((tr) => tr
        ..symbol = 'Future'
        ..types.add(refer('${entityClass.name}?')))
      ..requiredParameters.add(Parameter((p) => p..name = 'id'))
      ..modifier = MethodModifier.async
      ..body = Block.of([
        Code('final result = await operations.findById(id);'),
        Code('if (result.isEmpty) return null;'),
        Code(
            'return mapper.mapRow(result.rows.first, database, relationshipContext);'),
      ]));
  }

  Method _generateOperationsSaveMethod(
      ClassElement entityClass, EntitySqlMetadata metadata) {
    return Method((m) => m
      ..name = 'save'
      ..annotations.add(refer('override'))
      ..returns = TypeReference((tr) => tr
        ..symbol = 'Future'
        ..types
            .add(refer('QueryResult', 'package:datapod_api/datapod_api.dart')))
      ..modifier = MethodModifier.async
      ..requiredParameters.add(Parameter((p) => p
        ..name = 'params'
        ..type = refer('Map<String, dynamic>')))
      ..optionalParameters.add(Parameter((p) => p
        ..name = 'isUpdate'
        ..type = refer('bool')
        ..named = true
        ..defaultTo = Code('false')))
      ..body = Block.of([
        Code(
            "return database.connection.execute(isUpdate ? _updateSql : _insertSql, params);"),
      ]));
  }

  Method _generateOperationsFindByIdMethod(
      ClassElement entityClass, DartType keyType, EntitySqlMetadata metadata) {
    return Method((m) => m
      ..name = 'findById'
      ..annotations.add(refer('override'))
      ..returns = TypeReference((tr) => tr
        ..symbol = 'Future'
        ..types
            .add(refer('QueryResult', 'package:datapod_api/datapod_api.dart')))
      ..modifier = MethodModifier.async
      ..requiredParameters.add(Parameter((p) => p
        ..name = 'id'
        ..type = refer(keyType.getDisplayString(withNullability: true))))
      ..body = Block.of([
        Code("return database.connection.execute(_findByIdSql, {'id': id});"),
      ]));
  }

  Method _generateOperationsDeleteMethod(
      ClassElement entityClass, DartType keyType, EntitySqlMetadata metadata) {
    return Method((m) => m
      ..name = 'delete'
      ..annotations.add(refer('override'))
      ..returns = refer('Future<void>')
      ..modifier = MethodModifier.async
      ..requiredParameters.add(Parameter((p) => p
        ..name = 'id'
        ..type = refer(keyType.getDisplayString(withNullability: true))))
      ..body = Block.of([
        Code("await database.connection.execute(_deleteSql, {'id': id});"),
      ]));
  }

  Iterable<Method> _generateOperationsQueryResultMethods(
      ClassElement repoInterface,
      ClassElement entityClass,
      EntitySqlMetadata metadata,
      Set<String> seen) {
    final methods = <Method>[];
    final allMethods = [
      ...repoInterface.methods,
      ...repoInterface.allSupertypes.expand((s) => s.methods)
    ];

    for (final method in allMethods) {
      if (seen.contains(method.name)) continue;
      if (recomputeMethod(method)) continue;

      if (method.name.startsWith('findBy') ||
          method.name.startsWith('countBy') ||
          method.name.startsWith('existsBy') ||
          method.name.startsWith('deleteBy')) {
        seen.add(method.name);
        methods.add(_generateOperationsDslMethod(method, metadata));
      }
    }

    // Automatically generate findBy...Id for relationships
    for (final col in metadata.columns
        .where((c) => c.relationType != null && c.columnName.isNotEmpty)) {
      final methodName =
          'findBy${col.fieldName[0].toUpperCase()}${col.fieldName.substring(1)}Id';
      if (!seen.contains(methodName)) {
        seen.add(methodName);
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

    final pageableChecker =
        TypeChecker.fromUrl('package:datapod_api/pagination.dart#Pageable');
    final sortChecker =
        TypeChecker.fromUrl('package:datapod_api/pagination.dart#Sort');

    String? pageableVar;
    String? sortVar;

    for (final param in method.parameters) {
      if (pageableChecker.isAssignableFromType(param.type)) {
        pageableVar = param.name;
      } else if (sortChecker.isAssignableFromType(param.type) ||
          (param.type.isDartCoreList &&
              sortChecker.isAssignableFromType(
                  (param.type as InterfaceType).typeArguments.first))) {
        sortVar = param.name;
      }
    }

    final otherParams = method.parameters
        .where((p) =>
            !pageableChecker.isAssignableFromType(p.type) &&
            !sortChecker.isAssignableFromType(p.type) &&
            !(p.type.isDartCoreList &&
                sortChecker.isAssignableFromType(
                    (p.type as InterfaceType).typeArguments.first)))
        .toList();

    final paramNames = <String>[];
    int paramIdx = 0;
    for (final comp in components) {
      if (comp.operator == 'IsNull' ||
          comp.operator == 'IsNotNull' ||
          comp.operator == 'IsEmpty' ||
          comp.operator == 'IsNotEmpty' ||
          comp.operator == 'True' ||
          comp.operator == 'False') {
        paramNames.add('');
      } else {
        if (paramIdx < otherParams.length) {
          paramNames.add(otherParams[paramIdx].name);
          paramIdx++;
        } else {
          paramNames.add('');
        }
      }
    }

    final returnType = method.returnType;
    final isStream =
        returnType is InterfaceType && returnType.isDartAsyncStream;

    return Method((m) => m
      ..name = method.name
      ..returns = isStream
          ? refer('Stream<Map<String, dynamic>>')
          : refer('Future<QueryResult>', 'package:datapod_api/datapod_api.dart')
      ..modifier = isStream ? null : MethodModifier.async
      ..requiredParameters.addAll(method.parameters
          .where((p) => !p.isNamed)
          .map((p) => Parameter((b) => b
            ..name = p.name
            ..type = refer(p.type.getDisplayString(withNullability: true)))))
      ..optionalParameters.addAll(method.parameters
          .where((p) => p.isNamed)
          .map((p) => Parameter((b) => b
            ..name = p.name
            ..named = true
            ..type = refer(p.type.getDisplayString(withNullability: true)))))
      ..body = Block.of([
        Code(
            'final params = ${_generateDslParamMap(components, otherParams)};'),
        Code(
            "final sql = applyPagination('''${SqlGenerator.generateDslQuery(metadata, components, type, paramNames)}''', sort: ${sortVar ?? (pageableVar != null ? '$pageableVar.sort' : 'null')}, limit: ${pageableVar != null ? '$pageableVar.size' : 'null'}, offset: ${pageableVar != null ? '$pageableVar.offset' : 'null'}, fieldToColumn: _fieldToColumn);"),
        isStream
            ? Code('return database.connection.stream(sql, params);')
            : Code('return database.connection.execute(sql, params);'),
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
      ..returns = TypeReference((tr) => tr
        ..symbol = 'Future'
        ..types.add(refer(entityClass.name)))
      ..requiredParameters.add(Parameter((p) => p
        ..name = 'entity'
        ..type = refer(entityClass.name)))
      ..modifier = MethodModifier.async
      ..body = Block.of([
        Code(
            'final Managed${entityClass.name} managed = entity is ManagedEntity ? (entity as Managed${entityClass.name}) : Managed${entityClass.name}.fromEntity(entity, database, relationshipContext);'),
        for (final col in metadata.columns.where((c) =>
            c.relationType == 'ManyToOne' ||
            (c.relationType == 'OneToOne' && c.columnName.isNotEmpty))) ...[
          Code('final ${col.fieldName} = await managed.${col.fieldName};'),
          Code('if (${col.fieldName} != null) {'),
          if (col.cascadePersist) ...[
            Code(
                '  final related = await relationshipContext.getOperations<${col.relatedEntityType}, dynamic>().saveEntity(${col.fieldName});'),
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
                '    await relationshipContext.getOperations<${col.relatedEntityType}, dynamic>().saveEntity(child);'),
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
                '    await relationshipContext.getOperations<${col.relatedEntityType}, dynamic>().saveEntity(child);'),
            Code('}'),
          ],
        ],
        Code('return managed;'),
      ]));
  }

  Iterable<Method> _generateRepoQueryResultMethods(ClassElement repoInterface,
      ClassElement entityClass, EntitySqlMetadata metadata) {
    final methods = <Method>[];
    final seen = <String>{};
    final allMethods = [
      ...repoInterface.methods,
      ...repoInterface.allSupertypes.expand((s) => s.methods)
    ];

    for (final method in allMethods) {
      if (seen.contains(method.name)) continue;
      if (recomputeMethod(method)) continue;

      if (method.name.startsWith('findBy') ||
          method.name.startsWith('countBy') ||
          method.name.startsWith('existsBy') ||
          method.name.startsWith('deleteBy')) {
        seen.add(method.name);
        methods.add(_generateRepoDslMethod(
            repoInterface, method, entityClass, metadata));
      }
    }

    // Automatically generate findBy...Id for relationships
    for (final col in metadata.columns
        .where((c) => c.relationType != null && c.columnName.isNotEmpty)) {
      final methodName =
          'findBy${col.fieldName[0].toUpperCase()}${col.fieldName.substring(1)}Id';
      if (!seen.contains(methodName)) {
        seen.add(methodName);
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

  Method _generateRepoDslMethod(
      ClassElement repoInterface,
      MethodElement method,
      ClassElement entityClass,
      EntitySqlMetadata metadata) {
    final type = method.name.startsWith('count')
        ? 'count'
        : method.name.startsWith('exists')
            ? 'exists'
            : method.name.startsWith('delete')
                ? 'delete'
                : 'find';

    final isCore = method.name == 'findAll' || method.name == 'findAllPaged';
    final components =
        isCore ? <QueryComponent>[] : DSLParser.parse(method.name);

    final pageableChecker =
        TypeChecker.fromUrl('package:datapod_api/pagination.dart#Pageable');
    final sortChecker =
        TypeChecker.fromUrl('package:datapod_api/pagination.dart#Sort');

    String? pageableVar;

    final otherParams = method.parameters
        .where((p) =>
            !pageableChecker.isAssignableFromType(p.type) &&
            !sortChecker.isAssignableFromType(p.type) &&
            !(p.type.isDartCoreList &&
                sortChecker.isAssignableFromType(
                    (p.type as InterfaceType).typeArguments.first)))
        .toList();

    for (final param in method.parameters) {
      if (pageableChecker.isAssignableFromType(param.type)) {
        pageableVar = param.name;
      }
    }

    final dslParamNames = <String>[];
    int paramIdx = 0;
    for (final comp in components) {
      if (comp.operator == 'IsNull' ||
          comp.operator == 'IsNotNull' ||
          comp.operator == 'IsEmpty' ||
          comp.operator == 'IsNotEmpty' ||
          comp.operator == 'True' ||
          comp.operator == 'False') {
        dslParamNames.add('');
      } else {
        if (paramIdx < otherParams.length) {
          dslParamNames.add(otherParams[paramIdx].name);
          paramIdx++;
        } else {
          dslParamNames.add('');
        }
      }
    }

    final isStream = method.returnType is InterfaceType &&
        (method.returnType as InterfaceType).isDartAsyncStream;

    final returnTypeStr =
        method.returnType.getDisplayString(withNullability: true);
    final isPage = returnTypeStr.startsWith('Future<Page<') ||
        returnTypeStr.startsWith('Page<');

    return Method((m) => m
      ..name = method.name
      ..annotations.add(refer('override'))
      ..returns = refer(returnTypeStr)
      ..modifier = isStream ? null : MethodModifier.async
      ..requiredParameters.addAll(method.parameters
          .where((p) => !p.isNamed)
          .map((p) => Parameter((b) => b
            ..name = p.name
            ..type = refer(p.type.getDisplayString(withNullability: true)))))
      ..optionalParameters.addAll(method.parameters
          .where((p) => p.isNamed)
          .map((p) => Parameter((b) => b
            ..name = p.name
            ..named = true
            ..type = refer(p.type.getDisplayString(withNullability: true)))))
      ..body = Block.of([
        if (isPage) ...[
          if (method.name == 'findAllPaged')
            Code(
                'final result = await operations.findAll(limit: $pageableVar.size, offset: $pageableVar.offset, sort: $pageableVar.sort);')
          else
            Code(
                'final result = ${isStream ? '' : 'await '}operations.${method.name}(${method.parameters.map((p) => p.isNamed ? '${p.name}: ${p.name}' : p.name).join(', ')});'),
          Code(
              "final totalElements = await operations.database.connection.execute("),
          Code(
              "  applyPagination('''${SqlGenerator.generateDslQuery(metadata, components, 'count', dslParamNames)}''', fieldToColumn: ${repoInterface.name}OperationsImpl._fieldToColumn),"),
          Code('  ${_generateDslParamMap(components, otherParams)}'),
          Code(');'),
          Code('return Page('),
          Code(
              '  items: mapper.mapRows(result.rows, database, relationshipContext),'),
          Code(
              '  totalElements: totalElements.rows.first.values.first as int,'),
          Code('  pageNumber: $pageableVar.page,'),
          Code('  pageSize: $pageableVar.size,'),
          Code(');'),
        ] else ...[
          isStream
              ? Code(
                  'final result = operations.${method.name}(${method.parameters.map((p) => p.isNamed ? '${p.name}: ${p.name}' : p.name).join(', ')});')
              : Code(
                  'final result = await operations.${method.name}(${method.parameters.map((p) => p.isNamed ? '${p.name}: ${p.name}' : p.name).join(', ')});'),
          _generateRepoDslReturn(type, method, entityClass),
        ]
      ]));
  }

  String _generateDslParamMap(
      List<QueryComponent> components, List<ParameterElement> otherParams) {
    if (components.isEmpty && otherParams.isEmpty) return '<String, dynamic>{}';
    final entries = <String>[];
    int paramIdx = 0;
    for (final comp in components) {
      if (comp.operator == 'IsNull' ||
          comp.operator == 'IsNotNull' ||
          comp.operator == 'IsEmpty' ||
          comp.operator == 'IsNotEmpty' ||
          comp.operator == 'True' ||
          comp.operator == 'False') {
        // No parameter
      } else {
        if (paramIdx < otherParams.length) {
          final param = otherParams[paramIdx];
          paramIdx++;
          String val = param.name;
          if (comp.operator == 'StartsWith') {
            val = "'\$$val%'";
          } else if (comp.operator == 'EndsWith') {
            val = "'%\$$val'";
          } else if (comp.operator == 'Contains' ||
              comp.operator == 'NotContains' ||
              comp.operator == 'Containing' ||
              comp.operator == 'NotContaining') {
            val = "'%\$$val%'";
          }
          entries.add("'${param.name}': $val");
        }
      }
    }
    // Add any remaining otherParams (though normally there shouldn't be any if DSL matches)
    while (paramIdx < otherParams.length) {
      final param = otherParams[paramIdx];
      paramIdx++;
      entries.add("'${param.name}': ${param.name}");
    }

    return '<String, dynamic>{${entries.join(', ')}}';
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

  Method _generateOperationsFindAllMethod(
      ClassElement entityClass, EntitySqlMetadata metadata) {
    return Method((m) => m
      ..name = 'findAll'
      ..annotations.add(refer('override'))
      ..returns = refer('Future<QueryResult>')
      ..modifier = MethodModifier.async
      ..optionalParameters.addAll([
        Parameter((p) => p
          ..name = 'sort'
          ..type = refer('List<Sort>?')
          ..named = true),
        Parameter((p) => p
          ..name = 'limit'
          ..type = refer('int?')
          ..named = true),
        Parameter((p) => p
          ..name = 'offset'
          ..type = refer('int?')
          ..named = true),
      ])
      ..body = Block.of([
        Code(
            "final sql = applyPagination('''SELECT * FROM ${metadata.tableName}''', sort: sort, limit: limit, offset: offset, fieldToColumn: _fieldToColumn);"),
        Code("return database.connection.execute(sql, {});"),
      ]));
  }

  Method _generateFindAllMethod(ClassElement repoInterface,
      ClassElement entityClass, EntitySqlMetadata metadata) {
    final method = repoInterface.allSupertypes
        .expand((s) => s.methods)
        .firstWhere((m) => m.name == 'findAll');

    return _generateRepoDslMethod(repoInterface, method, entityClass, metadata);
  }

  Method _generateFindAllPagedMethod(ClassElement repoInterface,
      ClassElement entityClass, EntitySqlMetadata metadata) {
    final method = repoInterface.allSupertypes
        .expand((s) => s.methods)
        .firstWhere((m) => m.name == 'findAllPaged');

    return _generateRepoDslMethod(repoInterface, method, entityClass, metadata);
  }

  bool recomputeMethod(MethodElement method) {
    return method.name == 'save' ||
        method.name == 'saveAll' ||
        method.name == 'saveEntity' ||
        method.name == 'delete' ||
        method.name == 'findAll' ||
        method.name == 'findAllPaged' ||
        method.name == 'findById';
  }
}
