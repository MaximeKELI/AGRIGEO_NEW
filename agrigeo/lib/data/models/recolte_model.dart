import 'package:json_annotation/json_annotation.dart';

part 'recolte_model.g.dart';

/// Modèle pour les récoltes agricoles
@JsonSerializable()
class RecolteModel {
  final int id;
  @JsonKey(name: 'exploitation_id')
  final int exploitationId;
  @JsonKey(name: 'parcelle_id')
  final int? parcelleId;
  @JsonKey(name: 'type_culture')
  final String typeCulture; // Type de culture (maïs, riz, manioc, etc.)
  @JsonKey(name: 'mois')
  final int mois; // Mois de la récolte (1-12)
  @JsonKey(name: 'annee')
  final int annee; // Année de la récolte
  @JsonKey(name: 'quantite_recoltee')
  final double quantiteRecoltee; // Quantité en kg ou tonnes
  @JsonKey(name: 'unite_mesure')
  final String uniteMesure; // 'kg', 'tonnes', 'sacs', etc.
  @JsonKey(name: 'superficie_recoltee')
  final double? superficieRecoltee; // Superficie en hectares
  @JsonKey(name: 'rendement')
  final double? rendement; // Rendement en kg/ha ou tonnes/ha
  @JsonKey(name: 'prix_vente')
  final double? prixVente; // Prix de vente unitaire
  @JsonKey(name: 'cout_production')
  final double? coutProduction; // Coût de production total
  @JsonKey(name: 'qualite')
  final String? qualite; // 'excellente', 'bonne', 'moyenne', 'mauvaise'
  @JsonKey(name: 'conditions_climatiques')
  final String? conditionsClimatiques; // Conditions météo pendant la culture
  @JsonKey(name: 'observations')
  final String? observations;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  RecolteModel({
    required this.id,
    required this.exploitationId,
    this.parcelleId,
    required this.typeCulture,
    required this.mois,
    required this.annee,
    required this.quantiteRecoltee,
    required this.uniteMesure,
    this.superficieRecoltee,
    this.rendement,
    this.prixVente,
    this.coutProduction,
    this.qualite,
    this.conditionsClimatiques,
    this.observations,
    this.createdAt,
    this.updatedAt,
  });

  factory RecolteModel.fromJson(Map<String, dynamic> json) =>
      _$RecolteModelFromJson(json);
  Map<String, dynamic> toJson() => _$RecolteModelToJson(this);

  /// Calcule le rendement si la superficie est disponible
  double? calculateRendement() {
    if (superficieRecoltee != null && superficieRecoltee! > 0) {
      return quantiteRecoltee / superficieRecoltee!;
    }
    return rendement;
  }

  /// Calcule le bénéfice si prix et coût sont disponibles
  double? calculateBenefice() {
    if (prixVente != null && coutProduction != null) {
      return (prixVente! * quantiteRecoltee) - coutProduction!;
    }
    return null;
  }
}

/// Modèle pour les statistiques de récoltes
class RecolteStatistics {
  final double min;
  final double max;
  final double moyenne;
  final double mediane;
  final double ecartType;
  final int nombreRecoltes;
  final String typeCulture;
  final int annee;

  RecolteStatistics({
    required this.min,
    required this.max,
    required this.moyenne,
    required this.mediane,
    required this.ecartType,
    required this.nombreRecoltes,
    required this.typeCulture,
    required this.annee,
  });
}

/// Modèle pour les prévisions de récoltes
class RecoltePrevision {
  final double quantitePrevue;
  final double probabiliteBonne; // Probabilité de bonne récolte (0-100)
  final double probabiliteMauvaise; // Probabilité de mauvaise récolte (0-100)
  final String prediction; // 'excellente', 'bonne', 'moyenne', 'mauvaise'
  final String? raison;
  final Map<String, dynamic>? facteurs; // Facteurs influençant la prévision

  RecoltePrevision({
    required this.quantitePrevue,
    required this.probabiliteBonne,
    required this.probabiliteMauvaise,
    required this.prediction,
    this.raison,
    this.facteurs,
  });
}

