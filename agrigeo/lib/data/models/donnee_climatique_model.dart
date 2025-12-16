import 'package:json_annotation/json_annotation.dart';

part 'donnee_climatique_model.g.dart';

@JsonSerializable()
class DonneeClimatiqueModel {
  final int id;
  final String dateDebut;
  final String dateFin;
  final double? temperatureMin;
  final double? temperatureMax;
  final double? pluviometrie;
  final String? periodeObservee;
  final int exploitationId;
  final String? createdAt;
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

