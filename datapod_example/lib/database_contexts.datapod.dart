// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'database_contexts.dart';

// **************************************************************************
// DatabaseContextGenerator
// **************************************************************************

class _$IdentityContext {
  _$IdentityContext(RelationshipContext relationshipContext)
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

class IdentityContextImpl extends _$IdentityContext {
  IdentityContextImpl(RelationshipContext relationshipContext)
    : super(relationshipContext);
}

class _$ContentContext {
  _$ContentContext(RelationshipContext relationshipContext)
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

class ContentContextImpl extends _$ContentContext {
  ContentContextImpl(RelationshipContext relationshipContext)
    : super(relationshipContext);
}

class _$ConfigContext {
  _$ConfigContext(RelationshipContext relationshipContext)
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

class ConfigContextImpl extends _$ConfigContext {
  ConfigContextImpl(RelationshipContext relationshipContext)
    : super(relationshipContext);
}
