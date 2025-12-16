// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donnee_climatique_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DonneeClimatiqueModel _$DonneeClimatiqueModelFromJson(
  Map<String, dynamic> json,
) => DonneeClimatiqueModel(
  id: (json['id'] as num).toInt(),
  dateDebut: json['dateDebut'] as String,
  dateFin: json['dateFin'] as String,
  temperatureMin: (json['temperatureMin'] as num?)?.toDouble(),
  temperatureMax: (json['temperatureMax'] as num?)?.toDouble(),
  pluviometrie: (json['pluviometrie'] as num?)?.toDouble(),
  periodeObservee: json['periodeObservee'] as String?,
  exploitationId: (json['exploitationId'] as num).toInt(),
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$DonneeClimatiqueModelToJson(
  DonneeClimatiqueModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'dateDebut': instance.dateDebut,
  'dateFin': instance.dateFin,
  'temperatureMin': instance.temperatureMin,
  'temperatureMax': instance.temperatureMax,
  'pluviometrie': instance.pluviometrie,
  'periodeObservee': instance.periodeObservee,
  'exploitationId': instance.exploitationId,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
