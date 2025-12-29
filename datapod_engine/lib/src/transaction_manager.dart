// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'dart:async';
import 'package:datapod_api/datapod_api.dart';

/// Base implementation of [TransactionManager] using zones for propagation.
abstract class BaseTransactionManager implements TransactionManager {
  static const _transactionZoneKey = #datapod.transaction;

  /// Gets the current transaction from the zone, if any.
  static Transaction? get currentTransaction =>
      Zone.current[_transactionZoneKey] as Transaction?;

  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) async {
    final existing = currentTransaction;
    if (existing != null) {
      // Already in a transaction, just run the action.
      // TODO: Support nested transactions/savepoints if needed.
      return await action();
    }

    final transaction = await beginTransaction();
    return await runZoned(
      () async {
        try {
          final result = await action();
          await transaction.commit();
          return result;
        } catch (e) {
          await transaction.rollback();
          rethrow;
        }
      },
      zoneValues: {
        _transactionZoneKey: transaction,
      },
    );
  }

  /// Plugins must implement this to start a physical transaction.
  @override
  Future<Transaction> beginTransaction();
}
