// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:datapod_api/annotations.dart' as api;
import 'package:source_gen/source_gen.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

class DatabaseContextGenerator
    extends GeneratorForAnnotation<api.DatapodDatabaseContext> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'DatapodDatabaseContext can only be applied to a class.',
        element: element,
      );
    }

    final className = element.name;
    final repositories = annotation.read('repositories').listValue;

    final generatedClassName = '${className}Impl';

    final classBuilder = Class(
      (c) => c
        ..name = generatedClassName
        ..implements.add(refer(className))
        ..fields.addAll(
          repositories.map((repo) {
            final type = repo.toTypeValue()!;
            final name = _toCamelCase(type.element!.name!);
            return Field(
              (f) => f
                ..name = name
                ..type = refer(type.getDisplayString(withNullability: false))
                ..modifier = FieldModifier.final$,
            );
          }),
        )
        ..constructors.add(
          Constructor(
            (con) => con
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
              ..initializers.addAll(
                repositories.map((repo) {
                  final type = repo.toTypeValue()!;
                  final repoName = type.element!.name!;
                  final fieldName = _toCamelCase(repoName);
                  final superType = (type.element as ClassElement).allSupertypes
                      .firstWhere((t) => t.element.name == 'BaseRepository');
                  final entityType = superType.typeArguments[0];
                  final entityName = entityType.element!.name!;

                  return Code(
                    '$fieldName = ${repoName}Impl(relationshipContext.database!, ${repoName}OperationsImpl(relationshipContext.database!, relationshipContext), ${entityName}MapperImpl(), relationshipContext)',
                  );
                }),
              ),
          ),
        ),
    );

    final emitter = DartEmitter(allocator: Allocator.none);
    return DartFormatter().format('${classBuilder.accept(emitter)}');
  }

  String _toCamelCase(String s) {
    if (s.isEmpty) return s;
    return s[0].toLowerCase() + s.substring(1);
  }
}
