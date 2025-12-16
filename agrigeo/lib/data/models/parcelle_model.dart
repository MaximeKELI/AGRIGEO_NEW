import 'package:json_annotation/json_annotation.dart';

part 'parcelle_model.g.dart';

@JsonSerializable()
class ParcelleModel {
  final int id;
  final String nom;
  final double superficie;
  @JsonKey(name: 'type_culture')
  final String? typeCulture;
  @JsonKey(name: 'exploitation_id')
  final int exploitationId;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  ParcelleModel({
    required this.id,
    required this.nom,
    required this.superficie,
    this.typeCulture,
    required this.exploitationId,
    this.createdAt,
    this.updatedAt,
  });

  factory ParcelleModel.fromJson(Map<String, dynamic> json) => _$ParcelleModelFromJson(json);
  Map<String, dynamic> toJson() => _$ParcelleModelToJson(this);
}

