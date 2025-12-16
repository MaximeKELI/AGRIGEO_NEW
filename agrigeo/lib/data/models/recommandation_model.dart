import 'package:json_annotation/json_annotation.dart';

part 'recommandation_model.g.dart';

@JsonSerializable()
class RecommandationModel {
  final int id;
  final String typeRecommandation;
  final String titre;
  final String description;
  final String? parametresUtilises;
  final String priorite;
  final String statut;
  final int exploitationId;
  final int? parcelleId;
  final String? createdAt;
  final String? updatedAt;

  RecommandationModel({
    required this.id,
    required this.typeRecommandation,
    required this.titre,
    required this.description,
    this.parametresUtilises,
    required this.priorite,
    required this.statut,
    required this.exploitationId,
    this.parcelleId,
    this.createdAt,
    this.updatedAt,
  });

  factory RecommandationModel.fromJson(Map<String, dynamic> json) => _$RecommandationModelFromJson(json);
  Map<String, dynamic> toJson() => _$RecommandationModelToJson(this);
}

