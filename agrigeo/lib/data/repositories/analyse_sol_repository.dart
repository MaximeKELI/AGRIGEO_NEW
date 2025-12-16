import '../../core/errors/failures.dart';
import '../datasources/api_service.dart';
import '../datasources/local_database.dart';
import '../models/analyse_sol_model.dart';
import '../services/sync_service.dart';
import '../../core/utils/network_info.dart';

class AnalyseSolRepository {
  final ApiService _apiService;
  final LocalDatabase _localDb;
  final NetworkInfo _networkInfo;

  AnalyseSolRepository({
    ApiService? apiService,
    LocalDatabase? localDb,
    NetworkInfo? networkInfo,
  })  : _apiService = apiService ?? ApiService(),
        _localDb = localDb ?? LocalDatabase(),
        _networkInfo = networkInfo ?? NetworkInfoImpl();

  Future<List<AnalyseSolModel>> getAnalysesSols({
    int? exploitationId,
    int? parcelleId,
  }) async {
    try {
      final isConnected = await _networkInfo.isConnected;
      
      if (isConnected) {
        // Essayer de récupérer depuis l'API
        try {
          final response = await _apiService.getAnalysesSols(
            exploitationId: exploitationId,
            parcelleId: parcelleId,
          );
          final List<dynamic> data = response.data;
          return data.map((json) => AnalyseSolModel.fromJson(json)).toList();
        } catch (e) {
          // Si erreur réseau, utiliser les données locales
        }
      }

      // Récupérer depuis la base locale
      final localData = await _localDb.getAnalysesSols(
        exploitationId: exploitationId,
      );
      return localData.map((json) => AnalyseSolModel.fromJson(json)).toList();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  Future<AnalyseSolModel> createAnalyseSol(Map<String, dynamic> data) async {
    try {
      final isConnected = await _networkInfo.isConnected;

      if (isConnected) {
        try {
          final response = await _apiService.createAnalyseSol(data);
          return AnalyseSolModel.fromJson(response.data['analyse']);
        } catch (e) {
          // Si erreur, sauvegarder localement
        }
      }

      // Sauvegarder localement
      final localData = Map<String, dynamic>.from(data);
      localData['synced'] = 0;
      localData['created_at'] = DateTime.now().toIso8601String();
      
      final localId = await _localDb.insertAnalyseSol(localData);
      localData['id'] = localId;
      
      return AnalyseSolModel.fromJson(localData);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  Future<AnalyseSolModel> updateAnalyseSol(int id, Map<String, dynamic> data) async {
    try {
      final isConnected = await _networkInfo.isConnected;

      if (isConnected) {
        final response = await _apiService.updateAnalyseSol(id, data);
        return AnalyseSolModel.fromJson(response.data['analyse']);
      }

      // Mettre à jour localement
      final localData = Map<String, dynamic>.from(data);
      localData['synced'] = 0;
      localData['updated_at'] = DateTime.now().toIso8601String();
      
      await _localDb.updateAnalyseSol(id, localData);
      localData['id'] = id;
      
      return AnalyseSolModel.fromJson(localData);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  Future<void> deleteAnalyseSol(int id) async {
    try {
      final isConnected = await _networkInfo.isConnected;

      if (isConnected) {
        await _apiService.deleteAnalyseSol(id);
        return;
      }

      // Supprimer localement et ajouter à la queue
      await _localDb.deleteAnalyseSol(id);
      await _localDb.addToSyncQueue('delete', 'analyse_sol', {'id': id});
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }
}

