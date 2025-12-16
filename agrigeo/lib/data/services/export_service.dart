import 'dart:convert';
import 'package:csv/csv.dart';
import '../../data/models/exploitation_model.dart';
import '../../data/models/analyse_sol_model.dart';
import '../../data/models/intrant_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Service d'export de données en CSV
class ExportService {
  /// Exporte les exploitations en CSV
  Future<String> exportExploitationsToCSV(List<ExploitationModel> exploitations) async {
    final List<List<dynamic>> rows = [
      ['Nom', 'Localisation', 'Superficie (ha)', 'Type de culture', 'Latitude', 'Longitude'],
    ];

    for (final exp in exploitations) {
      rows.add([
        exp.nom,
        exp.localisationTexte ?? '',
        exp.superficieTotale,
        exp.typeCulturePrincipal ?? '',
        exp.latitude ?? '',
        exp.longitude ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    return await _saveFile('exploitations_${DateTime.now().millisecondsSinceEpoch}.csv', csv);
  }

  /// Exporte les analyses de sol en CSV
  Future<String> exportAnalysesToCSV(List<AnalyseSolModel> analyses) async {
    final List<List<dynamic>> rows = [
      [
        'Date',
        'pH',
        'Humidité (%)',
        'Texture',
        'Azote N (mg/kg)',
        'Phosphore P (mg/kg)',
        'Potassium K (mg/kg)',
        'Observations'
      ],
    ];

    for (final analyse in analyses) {
      rows.add([
        analyse.datePrelevement,
        analyse.ph ?? '',
        analyse.humidite ?? '',
        analyse.texture ?? '',
        analyse.azoteN ?? '',
        analyse.phosphoreP ?? '',
        analyse.potassiumK ?? '',
        analyse.observations ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    return await _saveFile('analyses_sol_${DateTime.now().millisecondsSinceEpoch}.csv', csv);
  }

  /// Exporte les intrants en CSV
  Future<String> exportIntrantsToCSV(List<IntrantModel> intrants) async {
    final List<List<dynamic>> rows = [
      ['Type', 'Nom commercial', 'Quantité', 'Unité', 'Date application', 'Culture'],
    ];

    for (final intrant in intrants) {
      rows.add([
        intrant.typeIntrant,
        intrant.nomCommercial ?? '',
        intrant.quantite,
        intrant.unite,
        intrant.dateApplication,
        intrant.cultureConcernee ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    return await _saveFile('intrants_${DateTime.now().millisecondsSinceEpoch}.csv', csv);
  }

  Future<String> _saveFile(String filename, String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(content);
    return file.path;
  }
}

