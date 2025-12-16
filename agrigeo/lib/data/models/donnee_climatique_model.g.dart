// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donnee_climatique_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DonneeClimatiqueModel _$DonneeClimatiqueModelFromJson(
  Map<String, dynamic> json,
) => DonneeClimatiqueModel(
  id: (json['id'] as num).toInt(),
  dateDebut: json['date_debut'] as String,
  dateFin: json['date_fin'] as String,
  temperatureMin: (json['temperature_min'] as num?)?.toDouble(),
  temperatureMax: (json['temperature_max'] as num?)?.toDouble(),
  pluviometrie: (json['pluviometrie'] as num?)?.toDouble(),
  periodeObservee: json['periode_observée'] as String?,
  exploitationId: (json['exploitation_id'] as num).toInt(),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$DonneeClimatiqueModelToJson(
  DonneeClimatiqueModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'date_debut': instance.dateDebut,
  'date_fin': instance.dateFin,
  'temperature_min': instance.temperatureMin,
  'temperature_max': instance.temperatureMax,
  'pluviometrie': instance.pluviometrie,
  'periode_observée': instance.periodeObservee,
  'exploitation_id': instance.exploitationId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
