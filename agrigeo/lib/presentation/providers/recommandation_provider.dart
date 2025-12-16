import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../data/models/recommandation_model.dart';
import '../../data/repositories/recommandation_repository.dart';

class RecommandationProvider with ChangeNotifier {
  final RecommandationRepository _repository;
  List<RecommandationModel> _recommandations = [];
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _error;

  RecommandationProvider({RecommandationRepository? repository})
      : _repository = repository ?? RecommandationRepository();

  List<RecommandationModel> get recommandations => _recommandations;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get error => _error;

  Future<void> loadRecommandations({int? exploitationId, int? parcelleId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recommandations = await _repository.getRecommandations(
        exploitationId: exploitationId,
        parcelleId: parcelleId,
      );
      _isLoading = false;
      notifyListeners();
    } on Failure catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> generateRecommandations(int exploitationId) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      final nouvellesRecommandations = await _repository.generateRecommandations(exploitationId);
      _recommandations.addAll(nouvellesRecommandations);
      _isGenerating = false;
      notifyListeners();
      return true;
    } on Failure catch (e) {
      _error = e.message;
      _isGenerating = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erreur inattendue: ${e.toString()}';
      _isGenerating = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRecommandationStatus(int id, String statut) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final recommandation = await _repository.updateRecommandationStatus(id, statut);
      final index = _recommandations.indexWhere((r) => r.id == id);
      if (index != -1) {
        _recommandations[index] = recommandation;
      }
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

