// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intrant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntrantModel _$IntrantModelFromJson(Map<String, dynamic> json) => IntrantModel(
  id: (json['id'] as num).toInt(),
  typeIntrant: json['typeIntrant'] as String,
  nomCommercial: json['nomCommercial'] as String?,
  quantite: (json['quantite'] as num).toDouble(),
  unite: json['unite'] as String,
  dateApplication: json['dateApplication'] as String,
  cultureConcernee: json['cultureConcernee'] as String?,
  exploitationId: (json['exploitationId'] as num).toInt(),
  parcelleId: (json['parcelleId'] as num?)?.toInt(),
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$IntrantModelToJson(IntrantModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'typeIntrant': instance.typeIntrant,
      'nomCommercial': instance.nomCommercial,
      'quantite': instance.quantite,
      'unite': instance.unite,
      'dateApplication': instance.dateApplication,
      'cultureConcernee': instance.cultureConcernee,
      'exploitationId': instance.exploitationId,
      'parcelleId': instance.parcelleId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
