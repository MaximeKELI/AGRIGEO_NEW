// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'region_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegionModel _$RegionModelFromJson(Map<String, dynamic> json) => RegionModel(
  id: (json['id'] as num).toInt(),
  nom: json['nom'] as String,
  code: json['code'] as String?,
  superficie: (json['superficie'] as num?)?.toDouble(),
  chefLieu: json['chefLieu'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  description: json['description'] as String?,
  prefecturesCount: (json['prefectures_count'] as num?)?.toInt(),
  exploitationsCount: (json['exploitations_count'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  prefectures:
      (json['prefectures'] as List<dynamic>?)
          ?.map((e) => PrefectureModel.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$RegionModelToJson(RegionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'code': instance.code,
      'superficie': instance.superficie,
      'chefLieu': instance.chefLieu,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'description': instance.description,
      'prefectures_count': instance.prefecturesCount,
      'exploitations_count': instance.exploitationsCount,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'prefectures': instance.prefectures,
    };

PrefectureModel _$PrefectureModelFromJson(Map<String, dynamic> json) =>
    PrefectureModel(
      id: (json['id'] as num).toInt(),
      nom: json['nom'] as String,
      code: json['code'] as String?,
      regionId: (json['region_id'] as num).toInt(),
      regionNom: json['region_nom'] as String?,
      superficie: (json['superficie'] as num?)?.toDouble(),
      chefLieu: json['chefLieu'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      description: json['description'] as String?,
      communesCount: (json['communes_count'] as num?)?.toInt(),
      exploitationsCount: (json['exploitations_count'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      communes:
          (json['communes'] as List<dynamic>?)
              ?.map((e) => CommuneModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$PrefectureModelToJson(PrefectureModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'code': instance.code,
      'region_id': instance.regionId,
      'region_nom': instance.regionNom,
      'superficie': instance.superficie,
      'chefLieu': instance.chefLieu,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'description': instance.description,
      'communes_count': instance.communesCount,
      'exploitations_count': instance.exploitationsCount,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'communes': instance.communes,
    };

CommuneModel _$CommuneModelFromJson(Map<String, dynamic> json) => CommuneModel(
  id: (json['id'] as num).toInt(),
  nom: json['nom'] as String,
  code: json['code'] as String?,
  prefectureId: (json['prefecture_id'] as num).toInt(),
  prefectureNom: json['prefecture_nom'] as String?,
  regionId: (json['region_id'] as num?)?.toInt(),
  regionNom: json['region_nom'] as String?,
  superficie: (json['superficie'] as num?)?.toDouble(),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  description: json['description'] as String?,
  exploitationsCount: (json['exploitations_count'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$CommuneModelToJson(CommuneModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'code': instance.code,
      'prefecture_id': instance.prefectureId,
      'prefecture_nom': instance.prefectureNom,
      'region_id': instance.regionId,
      'region_nom': instance.regionNom,
      'superficie': instance.superficie,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'description': instance.description,
      'exploitations_count': instance.exploitationsCount,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
