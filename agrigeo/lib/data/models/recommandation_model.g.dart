// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommandation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommandationModel _$RecommandationModelFromJson(Map<String, dynamic> json) =>
    RecommandationModel(
      id: (json['id'] as num).toInt(),
      typeRecommandation: json['typeRecommandation'] as String,
      titre: json['titre'] as String,
      description: json['description'] as String,
      parametresUtilises: json['parametresUtilises'] as String?,
      priorite: json['priorite'] as String,
      statut: json['statut'] as String,
      exploitationId: (json['exploitationId'] as num).toInt(),
      parcelleId: (json['parcelleId'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$RecommandationModelToJson(
  RecommandationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'typeRecommandation': instance.typeRecommandation,
  'titre': instance.titre,
  'description': instance.description,
  'parametresUtilises': instance.parametresUtilises,
  'priorite': instance.priorite,
  'statut': instance.statut,
  'exploitationId': instance.exploitationId,
  'parcelleId': instance.parcelleId,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
