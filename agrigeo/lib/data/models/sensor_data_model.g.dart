// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SensorDataModel _$SensorDataModelFromJson(Map<String, dynamic> json) =>
    SensorDataModel(
      id: (json['id'] as num?)?.toInt(),
      sensorId: json['sensor_id'] as String,
      sensorType: json['sensor_type'] as String,
      sensorName: json['sensor_name'] as String?,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      parcelleId: (json['parcelle_id'] as num?)?.toInt(),
      exploitationId: (json['exploitation_id'] as num?)?.toInt(),
      timestamp: json['timestamp'] as String,
      batteryLevel: (json['battery_level'] as num?)?.toInt(),
      signalStrength: (json['signal_strength'] as num?)?.toInt(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$SensorDataModelToJson(SensorDataModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sensor_id': instance.sensorId,
      'sensor_type': instance.sensorType,
      'sensor_name': instance.sensorName,
      'value': instance.value,
      'unit': instance.unit,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'parcelle_id': instance.parcelleId,
      'exploitation_id': instance.exploitationId,
      'timestamp': instance.timestamp,
      'battery_level': instance.batteryLevel,
      'signal_strength': instance.signalStrength,
      'metadata': instance.metadata,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

SensorModel _$SensorModelFromJson(Map<String, dynamic> json) => SensorModel(
  id: (json['id'] as num?)?.toInt(),
  sensorId: json['sensor_id'] as String,
  sensorName: json['sensor_name'] as String,
  sensorType: json['sensor_type'] as String,
  description: json['description'] as String?,
  parcelleId: (json['parcelle_id'] as num?)?.toInt(),
  exploitationId: (json['exploitation_id'] as num?)?.toInt(),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  isActive: json['is_active'] as bool? ?? true,
  lastReading: json['last_reading'] as String?,
  batteryLevel: (json['battery_level'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$SensorModelToJson(SensorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sensor_id': instance.sensorId,
      'sensor_name': instance.sensorName,
      'sensor_type': instance.sensorType,
      'description': instance.description,
      'parcelle_id': instance.parcelleId,
      'exploitation_id': instance.exploitationId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'is_active': instance.isActive,
      'last_reading': instance.lastReading,
      'battery_level': instance.batteryLevel,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
