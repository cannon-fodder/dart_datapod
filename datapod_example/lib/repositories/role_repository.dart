// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>

import 'package:datapod_api/datapod_api.dart';
import '../entities/role.dart';

part 'role_repository.datapod.dart';

@Repository()
@Database('postgres_db')
abstract class RoleRepository extends BaseRepository<Role, int> {
  RoleRepository(super.relationshipContext);
}
