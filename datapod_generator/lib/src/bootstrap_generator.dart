// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:datapod_api/datapod_api.dart' as api;

class BootstrapGenerator extends Generator {
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    final entities = <ClassElement>[];
    final repositories = <ClassElement>[];

    final typeCheckerEntity = TypeChecker.fromRuntime(api.Entity);
    final typeCheckerRepo = TypeChecker.fromRuntime(api.Repository);

    for (var lib in await buildStep.resolver.libraries.toList()) {
      final reader = LibraryReader(lib);
      for (var annotated in reader.annotatedWith(typeCheckerEntity)) {
        if (annotated.element is ClassElement) {
          entities.add(annotated.element as ClassElement);
        }
      }
      for (var annotated in reader.annotatedWith(typeCheckerRepo)) {
        if (annotated.element is ClassElement) {
          repositories.add(annotated.element as ClassElement);
        }
      }
    }

    if (entities.isEmpty && repositories.isEmpty) return '';

    final result = StringBuffer();
    result.writeln('// Generated Datapod initialization');
    result.writeln('import \'package:datapod_engine/datapod_engine.dart\';');
    for (final entity in entities) {
      result.writeln('import \'${entity.library.identifier}\';');
    }
    for (final repo in repositories) {
      result.writeln('import \'${repo.library.identifier}\';');
    }

    result.writeln('\nvoid initializeDatapod() {');
    for (final repo in repositories) {
      result.writeln('  // Registration logic for ${repo.name}');
      // In a real implementation, we would register the generated RepositoryImpl
    }
    result.writeln('}');

    return result.toString();
  }
}
