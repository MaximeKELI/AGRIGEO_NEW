// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistiques_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatistiquesNationalesModel _$StatistiquesNationalesModelFromJson(
  Map<String, dynamic> json,
) => StatistiquesNationalesModel(
  totalExploitations: (json['total_exploitations'] as num).toInt(),
  superficieTotaleCultivee:
      (json['superficie_totale_cultivee'] as num).toDouble(),
  repartitionParCulture:
      (json['repartition_par_culture'] as List<dynamic>)
          .map(
            (e) => RepartitionCultureModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
  repartitionParRegion:
      (json['repartition_par_region'] as List<dynamic>)
          .map(
            (e) => RepartitionRegionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
  totalAnalysesSol: (json['total_analyses_sol'] as num).toInt(),
  totalIntrants: (json['total_intrants'] as num).toInt(),
  totalRecoltes: (json['total_recoltes'] as num).toInt(),
  dateCalcul: json['date_calcul'] as String,
);

Map<String, dynamic> _$StatistiquesNationalesModelToJson(
  StatistiquesNationalesModel instance,
) => <String, dynamic>{
  'total_exploitations': instance.totalExploitations,
  'superficie_totale_cultivee': instance.superficieTotaleCultivee,
  'repartition_par_culture': instance.repartitionParCulture,
  'repartition_par_region': instance.repartitionParRegion,
  'total_analyses_sol': instance.totalAnalysesSol,
  'total_intrants': instance.totalIntrants,
  'total_recoltes': instance.totalRecoltes,
  'date_calcul': instance.dateCalcul,
};

RepartitionCultureModel _$RepartitionCultureModelFromJson(
  Map<String, dynamic> json,
) => RepartitionCultureModel(
  culture: json['culture'] as String,
  nombreExploitations: (json['nombre_exploitations'] as num).toInt(),
  superficieTotale: (json['superficie_totale'] as num).toDouble(),
);

Map<String, dynamic> _$RepartitionCultureModelToJson(
  RepartitionCultureModel instance,
) => <String, dynamic>{
  'culture': instance.culture,
  'nombre_exploitations': instance.nombreExploitations,
  'superficie_totale': instance.superficieTotale,
};

RepartitionRegionModel _$RepartitionRegionModelFromJson(
  Map<String, dynamic> json,
) => RepartitionRegionModel(
  region: json['region'] as String,
  nombreExploitations: (json['nombre_exploitations'] as num).toInt(),
  superficieTotale: (json['superficie_totale'] as num).toDouble(),
);

Map<String, dynamic> _$RepartitionRegionModelToJson(
  RepartitionRegionModel instance,
) => <String, dynamic>{
  'region': instance.region,
  'nombre_exploitations': instance.nombreExploitations,
  'superficie_totale': instance.superficieTotale,
};

StatistiquesRegionalesModel _$StatistiquesRegionalesModelFromJson(
  Map<String, dynamic> json,
) => StatistiquesRegionalesModel(
  region: json['region'] as Map<String, dynamic>,
  totalExploitations: (json['total_exploitations'] as num).toInt(),
  superficieTotaleCultivee:
      (json['superficie_totale_cultivee'] as num).toDouble(),
  repartitionParPrefecture:
      (json['repartition_par_prefecture'] as List<dynamic>)
          .map(
            (e) =>
                RepartitionPrefectureModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
  repartitionParCulture:
      (json['repartition_par_culture'] as List<dynamic>)
          .map(
            (e) => RepartitionCultureModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
  totalAnalysesSol: (json['total_analyses_sol'] as num).toInt(),
  dateCalcul: json['date_calcul'] as String,
);

Map<String, dynamic> _$StatistiquesRegionalesModelToJson(
  StatistiquesRegionalesModel instance,
) => <String, dynamic>{
  'region': instance.region,
  'total_exploitations': instance.totalExploitations,
  'superficie_totale_cultivee': instance.superficieTotaleCultivee,
  'repartition_par_prefecture': instance.repartitionParPrefecture,
  'repartition_par_culture': instance.repartitionParCulture,
  'total_analyses_sol': instance.totalAnalysesSol,
  'date_calcul': instance.dateCalcul,
};

RepartitionPrefectureModel _$RepartitionPrefectureModelFromJson(
  Map<String, dynamic> json,
) => RepartitionPrefectureModel(
  prefectureId: (json['prefecture_id'] as num).toInt(),
  prefectureNom: json['prefecture_nom'] as String,
  nombreExploitations: (json['nombre_exploitations'] as num).toInt(),
  superficieTotale: (json['superficie_totale'] as num).toDouble(),
);

Map<String, dynamic> _$RepartitionPrefectureModelToJson(
  RepartitionPrefectureModel instance,
) => <String, dynamic>{
  'prefecture_id': instance.prefectureId,
  'prefecture_nom': instance.prefectureNom,
  'nombre_exploitations': instance.nombreExploitations,
  'superficie_totale': instance.superficieTotale,
};

ComparaisonRegionsModel _$ComparaisonRegionsModelFromJson(
  Map<String, dynamic> json,
) => ComparaisonRegionsModel(
  comparaison:
      (json['comparaison'] as List<dynamic>)
          .map(
            (e) =>
                ComparaisonRegionItemModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
  superficieNationaleTotale:
      (json['superficie_nationale_totale'] as num).toDouble(),
  dateCalcul: json['date_calcul'] as String,
);

Map<String, dynamic> _$ComparaisonRegionsModelToJson(
  ComparaisonRegionsModel instance,
) => <String, dynamic>{
  'comparaison': instance.comparaison,
  'superficie_nationale_totale': instance.superficieNationaleTotale,
  'date_calcul': instance.dateCalcul,
};

ComparaisonRegionItemModel _$ComparaisonRegionItemModelFromJson(
  Map<String, dynamic> json,
) => ComparaisonRegionItemModel(
  regionId: (json['region_id'] as num).toInt(),
  regionNom: json['region_nom'] as String,
  regionCode: json['region_code'] as String?,
  nombreExploitations: (json['nombre_exploitations'] as num).toInt(),
  superficieTotale: (json['superficie_totale'] as num).toDouble(),
  superficieMoyenneParExploitation:
      (json['superficie_moyenne_par_exploitation'] as num).toDouble(),
  culturePrincipale: json['culture_principale'] as String?,
  pourcentageSuperficieNationale:
      (json['pourcentage_superficie_nationale'] as num).toDouble(),
);

Map<String, dynamic> _$ComparaisonRegionItemModelToJson(
  ComparaisonRegionItemModel instance,
) => <String, dynamic>{
  'region_id': instance.regionId,
  'region_nom': instance.regionNom,
  'region_code': instance.regionCode,
  'nombre_exploitations': instance.nombreExploitations,
  'superficie_totale': instance.superficieTotale,
  'superficie_moyenne_par_exploitation':
      instance.superficieMoyenneParExploitation,
  'culture_principale': instance.culturePrincipale,
  'pourcentage_superficie_nationale': instance.pourcentageSuperficieNationale,
};
