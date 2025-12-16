import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'analyse_sol_model.g.dart';

@JsonSerializable()
class AnalyseSolModel {
  final int id;
  @JsonKey(name: 'date_prelevement')
  final String datePrelevement;
  final double? ph;
  final double? humidite;
  final String? texture;
  @JsonKey(name: 'azote_n')
  final double? azoteN;
  @JsonKey(name: 'phosphore_p')
  final double? phosphoreP;
  @JsonKey(name: 'potassium_k')
  final double? potassiumK;
  final String? observations;
  @JsonKey(name: 'exploitation_id')
  final int exploitationId;
  @JsonKey(name: 'parcelle_id')
  final int? parcelleId;
  @JsonKey(name: 'technicien_id')
  final int technicienId;
  final UserModel? technicien;
  @JsonKey(name: 'sensor_data')
  final Map<String, dynamic>? sensorData; // Données brutes des capteurs
  @JsonKey(name: 'sensor_ids')
  final List<String>? sensorIds; // Liste des IDs de capteurs utilisés
  @JsonKey(name: 'data_source')
  final String? dataSource; // 'manual', 'sensor', 'mixed'
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
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
    this.sensorData,
    this.sensorIds,
    this.dataSource,
    this.createdAt,
    this.updatedAt,
  });

  factory AnalyseSolModel.fromJson(Map<String, dynamic> json) => _$AnalyseSolModelFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyseSolModelToJson(this);
}

