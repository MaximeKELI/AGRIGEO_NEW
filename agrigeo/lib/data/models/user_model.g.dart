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
  zoneIntervention: json['zone_intervention'] as String?,
  roleId: (json['role_id'] as num).toInt(),
  role:
      json['role'] == null
          ? null
          : RoleModel.fromJson(json['role'] as Map<String, dynamic>),
  isActive: json['is_active'] as bool,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'nom': instance.nom,
  'prenom': instance.prenom,
  'telephone': instance.telephone,
  'zone_intervention': instance.zoneIntervention,
  'role_id': instance.roleId,
  'role': instance.role,
  'is_active': instance.isActive,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

RoleModel _$RoleModelFromJson(Map<String, dynamic> json) => RoleModel(
  id: (json['id'] as num).toInt(),
  nom: json['nom'] as String,
  description: json['description'] as String?,
  permissions: json['permissions'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$RoleModelToJson(RoleModel instance) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'description': instance.description,
  'permissions': instance.permissions,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
