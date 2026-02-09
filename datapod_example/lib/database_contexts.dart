import 'package:datapod_api/datapod_api.dart';
import 'package:datapod_example/repositories/user_repository.dart';
import 'package:datapod_example/repositories/role_repository.dart';
import 'package:datapod_example/repositories/post_repository.dart';
import 'package:datapod_example/repositories/comment_repository.dart';
import 'package:datapod_example/repositories/setting_repository.dart';
import 'package:datapod_example/repositories/setting_audit_repository.dart';
import 'package:datapod_example/entities/user.dart';
import 'package:datapod_example/entities/role.dart';
import 'package:datapod_example/entities/post.dart';
import 'package:datapod_example/entities/comment.dart';
import 'package:datapod_example/entities/setting.dart';
import 'package:datapod_example/entities/setting_audit.dart';

part 'database_contexts.datapod.dart';

@DatapodDatabaseContext(
  entities: [User, Role],
  repositories: [UserRepository, RoleRepository],
)
abstract class IdentityContext {}

@DatapodDatabaseContext(
  entities: [Post, Comment],
  repositories: [PostRepository, CommentRepository],
)
abstract class ContentContext {}

@DatapodDatabaseContext(
  entities: [Setting, SettingAudit],
  repositories: [SettingRepository, SettingAuditRepository],
)
abstract class ConfigContext {}
