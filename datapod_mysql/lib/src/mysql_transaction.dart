// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
// This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

import 'package:datapod_api/datapod_api.dart';

class MySqlTransaction implements Transaction {
  final Future<void> Function() _commit;
  final Future<void> Function() _rollback;
  final Future<void> Function(String) _createSavepoint;
  final Future<void> Function(String) _rollbackToSavepoint;
  final Future<void> Function(String) _releaseSavepoint;
  bool _completed = false;

  MySqlTransaction(
    this._commit,
    this._rollback,
    this._createSavepoint,
    this._rollbackToSavepoint,
    this._releaseSavepoint,
  );

  @override
  Future<void> commit() async {
    if (_completed) return;
    await _commit();
    _completed = true;
  }

  @override
  Future<void> rollback() async {
    if (_completed) return;
    await _rollback();
    _completed = true;
  }

  @override
  Future<void> createSavepoint(String name) async {
    if (_completed) return;
    await _createSavepoint(name);
  }

  @override
  Future<void> rollbackToSavepoint(String name) async {
    if (_completed) return;
    await _rollbackToSavepoint(name);
  }

  @override
  Future<void> releaseSavepoint(String name) async {
    if (_completed) return;
    await _releaseSavepoint(name);
  }
}
