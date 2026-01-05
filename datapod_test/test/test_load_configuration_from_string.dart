// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'dart:io';

import 'package:test/test.dart';
import 'package:datapod_test/datapod_init.dart';

void main() {
  test('initialize DatapodContext from string configuration', () async {
    // Read files manually to simulate loading from assets/memory
    // Assuming the test runs from the package root or standard test location
    final dbContent = await File('databases.yaml').readAsString();
    final connContent = await File('connections.yaml').readAsString();

    final context = await DatapodInitializer.initialize(
      databasesYamlContent: dbContent,
      connectionsYamlContent: connContent,
    );

    addTearDown(() async {
      await context.close();
    });

    expect(context, isNotNull);

    // Check that we can execute a query on one of the initialized databases
    final result = await context.postgresTest.connection.execute('SELECT 1');
    expect(result.rows, isNotEmpty);
  });
}
