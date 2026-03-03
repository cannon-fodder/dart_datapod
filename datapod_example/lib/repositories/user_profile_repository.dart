// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>

import 'package:datapod_api/datapod_api.dart';
import '../entities/user_profile.dart';

part 'user_profile_repository.datapod.dart';

@Repository()
@Database('identity_db')
abstract class UserProfileRepository extends BaseRepository<UserProfile, int> {
  UserProfileRepository(super.relationshipContext);
}
