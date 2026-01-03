import 'dart:convert';
import 'package:datapod_api/datapod_api.dart';
import '../test_entities.dart';

part 'test_entity_repository.datapod.dart';

@Repository()
abstract class TestEntityRepository extends BaseRepository<TestEntity, int> {
  TestEntityRepository(super.relationshipContext);
}
