import '../../core/errors/failures.dart';
import '../../core/constants/app_constants.dart';
import '../datasources/api_service.dart';
import '../models/recolte_model.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Service pour gérer les récoltes
class RecolteService {
  final ApiService _apiService;

  RecolteService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  /// Récupère la liste des récoltes
  Future<List<RecolteModel>> getRecoltes({
    int? exploitationId,
    int? parcelleId,
    String? typeCulture,
    int? annee,
    int? mois,
  }) async {
    try {
      final response = await _apiService.getRecoltes(
        exploitationId: exploitationId,
        parcelleId: parcelleId,
        typeCulture: typeCulture,
        annee: annee,
        mois: mois,
      );
      final List<dynamic> recoltesData = response.data['items'] ?? response.data;
      return recoltesData.map((json) => RecolteModel.fromJson(json)).toList();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Crée une nouvelle récolte
  Future<RecolteModel> createRecolte(RecolteModel recolte) async {
    try {
      final response = await _apiService.createRecolte(recolte.toJson());
      return RecolteModel.fromJson(response.data['recolte']);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Met à jour une récolte
  Future<RecolteModel> updateRecolte(int id, RecolteModel recolte) async {
    try {
      final response = await _apiService.updateRecolte(id, recolte.toJson());
      return RecolteModel.fromJson(response.data['recolte']);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Supprime une récolte
  Future<void> deleteRecolte(int id) async {
    try {
      await _apiService.deleteRecolte(id);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Récupère les statistiques des récoltes
  Future<RecolteStatistics> getStatistics({
    int? exploitationId,
    String? typeCulture,
    int? annee,
  }) async {
    try {
      final response = await _apiService.getRecolteStatistics(
        exploitationId: exploitationId,
        typeCulture: typeCulture,
        annee: annee,
      );
      final data = response.data;
      return RecolteStatistics(
        min: (data['min'] as num).toDouble(),
        max: (data['max'] as num).toDouble(),
        moyenne: (data['moyenne'] as num).toDouble(),
        mediane: (data['mediane'] as num).toDouble(),
        ecartType: (data['ecart_type'] as num).toDouble(),
        nombreRecoltes: data['nombre'] as int,
        typeCulture: typeCulture ?? 'Toutes',
        annee: annee ?? DateTime.now().year,
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Récupère la prévision pour la prochaine récolte
  Future<RecoltePrevision> getPrevision({
    required int exploitationId,
    required String typeCulture,
  }) async {
    try {
      final response = await _apiService.getRecoltePrevision(
        exploitationId: exploitationId,
        typeCulture: typeCulture,
      );
      final data = response.data;
      return RecoltePrevision(
        quantitePrevue: (data['quantite_prevue'] as num).toDouble(),
        probabiliteBonne: (data['probabilite_bonne'] as num).toDouble(),
        probabiliteMauvaise: (data['probabilite_mauvaise'] as num).toDouble(),
        prediction: data['prediction'] as String,
        raison: data['raison'] as String?,
        facteurs: data['facteurs'] as Map<String, dynamic>?,
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Importe des récoltes depuis un fichier CSV
  Future<Map<String, dynamic>> importFromCsv(String csvContent, {required int exploitationId}) async {
    try {
      final lines = const CsvToListConverter().convert(csvContent);
      if (lines.isEmpty) {
        throw const FormatException('Le fichier CSV est vide');
      }

      // Première ligne = en-têtes
      final headers = lines[0].map((e) => e.toString().toLowerCase().trim()).toList();
      
      // Mapping des colonnes
      final Map<String, int> columnMap = {};
      for (int i = 0; i < headers.length; i++) {
        final header = headers[i];
        if (header.contains('type') || header.contains('culture')) {
          columnMap['type_culture'] = i;
        } else if (header.contains('mois') || header.contains('month')) {
          columnMap['mois'] = i;
        } else if (header.contains('année') || header.contains('annee') || header.contains('year')) {
          columnMap['annee'] = i;
        } else if (header.contains('quantité') || header.contains('quantite') || header.contains('quantity')) {
          columnMap['quantite_recoltee'] = i;
        } else if (header.contains('superficie') || header.contains('surface') || header.contains('area')) {
          columnMap['superficie_recoltee'] = i;
        } else if (header.contains('unité') || header.contains('unite') || header.contains('unit')) {
          columnMap['unite_mesure'] = i;
        } else if (header.contains('prix') || header.contains('price')) {
          columnMap['prix_vente'] = i;
        } else if (header.contains('coût') || header.contains('cout') || header.contains('cost')) {
          columnMap['cout_production'] = i;
        } else if (header.contains('qualité') || header.contains('qualite') || header.contains('quality')) {
          columnMap['qualite'] = i;
        }
      }

      final List<Map<String, dynamic>> recoltesData = [];
      int ligneNum = 1;

      for (int i = 1; i < lines.length; i++) {
        ligneNum = i + 1;
        final line = lines[i];
        
        if (line.length < headers.length) continue;

        final recolteData = <String, dynamic>{
          'exploitation_id': exploitationId,
        };

        // Extraire les données selon le mapping
        if (columnMap.containsKey('type_culture')) {
          recolteData['type_culture'] = line[columnMap['type_culture']!].toString().trim();
        }
        if (columnMap.containsKey('mois')) {
          final moisStr = line[columnMap['mois']!].toString().trim();
          recolteData['mois'] = _parseMois(moisStr);
        }
        if (columnMap.containsKey('annee')) {
          recolteData['annee'] = int.tryParse(line[columnMap['annee']!].toString()) ?? DateTime.now().year;
        }
        if (columnMap.containsKey('quantite_recoltee')) {
          recolteData['quantite_recoltee'] = double.tryParse(line[columnMap['quantite_recoltee']!].toString().replaceAll(',', '.')) ?? 0.0;
        }
        if (columnMap.containsKey('superficie_recoltee')) {
          final superficie = double.tryParse(line[columnMap['superficie_recoltee']!].toString().replaceAll(',', '.'));
          if (superficie != null) recolteData['superficie_recoltee'] = superficie;
        }
        if (columnMap.containsKey('unite_mesure')) {
          recolteData['unite_mesure'] = line[columnMap['unite_mesure']!].toString().trim();
        } else {
          recolteData['unite_mesure'] = 'kg';
        }
        if (columnMap.containsKey('prix_vente')) {
          final prix = double.tryParse(line[columnMap['prix_vente']!].toString().replaceAll(',', '.'));
          if (prix != null) recolteData['prix_vente'] = prix;
        }
        if (columnMap.containsKey('cout_production')) {
          final cout = double.tryParse(line[columnMap['cout_production']!].toString().replaceAll(',', '.'));
          if (cout != null) recolteData['cout_production'] = cout;
        }
        if (columnMap.containsKey('qualite')) {
          recolteData['qualite'] = line[columnMap['qualite']!].toString().trim();
        }

        // Validation minimale
        if (recolteData.containsKey('type_culture') && 
            recolteData.containsKey('mois') && 
            recolteData.containsKey('annee') && 
            recolteData.containsKey('quantite_recoltee')) {
          recoltesData.add(recolteData);
        }
      }

      if (recoltesData.isEmpty) {
        throw const FormatException('Aucune donnée valide trouvée dans le fichier CSV');
      }

      // Envoyer au backend
      final response = await _apiService.importRecoltes({'recoltes': recoltesData});
      
      return {
        'success': true,
        'importees': response.data['importees'] as int,
        'erreurs': response.data['erreurs'] as List<dynamic>,
        'message': response.data['message'] as String,
      };
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Erreur lors de l\'import CSV: ${e.toString()}');
    }
  }

  /// Exporte les récoltes vers un fichier CSV
  Future<String> exportToCsv(List<RecolteModel> recoltes) async {
    try {
      final List<List<dynamic>> csvData = [];
      
      // En-têtes
      csvData.add([
        'ID',
        'Exploitation ID',
        'Parcelle ID',
        'Type Culture',
        'Mois',
        'Année',
        'Quantité Récoltée',
        'Unité',
        'Superficie (ha)',
        'Rendement (kg/ha)',
        'Prix Vente',
        'Coût Production',
        'Qualité',
        'Observations',
        'Date Création',
      ]);

      // Données
      for (final recolte in recoltes) {
        csvData.add([
          recolte.id,
          recolte.exploitationId,
          recolte.parcelleId ?? '',
          recolte.typeCulture,
          recolte.mois,
          recolte.annee,
          recolte.quantiteRecoltee,
          recolte.uniteMesure,
          recolte.superficieRecoltee ?? '',
          recolte.rendement ?? '',
          recolte.prixVente ?? '',
          recolte.coutProduction ?? '',
          recolte.qualite ?? '',
          recolte.observations ?? '',
          recolte.createdAt ?? '',
        ]);
      }

      final csvString = const ListToCsvConverter().convert(csvData);
      
      // Sauvegarder dans le dossier Documents
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/recoltes_export_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csvString);
      
      return file.path;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Erreur lors de l\'export CSV: ${e.toString()}');
    }
  }

  /// Parse le mois depuis une chaîne (peut être un nombre ou un nom de mois)
  int _parseMois(String moisStr) {
    // Essayer de parser comme nombre
    final moisNum = int.tryParse(moisStr);
    if (moisNum != null && moisNum >= 1 && moisNum <= 12) {
      return moisNum;
    }

    // Parser comme nom de mois
    final moisLower = moisStr.toLowerCase();
    final moisMap = {
      'janvier': 1, 'january': 1, 'jan': 1,
      'février': 2, 'fevrier': 2, 'february': 2, 'feb': 2,
      'mars': 3, 'march': 3, 'mar': 3,
      'avril': 4, 'april': 4, 'apr': 4,
      'mai': 5, 'may': 5,
      'juin': 6, 'june': 6, 'jun': 6,
      'juillet': 7, 'july': 7, 'jul': 7,
      'août': 8, 'aout': 8, 'august': 8, 'aug': 8,
      'septembre': 9, 'september': 9, 'sep': 9, 'sept': 9,
      'octobre': 10, 'october': 10, 'oct': 10,
      'novembre': 11, 'november': 11, 'nov': 11,
      'décembre': 12, 'decembre': 12, 'december': 12, 'dec': 12,
    };

    return moisMap[moisLower] ?? DateTime.now().month;
  }
}

