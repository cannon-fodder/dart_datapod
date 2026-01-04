import 'package:datapod_api/datapod_api.dart';
import '../test_entities.dart';

part 'unique_entity_repository.datapod.dart';

@Repository()
abstract class UniqueEntityRepository
    extends BaseRepository<UniqueEntity, int> {
  UniqueEntityRepository(super.relationshipContext);
}
