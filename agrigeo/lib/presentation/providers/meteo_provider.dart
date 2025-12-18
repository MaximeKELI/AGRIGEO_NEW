import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../data/models/meteo_model.dart';
import '../../data/repositories/meteo_repository.dart';

class MeteoProvider with ChangeNotifier {
  final MeteoRepository _repository;
  MeteoModel? _meteoActuelle;
  List<MeteoModel> _previsions = [];
  bool _isLoading = false;
  String? _error;

  MeteoProvider({MeteoRepository? repository})
      : _repository = repository ?? MeteoRepository();

  MeteoModel? get meteoActuelle => _meteoActuelle;
  List<MeteoModel> get previsions => _previsions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Configure la clé API OpenWeather
  void setApiKey(String apiKey) {
    _repository.setApiKey(apiKey);
  }

  /// Charge la météo actuelle
  Future<void> loadMeteoActuelle({
    required double latitude,
    required double longitude,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _meteoActuelle = await _repository.getMeteoActuelle(
        latitude: latitude,
        longitude: longitude,
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

  /// Charge les prévisions
  Future<void> loadPrevisions({
    required double latitude,
    required double longitude,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _previsions = await _repository.getPrevisions(
        latitude: latitude,
        longitude: longitude,
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

  /// Charge la météo complète (actuelle + prévisions)
  Future<void> loadMeteoComplete({
    required double latitude,
    required double longitude,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final meteoComplete = await _repository.getMeteoComplete(
        latitude: latitude,
        longitude: longitude,
      );
      _meteoActuelle = meteoComplete.actuelle;
      _previsions = meteoComplete.previsions;
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}




