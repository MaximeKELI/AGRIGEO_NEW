import 'package:json_annotation/json_annotation.dart';

part 'parcelle_model.g.dart';

@JsonSerializable()
class ParcelleModel {
  final int id;
  final String nom;
  final double superficie;
  final String? typeCulture;
  final int exploitationId;
  final String? createdAt;
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

