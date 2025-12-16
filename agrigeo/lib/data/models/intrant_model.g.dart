// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intrant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntrantModel _$IntrantModelFromJson(Map<String, dynamic> json) => IntrantModel(
  id: (json['id'] as num).toInt(),
  typeIntrant: json['type_intrant'] as String,
  nomCommercial: json['nom_commercial'] as String?,
  quantite: (json['quantite'] as num).toDouble(),
  unite: json['unite'] as String,
  dateApplication: json['date_application'] as String,
  cultureConcernee: json['culture_concernée'] as String?,
  exploitationId: (json['exploitation_id'] as num).toInt(),
  parcelleId: (json['parcelle_id'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$IntrantModelToJson(IntrantModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type_intrant': instance.typeIntrant,
      'nom_commercial': instance.nomCommercial,
      'quantite': instance.quantite,
      'unite': instance.unite,
      'date_application': instance.dateApplication,
      'culture_concernée': instance.cultureConcernee,
      'exploitation_id': instance.exploitationId,
      'parcelle_id': instance.parcelleId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
