import 'package:json_annotation/json_annotation.dart';

part 'intrant_model.g.dart';

@JsonSerializable()
class IntrantModel {
  final int id;
  @JsonKey(name: 'type_intrant')
  final String typeIntrant;
  @JsonKey(name: 'nom_commercial')
  final String? nomCommercial;
  final double quantite;
  final String unite;
  @JsonKey(name: 'date_application')
  final String dateApplication;
  @JsonKey(name: 'culture_concernée')
  final String? cultureConcernee;
  @JsonKey(name: 'exploitation_id')
  final int exploitationId;
  @JsonKey(name: 'parcelle_id')
  final int? parcelleId;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  IntrantModel({
    required this.id,
    required this.typeIntrant,
    this.nomCommercial,
    required this.quantite,
    required this.unite,
    required this.dateApplication,
    this.cultureConcernee,
    required this.exploitationId,
    this.parcelleId,
    this.createdAt,
    this.updatedAt,
  });

  factory IntrantModel.fromJson(Map<String, dynamic> json) => _$IntrantModelFromJson(json);
  Map<String, dynamic> toJson() => _$IntrantModelToJson(this);
}

