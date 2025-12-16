// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  nom: json['nom'] as String?,
  prenom: json['prenom'] as String?,
  telephone: json['telephone'] as String?,
  zoneIntervention: json['zoneIntervention'] as String?,
  roleId: (json['roleId'] as num).toInt(),
  role:
      json['role'] == null
          ? null
          : RoleModel.fromJson(json['role'] as Map<String, dynamic>),
  isActive: json['isActive'] as bool,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'nom': instance.nom,
  'prenom': instance.prenom,
  'telephone': instance.telephone,
  'zoneIntervention': instance.zoneIntervention,
  'roleId': instance.roleId,
  'role': instance.role,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

RoleModel _$RoleModelFromJson(Map<String, dynamic> json) => RoleModel(
  id: (json['id'] as num).toInt(),
  nom: json['nom'] as String,
  description: json['description'] as String?,
  permissions: json['permissions'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$RoleModelToJson(RoleModel instance) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'description': instance.description,
  'permissions': instance.permissions,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
