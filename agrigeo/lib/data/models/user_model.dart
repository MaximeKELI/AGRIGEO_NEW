import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String username;
  final String email;
  final String? nom;
  final String? prenom;
  final String? telephone;
  @JsonKey(name: 'zone_intervention')
  final String? zoneIntervention;
  @JsonKey(name: 'role_id')
  final int roleId;
  final RoleModel? role;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.nom,
    this.prenom,
    this.telephone,
    this.zoneIntervention,
    required this.roleId,
    this.role,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class RoleModel {
  final int id;
  final String nom;
  final String? description;
  final String? permissions;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  RoleModel({
    required this.id,
    required this.nom,
    this.description,
    this.permissions,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) => _$RoleModelFromJson(json);
  Map<String, dynamic> toJson() => _$RoleModelToJson(this);
}

