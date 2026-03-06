// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'test_database_context.dart';

// **************************************************************************
// DatabaseContextGenerator
// **************************************************************************

class _$TestDatabaseContext {
  _$TestDatabaseContext(RelationshipContext relationshipContext)
    : testEntityRepository = TestEntityRepositoryImpl(
        relationshipContext.database!,
        TestEntityRepositoryOperationsImpl(
          relationshipContext.database!,
          relationshipContext,
        ),
        TestEntityMapperImpl(),
        relationshipContext,
      ),
      uniqueEntityRepository = UniqueEntityRepositoryImpl(
        relationshipContext.database!,
        UniqueEntityRepositoryOperationsImpl(
          relationshipContext.database!,
          relationshipContext,
        ),
        UniqueEntityMapperImpl(),
        relationshipContext,
      );

  final TestEntityRepository testEntityRepository;

  final UniqueEntityRepository uniqueEntityRepository;
}

class TestDatabaseContextImpl extends _$TestDatabaseContext {
  TestDatabaseContextImpl(RelationshipContext relationshipContext)
    : super(relationshipContext);
}
