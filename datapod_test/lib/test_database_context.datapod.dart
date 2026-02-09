// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_database_context.dart';

// **************************************************************************
// DatabaseContextGenerator
// **************************************************************************

class TestDatabaseContextImpl implements TestDatabaseContext {
  TestDatabaseContextImpl(RelationshipContext relationshipContext)
      : testEntityRepository = TestEntityRepositoryImpl(
            relationshipContext.database!,
            TestEntityRepositoryOperationsImpl(
                relationshipContext.database!, relationshipContext),
            TestEntityMapperImpl(),
            relationshipContext),
        uniqueEntityRepository = UniqueEntityRepositoryImpl(
            relationshipContext.database!,
            UniqueEntityRepositoryOperationsImpl(
                relationshipContext.database!, relationshipContext),
            UniqueEntityMapperImpl(),
            relationshipContext);

  final TestEntityRepository testEntityRepository;

  final UniqueEntityRepository uniqueEntityRepository;
}
