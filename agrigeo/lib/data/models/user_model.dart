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
  final String? zoneIntervention;
  final int roleId;
  final RoleModel? role;
  final bool isActive;
  final String? createdAt;
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
  final String? createdAt;
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

