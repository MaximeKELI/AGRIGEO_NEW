// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analyse_sol_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyseSolModel _$AnalyseSolModelFromJson(Map<String, dynamic> json) =>
    AnalyseSolModel(
      id: (json['id'] as num).toInt(),
      datePrelevement: json['date_prelevement'] as String,
      ph: (json['ph'] as num?)?.toDouble(),
      humidite: (json['humidite'] as num?)?.toDouble(),
      texture: json['texture'] as String?,
      azoteN: (json['azote_n'] as num?)?.toDouble(),
      phosphoreP: (json['phosphore_p'] as num?)?.toDouble(),
      potassiumK: (json['potassium_k'] as num?)?.toDouble(),
      observations: json['observations'] as String?,
      exploitationId: (json['exploitation_id'] as num).toInt(),
      parcelleId: (json['parcelle_id'] as num?)?.toInt(),
      technicienId: (json['technicien_id'] as num).toInt(),
      technicien:
          json['technicien'] == null
              ? null
              : UserModel.fromJson(json['technicien'] as Map<String, dynamic>),
      sensorData: json['sensor_data'] as Map<String, dynamic>?,
      sensorIds:
          (json['sensor_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      dataSource: json['data_source'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$AnalyseSolModelToJson(AnalyseSolModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date_prelevement': instance.datePrelevement,
      'ph': instance.ph,
      'humidite': instance.humidite,
      'texture': instance.texture,
      'azote_n': instance.azoteN,
      'phosphore_p': instance.phosphoreP,
      'potassium_k': instance.potassiumK,
      'observations': instance.observations,
      'exploitation_id': instance.exploitationId,
      'parcelle_id': instance.parcelleId,
      'technicien_id': instance.technicienId,
      'technicien': instance.technicien,
      'sensor_data': instance.sensorData,
      'sensor_ids': instance.sensorIds,
      'data_source': instance.dataSource,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
