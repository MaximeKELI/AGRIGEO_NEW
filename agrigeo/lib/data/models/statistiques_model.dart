import 'package:json_annotation/json_annotation.dart';

part 'statistiques_model.g.dart';

/// Modèle pour les statistiques nationales
@JsonSerializable()
class StatistiquesNationalesModel {
  @JsonKey(name: 'total_exploitations')
  final int totalExploitations;
  @JsonKey(name: 'superficie_totale_cultivee')
  final double superficieTotaleCultivee;
  @JsonKey(name: 'repartition_par_culture')
  final List<RepartitionCultureModel> repartitionParCulture;
  @JsonKey(name: 'repartition_par_region')
  final List<RepartitionRegionModel> repartitionParRegion;
  @JsonKey(name: 'total_analyses_sol')
  final int totalAnalysesSol;
  @JsonKey(name: 'total_intrants')
  final int totalIntrants;
  @JsonKey(name: 'total_recoltes')
  final int totalRecoltes;
  @JsonKey(name: 'date_calcul')
  final String dateCalcul;

  StatistiquesNationalesModel({
    required this.totalExploitations,
    required this.superficieTotaleCultivee,
    required this.repartitionParCulture,
    required this.repartitionParRegion,
    required this.totalAnalysesSol,
    required this.totalIntrants,
    required this.totalRecoltes,
    required this.dateCalcul,
  });

  factory StatistiquesNationalesModel.fromJson(Map<String, dynamic> json) =>
      _$StatistiquesNationalesModelFromJson(json);
  Map<String, dynamic> toJson() => _$StatistiquesNationalesModelToJson(this);
}

/// Modèle pour la répartition par culture
@JsonSerializable()
class RepartitionCultureModel {
  final String culture;
  @JsonKey(name: 'nombre_exploitations')
  final int nombreExploitations;
  @JsonKey(name: 'superficie_totale')
  final double superficieTotale;

  RepartitionCultureModel({
    required this.culture,
    required this.nombreExploitations,
    required this.superficieTotale,
  });

  factory RepartitionCultureModel.fromJson(Map<String, dynamic> json) =>
      _$RepartitionCultureModelFromJson(json);
  Map<String, dynamic> toJson() => _$RepartitionCultureModelToJson(this);
}

/// Modèle pour la répartition par région
@JsonSerializable()
class RepartitionRegionModel {
  final String region;
  @JsonKey(name: 'nombre_exploitations')
  final int nombreExploitations;
  @JsonKey(name: 'superficie_totale')
  final double superficieTotale;

  RepartitionRegionModel({
    required this.region,
    required this.nombreExploitations,
    required this.superficieTotale,
  });

  factory RepartitionRegionModel.fromJson(Map<String, dynamic> json) =>
      _$RepartitionRegionModelFromJson(json);
  Map<String, dynamic> toJson() => _$RepartitionRegionModelToJson(this);
}

/// Modèle pour les statistiques régionales
@JsonSerializable()
class StatistiquesRegionalesModel {
  final Map<String, dynamic> region;
  @JsonKey(name: 'total_exploitations')
  final int totalExploitations;
  @JsonKey(name: 'superficie_totale_cultivee')
  final double superficieTotaleCultivee;
  @JsonKey(name: 'repartition_par_prefecture')
  final List<RepartitionPrefectureModel> repartitionParPrefecture;
  @JsonKey(name: 'repartition_par_culture')
  final List<RepartitionCultureModel> repartitionParCulture;
  @JsonKey(name: 'total_analyses_sol')
  final int totalAnalysesSol;
  @JsonKey(name: 'date_calcul')
  final String dateCalcul;

  StatistiquesRegionalesModel({
    required this.region,
    required this.totalExploitations,
    required this.superficieTotaleCultivee,
    required this.repartitionParPrefecture,
    required this.repartitionParCulture,
    required this.totalAnalysesSol,
    required this.dateCalcul,
  });

  factory StatistiquesRegionalesModel.fromJson(Map<String, dynamic> json) =>
      _$StatistiquesRegionalesModelFromJson(json);
  Map<String, dynamic> toJson() => _$StatistiquesRegionalesModelToJson(this);
}

/// Modèle pour la répartition par préfecture
@JsonSerializable()
class RepartitionPrefectureModel {
  @JsonKey(name: 'prefecture_id')
  final int prefectureId;
  @JsonKey(name: 'prefecture_nom')
  final String prefectureNom;
  @JsonKey(name: 'nombre_exploitations')
  final int nombreExploitations;
  @JsonKey(name: 'superficie_totale')
  final double superficieTotale;

  RepartitionPrefectureModel({
    required this.prefectureId,
    required this.prefectureNom,
    required this.nombreExploitations,
    required this.superficieTotale,
  });

  factory RepartitionPrefectureModel.fromJson(Map<String, dynamic> json) =>
      _$RepartitionPrefectureModelFromJson(json);
  Map<String, dynamic> toJson() => _$RepartitionPrefectureModelToJson(this);
}

/// Modèle pour la comparaison inter-régions
@JsonSerializable()
class ComparaisonRegionsModel {
  final List<ComparaisonRegionItemModel> comparaison;
  @JsonKey(name: 'superficie_nationale_totale')
  final double superficieNationaleTotale;
  @JsonKey(name: 'date_calcul')
  final String dateCalcul;

  ComparaisonRegionsModel({
    required this.comparaison,
    required this.superficieNationaleTotale,
    required this.dateCalcul,
  });

  factory ComparaisonRegionsModel.fromJson(Map<String, dynamic> json) =>
      _$ComparaisonRegionsModelFromJson(json);
  Map<String, dynamic> toJson() => _$ComparaisonRegionsModelToJson(this);
}

/// Modèle pour un item de comparaison de région
@JsonSerializable()
class ComparaisonRegionItemModel {
  @JsonKey(name: 'region_id')
  final int regionId;
  @JsonKey(name: 'region_nom')
  final String regionNom;
  @JsonKey(name: 'region_code')
  final String? regionCode;
  @JsonKey(name: 'nombre_exploitations')
  final int nombreExploitations;
  @JsonKey(name: 'superficie_totale')
  final double superficieTotale;
  @JsonKey(name: 'superficie_moyenne_par_exploitation')
  final double superficieMoyenneParExploitation;
  @JsonKey(name: 'culture_principale')
  final String? culturePrincipale;
  @JsonKey(name: 'pourcentage_superficie_nationale')
  final double pourcentageSuperficieNationale;

  ComparaisonRegionItemModel({
    required this.regionId,
    required this.regionNom,
    this.regionCode,
    required this.nombreExploitations,
    required this.superficieTotale,
    required this.superficieMoyenneParExploitation,
    this.culturePrincipale,
    required this.pourcentageSuperficieNationale,
  });

  factory ComparaisonRegionItemModel.fromJson(Map<String, dynamic> json) =>
      _$ComparaisonRegionItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$ComparaisonRegionItemModelToJson(this);
}




