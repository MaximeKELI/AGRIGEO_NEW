// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recolte_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecolteModel _$RecolteModelFromJson(Map<String, dynamic> json) => RecolteModel(
  id: (json['id'] as num).toInt(),
  exploitationId: (json['exploitation_id'] as num).toInt(),
  parcelleId: (json['parcelle_id'] as num?)?.toInt(),
  typeCulture: json['type_culture'] as String,
  mois: (json['mois'] as num).toInt(),
  annee: (json['annee'] as num).toInt(),
  quantiteRecoltee: (json['quantite_recoltee'] as num).toDouble(),
  uniteMesure: json['unite_mesure'] as String,
  superficieRecoltee: (json['superficie_recoltee'] as num?)?.toDouble(),
  rendement: (json['rendement'] as num?)?.toDouble(),
  prixVente: (json['prix_vente'] as num?)?.toDouble(),
  coutProduction: (json['cout_production'] as num?)?.toDouble(),
  qualite: json['qualite'] as String?,
  conditionsClimatiques: json['conditions_climatiques'] as String?,
  observations: json['observations'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$RecolteModelToJson(RecolteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exploitation_id': instance.exploitationId,
      'parcelle_id': instance.parcelleId,
      'type_culture': instance.typeCulture,
      'mois': instance.mois,
      'annee': instance.annee,
      'quantite_recoltee': instance.quantiteRecoltee,
      'unite_mesure': instance.uniteMesure,
      'superficie_recoltee': instance.superficieRecoltee,
      'rendement': instance.rendement,
      'prix_vente': instance.prixVente,
      'cout_production': instance.coutProduction,
      'qualite': instance.qualite,
      'conditions_climatiques': instance.conditionsClimatiques,
      'observations': instance.observations,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
