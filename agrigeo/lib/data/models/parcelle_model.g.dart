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
      typeCulture: json['type_culture'] as String?,
      exploitationId: (json['exploitation_id'] as num).toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$ParcelleModelToJson(ParcelleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'superficie': instance.superficie,
      'type_culture': instance.typeCulture,
      'exploitation_id': instance.exploitationId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
