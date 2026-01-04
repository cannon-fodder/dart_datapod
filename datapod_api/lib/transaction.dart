// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'dart:async';

/// Manages database transactions and provides nested transaction support.
abstract interface class TransactionManager {
  /// Runs the given [action] within a transaction.
  ///
  /// The transaction is automatically committed if the action completes
  /// successfully, or rolled back if an exception is thrown.
  ///
  /// Datapod supports nested transactions by using database savepoints.
  /// If [runInTransaction] is called while already in a transaction,
  /// a savepoint is created, and the inner action is executed relative to it.
  ///
  /// Uses [Zone]s to propagate the transaction context across asynchronous gaps.
  Future<T> runInTransaction<T>(Future<T> Function() action);

  /// Starts a new transaction manually.
  ///
  /// The caller is responsible for calling [Transaction.commit] or
  /// [Transaction.rollback] on the returned object.
  ///
  /// For most use cases, [runInTransaction] is preferred as it handles
  /// lifecycle and nesting automatically.
  Future<Transaction> beginTransaction();
}

/// A handle for manual database transaction control.
abstract interface class Transaction {
  /// Commits all changes made within this transaction to the database.
  Future<void> commit();

  /// Rolls back all changes made within this transaction.
  Future<void> rollback();

  /// Creates a named savepoint within the transaction.
  ///
  /// This allows for partial rollbacks to the savepoint without aborting
  /// the entire transaction.
  Future<void> createSavepoint(String name);

  /// Rolls back all changes made after the specified savepoint was created.
  Future<void> rollbackToSavepoint(String name);

  /// Releases a savepoint, making its changes permanent relative to the
  /// parent transaction.
  Future<void> releaseSavepoint(String name);
}
