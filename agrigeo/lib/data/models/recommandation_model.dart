import 'package:json_annotation/json_annotation.dart';

part 'recommandation_model.g.dart';

@JsonSerializable()
class RecommandationModel {
  final int id;
  @JsonKey(name: 'type_recommandation')
  final String typeRecommandation;
  final String titre;
  final String description;
  @JsonKey(name: 'parametres_utilises')
  final String? parametresUtilises;
  final String priorite;
  final String statut;
  @JsonKey(name: 'exploitation_id')
  final int exploitationId;
  @JsonKey(name: 'parcelle_id')
  final int? parcelleId;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
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

