import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../data/models/parcelle_model.dart';
import '../../data/repositories/parcelle_repository.dart';

class ParcelleProvider with ChangeNotifier {
  final ParcelleRepository _repository;
  List<ParcelleModel> _parcelles = [];
  bool _isLoading = false;
  String? _error;

  ParcelleProvider({ParcelleRepository? repository})
      : _repository = repository ?? ParcelleRepository();

  List<ParcelleModel> get parcelles => _parcelles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadParcelles(int exploitationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _parcelles = await _repository.getParcelles(exploitationId);
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

  Future<bool> createParcelle(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final parcelle = await _repository.createParcelle(data);
      _parcelles.add(parcelle);
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

  Future<bool> updateParcelle(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final parcelle = await _repository.updateParcelle(id, data);
      final index = _parcelles.indexWhere((p) => p.id == id);
      if (index != -1) {
        _parcelles[index] = parcelle;
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

  Future<bool> deleteParcelle(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteParcelle(id);
      _parcelles.removeWhere((p) => p.id == id);
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

