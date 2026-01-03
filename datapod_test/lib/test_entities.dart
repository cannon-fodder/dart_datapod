import 'dart:convert';
import 'package:datapod_api/datapod_api.dart';

part 'test_entities.datapod.dart';

enum TestEnum { alpha, beta, gamma }

@Entity(tableName: 'test_entities')
class TestEntity {
  @Id()
  int? id;

  @Column()
  String? name;

  @Column()
  int? value;

  @Column()
  double? rating;

  @Column()
  bool? flag;

  @Column()
  DateTime? createdAt;

  @Column()
  TestEnum? type;

  @Column()
  Map<String, dynamic>? data;

  @Column()
  List<String>? tags;
}
