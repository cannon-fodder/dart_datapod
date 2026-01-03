// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

import 'dart:async';
import 'package:mysql1/mysql1.dart' as mysql;

/// Interface for executing MySQL queries, shared by single connections and pools.
abstract interface class MySqlExecutor {
  Future<mysql.Results> query(String sql, [List<dynamic>? values]);
  Future<void> close();
}

/// A wrapper for single mysql1 connections to implement [MySqlExecutor].
class SingleMySqlExecutor implements MySqlExecutor {
  final mysql.MySqlConnection _connection;
  SingleMySqlExecutor(this._connection);

  @override
  Future<mysql.Results> query(String sql, [List<dynamic>? values]) =>
      _connection.query(sql, values);

  @override
  Future<void> close() => _connection.close();
}

/// A basic connection pool for mysql1.
class MySqlPool implements MySqlExecutor {
  final List<mysql.MySqlConnection> _connections = [];
  final mysql.ConnectionSettings _settings;
  final int _maxSize;
  int _currentIndex = 0;
  bool _closed = false;

  MySqlPool(this._settings, this._maxSize);

  Future<void> _initialize() async {
    for (var i = 0; i < _maxSize; i++) {
      _connections.add(await mysql.MySqlConnection.connect(_settings));
    }
  }

  static Future<MySqlPool> connect(
      mysql.ConnectionSettings settings, int maxSize) async {
    final pool = MySqlPool(settings, maxSize);
    await pool._initialize();
    return pool;
  }

  @override
  Future<mysql.Results> query(String sql, [List<dynamic>? values]) async {
    if (_closed) throw StateError('Pool is closed');

    // Simple round-robin for demonstration
    final conn = _connections[_currentIndex];
    _currentIndex = (_currentIndex + 1) % _connections.length;

    return conn.query(sql, values);
  }

  @override
  Future<void> close() async {
    _closed = true;
    await Future.wait(_connections.map((c) => c.close()));
    _connections.clear();
  }
}
