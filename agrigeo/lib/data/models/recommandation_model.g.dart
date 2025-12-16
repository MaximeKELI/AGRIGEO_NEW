// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommandation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommandationModel _$RecommandationModelFromJson(Map<String, dynamic> json) =>
    RecommandationModel(
      id: (json['id'] as num).toInt(),
      typeRecommandation: json['type_recommandation'] as String,
      titre: json['titre'] as String,
      description: json['description'] as String,
      parametresUtilises: json['parametres_utilises'] as String?,
      priorite: json['priorite'] as String,
      statut: json['statut'] as String,
      exploitationId: (json['exploitation_id'] as num).toInt(),
      parcelleId: (json['parcelle_id'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$RecommandationModelToJson(
  RecommandationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'type_recommandation': instance.typeRecommandation,
  'titre': instance.titre,
  'description': instance.description,
  'parametres_utilises': instance.parametresUtilises,
  'priorite': instance.priorite,
  'statut': instance.statut,
  'exploitation_id': instance.exploitationId,
  'parcelle_id': instance.parcelleId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
