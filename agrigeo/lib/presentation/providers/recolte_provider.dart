import 'package:flutter/foundation.dart';
import '../../data/models/recolte_model.dart';
import '../../data/services/recolte_service.dart';
import '../../core/errors/failures.dart';

class RecolteProvider with ChangeNotifier {
  final RecolteService _service;
  List<RecolteModel> _recoltes = [];
  RecolteStatistics? _statistics;
  RecoltePrevision? _prevision;
  bool _isLoading = false;
  String? _error;

  RecolteProvider({RecolteService? service}) : _service = service ?? RecolteService();

  List<RecolteModel> get recoltes => _recoltes;
  RecolteStatistics? get statistics => _statistics;
  RecoltePrevision? get prevision => _prevision;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRecoltes({
    int? exploitationId,
    int? parcelleId,
    String? typeCulture,
    int? annee,
    int? mois,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recoltes = await _service.getRecoltes(
        exploitationId: exploitationId,
        parcelleId: parcelleId,
        typeCulture: typeCulture,
        annee: annee,
        mois: mois,
      );
      _error = null;
    } on Failure catch (e) {
      _error = e.message;
      _recoltes = [];
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _recoltes = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadStatistics({
    int? exploitationId,
    String? typeCulture,
    int? annee,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _statistics = await _service.getStatistics(
        exploitationId: exploitationId,
        typeCulture: typeCulture,
        annee: annee,
      );
      _error = null;
    } on Failure catch (e) {
      _error = e.message;
      _statistics = null;
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _statistics = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<RecoltePrevision?> loadPrevision({
    required int exploitationId,
    required String typeCulture,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _prevision = await _service.getPrevision(
        exploitationId: exploitationId,
        typeCulture: typeCulture,
      );
      _error = null;
    } on Failure catch (e) {
      _error = e.message;
      _prevision = null;
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _prevision = null;
    }

    _isLoading = false;
    notifyListeners();
    return _prevision;
  }

  Future<bool> createRecolte(RecolteModel recolte) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nouvelleRecolte = await _service.createRecolte(recolte);
      _recoltes.add(nouvelleRecolte);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on Failure catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRecolte(int id, RecolteModel recolte) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final recolteModifiee = await _service.updateRecolte(id, recolte);
      final index = _recoltes.indexWhere((r) => r.id == id);
      if (index != -1) {
        _recoltes[index] = recolteModifiee;
      }
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on Failure catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRecolte(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteRecolte(id);
      _recoltes.removeWhere((r) => r.id == id);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on Failure catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> importFromCsv(String csvContent, int exploitationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.importFromCsv(csvContent, exploitationId: exploitationId);
      // Recharger les récoltes après l'import
      await loadRecoltes(exploitationId: exploitationId);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return result;
    } on Failure catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'erreurs': [e.message]};
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'erreurs': [e.toString()]};
    }
  }

  Future<String> exportToCsv() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final filePath = await _service.exportToCsv(_recoltes);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return filePath;
    } on Failure catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

