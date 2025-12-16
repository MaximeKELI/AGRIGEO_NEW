import 'package:json_annotation/json_annotation.dart';

part 'intrant_model.g.dart';

@JsonSerializable()
class IntrantModel {
  final int id;
  final String typeIntrant;
  final String? nomCommercial;
  final double quantite;
  final String unite;
  final String dateApplication;
  final String? cultureConcernee;
  final int exploitationId;
  final int? parcelleId;
  final String? createdAt;
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

