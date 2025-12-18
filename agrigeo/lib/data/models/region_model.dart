import 'package:json_annotation/json_annotation.dart';

part 'region_model.g.dart';

/// Modèle pour une région administrative
@JsonSerializable()
class RegionModel {
  final int id;
  final String nom;
  final String? code;
  final double? superficie;
  final String? chefLieu;
  final double? latitude;
  final double? longitude;
  final String? description;
  @JsonKey(name: 'prefectures_count')
  final int? prefecturesCount;
  @JsonKey(name: 'exploitations_count')
  final int? exploitationsCount;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  final List<PrefectureModel>? prefectures;

  RegionModel({
    required this.id,
    required this.nom,
    this.code,
    this.superficie,
    this.chefLieu,
    this.latitude,
    this.longitude,
    this.description,
    this.prefecturesCount,
    this.exploitationsCount,
    this.createdAt,
    this.updatedAt,
    this.prefectures,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) =>
      _$RegionModelFromJson(json);
  Map<String, dynamic> toJson() => _$RegionModelToJson(this);
}

/// Modèle pour une préfecture
@JsonSerializable()
class PrefectureModel {
  final int id;
  final String nom;
  final String? code;
  @JsonKey(name: 'region_id')
  final int regionId;
  @JsonKey(name: 'region_nom')
  final String? regionNom;
  final double? superficie;
  final String? chefLieu;
  final double? latitude;
  final double? longitude;
  final String? description;
  @JsonKey(name: 'communes_count')
  final int? communesCount;
  @JsonKey(name: 'exploitations_count')
  final int? exploitationsCount;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  final List<CommuneModel>? communes;

  PrefectureModel({
    required this.id,
    required this.nom,
    this.code,
    required this.regionId,
    this.regionNom,
    this.superficie,
    this.chefLieu,
    this.latitude,
    this.longitude,
    this.description,
    this.communesCount,
    this.exploitationsCount,
    this.createdAt,
    this.updatedAt,
    this.communes,
  });

  factory PrefectureModel.fromJson(Map<String, dynamic> json) =>
      _$PrefectureModelFromJson(json);
  Map<String, dynamic> toJson() => _$PrefectureModelToJson(this);
}

/// Modèle pour une commune
@JsonSerializable()
class CommuneModel {
  final int id;
  final String nom;
  final String? code;
  @JsonKey(name: 'prefecture_id')
  final int prefectureId;
  @JsonKey(name: 'prefecture_nom')
  final String? prefectureNom;
  @JsonKey(name: 'region_id')
  final int? regionId;
  @JsonKey(name: 'region_nom')
  final String? regionNom;
  final double? superficie;
  final double? latitude;
  final double? longitude;
  final String? description;
  @JsonKey(name: 'exploitations_count')
  final int? exploitationsCount;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  CommuneModel({
    required this.id,
    required this.nom,
    this.code,
    required this.prefectureId,
    this.prefectureNom,
    this.regionId,
    this.regionNom,
    this.superficie,
    this.latitude,
    this.longitude,
    this.description,
    this.exploitationsCount,
    this.createdAt,
    this.updatedAt,
  });

  factory CommuneModel.fromJson(Map<String, dynamic> json) =>
      _$CommuneModelFromJson(json);
  Map<String, dynamic> toJson() => _$CommuneModelToJson(this);
}




