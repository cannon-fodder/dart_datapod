// Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>

import 'package:datapod_api/datapod_api.dart';
import 'user.dart';

part 'role.datapod.dart';

@Entity(tableName: 'roles')
class Role {
  @Id()
  int? id;

  @Column()
  String? name;

  @ManyToOne()
  @JoinColumn('user_id')
  Future<User?>? user;
}
