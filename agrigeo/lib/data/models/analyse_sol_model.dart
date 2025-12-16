import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'analyse_sol_model.g.dart';

@JsonSerializable()
class AnalyseSolModel {
  final int id;
  final String datePrelevement;
  final double? ph;
  final double? humidite;
  final String? texture;
  final double? azoteN;
  final double? phosphoreP;
  final double? potassiumK;
  final String? observations;
  final int exploitationId;
  final int? parcelleId;
  final int technicienId;
  final UserModel? technicien;
  final String? createdAt;
  final String? updatedAt;

  AnalyseSolModel({
    required this.id,
    required this.datePrelevement,
    this.ph,
    this.humidite,
    this.texture,
    this.azoteN,
    this.phosphoreP,
    this.potassiumK,
    this.observations,
    required this.exploitationId,
    this.parcelleId,
    required this.technicienId,
    this.technicien,
    this.createdAt,
    this.updatedAt,
  });

  factory AnalyseSolModel.fromJson(Map<String, dynamic> json) => _$AnalyseSolModelFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyseSolModelToJson(this);
}

