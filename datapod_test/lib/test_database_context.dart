import 'package:datapod_api/datapod_api.dart';
import 'package:datapod_test/repositories/test_entity_repository.dart';
import 'package:datapod_test/repositories/unique_entity_repository.dart';
import 'package:datapod_test/test_entities.dart';

part 'test_database_context.datapod.dart';

@DatapodDatabaseContext(
  entities: [TestEntity, UniqueEntity],
  repositories: [TestEntityRepository, UniqueEntityRepository],
)
abstract class TestDatabaseContext {}
