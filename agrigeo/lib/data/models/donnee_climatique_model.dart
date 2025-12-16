import 'package:json_annotation/json_annotation.dart';

part 'donnee_climatique_model.g.dart';

@JsonSerializable()
class DonneeClimatiqueModel {
  final int id;
  @JsonKey(name: 'date_debut')
  final String dateDebut;
  @JsonKey(name: 'date_fin')
  final String dateFin;
  @JsonKey(name: 'temperature_min')
  final double? temperatureMin;
  @JsonKey(name: 'temperature_max')
  final double? temperatureMax;
  final double? pluviometrie;
  @JsonKey(name: 'periode_observée')
  final String? periodeObservee;
  @JsonKey(name: 'exploitation_id')
  final int exploitationId;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  DonneeClimatiqueModel({
    required this.id,
    required this.dateDebut,
    required this.dateFin,
    this.temperatureMin,
    this.temperatureMax,
    this.pluviometrie,
    this.periodeObservee,
    required this.exploitationId,
    this.createdAt,
    this.updatedAt,
  });

  factory DonneeClimatiqueModel.fromJson(Map<String, dynamic> json) => _$DonneeClimatiqueModelFromJson(json);
  Map<String, dynamic> toJson() => _$DonneeClimatiqueModelToJson(this);
}

