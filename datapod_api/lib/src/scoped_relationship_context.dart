import 'package:datapod_api/datapod_api.dart';

/// A RelationshipContext that proxies to a shared context for registry lookups
/// but provides its own specific [database] instance.
///
/// This allows using generated code (which expects a single context with a single database)
/// in a multi-database application where repositories need to share a global registry of
/// mappers and operations but be bound to different database connections.
class ScopedRelationshipContext implements RelationshipContext {
  final RelationshipContext _delegate;
  @override
  final DatapodDatabase database;

  ScopedRelationshipContext(this._delegate, this.database);

  @override
  EntityMapper<E> getMapper<E extends Object>() => _delegate.getMapper<E>();

  @override
  void registerMapper<E extends Object>(EntityMapper<E> mapper) =>
      _delegate.registerMapper(mapper);

  @override
  DatabaseOperations<E, K> getOperations<E extends Object, K>() =>
      _delegate.getOperations<E, K>();

  @override
  void registerOperations<E extends Object, K>(
    DatabaseOperations<E, K> operations,
  ) => _delegate.registerOperations(operations);
}
