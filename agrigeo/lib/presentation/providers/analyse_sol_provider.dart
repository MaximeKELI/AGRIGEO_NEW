import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../data/models/analyse_sol_model.dart';
import '../../data/repositories/analyse_sol_repository.dart';

class AnalyseSolProvider with ChangeNotifier {
  final AnalyseSolRepository _repository;
  List<AnalyseSolModel> _analyses = [];
  bool _isLoading = false;
  String? _error;

  AnalyseSolProvider({AnalyseSolRepository? repository})
      : _repository = repository ?? AnalyseSolRepository();

  List<AnalyseSolModel> get analyses => _analyses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAnalyses({int? exploitationId, int? parcelleId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _analyses = await _repository.getAnalysesSols(
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

  Future<bool> createAnalyse(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final analyse = await _repository.createAnalyseSol(data);
      _analyses.add(analyse);
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

  Future<bool> updateAnalyse(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final analyse = await _repository.updateAnalyseSol(id, data);
      final index = _analyses.indexWhere((a) => a.id == id);
      if (index != -1) {
        _analyses[index] = analyse;
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

  Future<bool> deleteAnalyse(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteAnalyseSol(id);
      _analyses.removeWhere((a) => a.id == id);
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

