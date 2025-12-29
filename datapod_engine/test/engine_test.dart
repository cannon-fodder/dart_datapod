// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:test/test.dart';
import 'package:datapod_api/datapod_api.dart';
import 'package:datapod_engine/datapod_engine.dart';

class MockTransaction implements Transaction {
  bool committed = false;
  bool rolledBack = false;

  @override
  Future<void> commit() async {
    committed = true;
  }

  @override
  Future<void> rollback() async {
    rolledBack = true;
  }
}

class MockTransactionManager extends BaseTransactionManager {
  int startCount = 0;
  MockTransaction? lastTransaction;

  @override
  Future<Transaction> beginTransaction() async {
    startCount++;
    lastTransaction = MockTransaction();
    return lastTransaction!;
  }
}

void main() {
  group('QueryResult', () {
    test('should store rows correctly', () {
      final results = QueryResult(rows: [
        {'id': 1, 'name': 'Test'}
      ], affectedRows: 0);
      expect(results.rows.length, 1);
      expect(results.rows.first['name'], 'Test');
    });
  });

  group('BaseTransactionManager', () {
    test('should propagate transaction correctly', () async {
      final manager = MockTransactionManager();

      await manager.runInTransaction(() async {
        expect(BaseTransactionManager.currentTransaction, isNotNull);
        expect(BaseTransactionManager.currentTransaction,
            same(manager.lastTransaction));

        // Nested call
        await manager.runInTransaction(() async {
          expect(BaseTransactionManager.currentTransaction, isNotNull);
          expect(manager.startCount,
              1); // Should not start a new physical transaction
        });
      });

      expect(manager.startCount, 1);
      expect(manager.lastTransaction?.committed, isTrue);
    });

    test('should rollback on error', () async {
      final manager = MockTransactionManager();

      try {
        await manager.runInTransaction(() async {
          throw Exception('Boom');
        });
      } catch (_) {}

      expect(manager.lastTransaction?.rolledBack, isTrue);
      expect(manager.lastTransaction?.committed, isFalse);
    });
  });
}
