// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parcelle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParcelleModel _$ParcelleModelFromJson(Map<String, dynamic> json) =>
    ParcelleModel(
      id: (json['id'] as num).toInt(),
      nom: json['nom'] as String,
      superficie: (json['superficie'] as num).toDouble(),
      typeCulture: json['typeCulture'] as String?,
      exploitationId: (json['exploitationId'] as num).toInt(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$ParcelleModelToJson(ParcelleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'superficie': instance.superficie,
      'typeCulture': instance.typeCulture,
      'exploitationId': instance.exploitationId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
