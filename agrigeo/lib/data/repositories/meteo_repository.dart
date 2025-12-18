import '../../core/errors/failures.dart';
import '../models/meteo_model.dart';
import '../services/meteo_service.dart';

class MeteoRepository {
  final MeteoService _meteoService;

  MeteoRepository({MeteoService? meteoService})
      : _meteoService = meteoService ?? MeteoService();

  /// Configure la clé API
  void setApiKey(String apiKey) {
    _meteoService.setApiKey(apiKey);
  }

  /// Récupère la météo actuelle
  Future<MeteoModel> getMeteoActuelle({
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await _meteoService.getMeteoActuelle(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      throw ServerFailure('Erreur météo: ${e.toString()}');
    }
  }

  /// Récupère les prévisions
  Future<List<MeteoModel>> getPrevisions({
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await _meteoService.getPrevisions(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      throw ServerFailure('Erreur prévisions: ${e.toString()}');
    }
  }

  /// Récupère la météo complète (actuelle + prévisions)
  Future<PrevisionMeteoModel> getMeteoComplete({
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await _meteoService.getMeteoComplete(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      throw ServerFailure('Erreur météo complète: ${e.toString()}');
    }
  }
}




