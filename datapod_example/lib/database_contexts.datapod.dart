// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'database_contexts.dart';

// **************************************************************************
// DatabaseContextGenerator
// **************************************************************************

class IdentityContextImpl {
  IdentityContextImpl(RelationshipContext relationshipContext)
    : userRepository = UserRepositoryImpl(
        relationshipContext.database!,
        UserRepositoryOperationsImpl(
          relationshipContext.database!,
          relationshipContext,
        ),
        UserMapperImpl(),
        relationshipContext,
      ),
      roleRepository = RoleRepositoryImpl(
        relationshipContext.database!,
        RoleRepositoryOperationsImpl(
          relationshipContext.database!,
          relationshipContext,
        ),
        RoleMapperImpl(),
        relationshipContext,
      );

  final UserRepository userRepository;

  final RoleRepository roleRepository;
}

class ContentContextImpl {
  ContentContextImpl(RelationshipContext relationshipContext)
    : postRepository = PostRepositoryImpl(
        relationshipContext.database!,
        PostRepositoryOperationsImpl(
          relationshipContext.database!,
          relationshipContext,
        ),
        PostMapperImpl(),
        relationshipContext,
      ),
      commentRepository = CommentRepositoryImpl(
        relationshipContext.database!,
        CommentRepositoryOperationsImpl(
          relationshipContext.database!,
          relationshipContext,
        ),
        CommentMapperImpl(),
        relationshipContext,
      );

  final PostRepository postRepository;

  final CommentRepository commentRepository;
}

class ConfigContextImpl {
  ConfigContextImpl(RelationshipContext relationshipContext)
    : settingRepository = SettingRepositoryImpl(
        relationshipContext.database!,
        SettingRepositoryOperationsImpl(
          relationshipContext.database!,
          relationshipContext,
        ),
        SettingMapperImpl(),
        relationshipContext,
      ),
      settingAuditRepository = SettingAuditRepositoryImpl(
        relationshipContext.database!,
        SettingAuditRepositoryOperationsImpl(
          relationshipContext.database!,
          relationshipContext,
        ),
        SettingAuditMapperImpl(),
        relationshipContext,
      );

  final SettingRepository settingRepository;

  final SettingAuditRepository settingAuditRepository;
}
