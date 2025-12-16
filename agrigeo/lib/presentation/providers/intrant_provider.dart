import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../data/models/intrant_model.dart';
import '../../data/repositories/intrant_repository.dart';

class IntrantProvider with ChangeNotifier {
  final IntrantRepository _repository;
  List<IntrantModel> _intrants = [];
  bool _isLoading = false;
  String? _error;

  IntrantProvider({IntrantRepository? repository})
      : _repository = repository ?? IntrantRepository();

  List<IntrantModel> get intrants => _intrants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadIntrants({int? exploitationId, int? parcelleId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _intrants = await _repository.getIntrants(
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

  Future<bool> createIntrant(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final intrant = await _repository.createIntrant(data);
      _intrants.add(intrant);
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

  Future<bool> updateIntrant(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final intrant = await _repository.updateIntrant(id, data);
      final index = _intrants.indexWhere((i) => i.id == id);
      if (index != -1) {
        _intrants[index] = intrant;
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

  Future<bool> deleteIntrant(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteIntrant(id);
      _intrants.removeWhere((i) => i.id == id);
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

