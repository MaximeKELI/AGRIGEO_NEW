// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analyse_sol_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyseSolModel _$AnalyseSolModelFromJson(Map<String, dynamic> json) =>
    AnalyseSolModel(
      id: (json['id'] as num).toInt(),
      datePrelevement: json['datePrelevement'] as String,
      ph: (json['ph'] as num?)?.toDouble(),
      humidite: (json['humidite'] as num?)?.toDouble(),
      texture: json['texture'] as String?,
      azoteN: (json['azoteN'] as num?)?.toDouble(),
      phosphoreP: (json['phosphoreP'] as num?)?.toDouble(),
      potassiumK: (json['potassiumK'] as num?)?.toDouble(),
      observations: json['observations'] as String?,
      exploitationId: (json['exploitationId'] as num).toInt(),
      parcelleId: (json['parcelleId'] as num?)?.toInt(),
      technicienId: (json['technicienId'] as num).toInt(),
      technicien:
          json['technicien'] == null
              ? null
              : UserModel.fromJson(json['technicien'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$AnalyseSolModelToJson(AnalyseSolModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'datePrelevement': instance.datePrelevement,
      'ph': instance.ph,
      'humidite': instance.humidite,
      'texture': instance.texture,
      'azoteN': instance.azoteN,
      'phosphoreP': instance.phosphoreP,
      'potassiumK': instance.potassiumK,
      'observations': instance.observations,
      'exploitationId': instance.exploitationId,
      'parcelleId': instance.parcelleId,
      'technicienId': instance.technicienId,
      'technicien': instance.technicien,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
