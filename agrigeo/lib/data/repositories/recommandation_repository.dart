import '../../core/errors/failures.dart';
import '../datasources/api_service.dart';
import '../models/recommandation_model.dart';

class RecommandationRepository {
  final ApiService _apiService;

  RecommandationRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<List<RecommandationModel>> getRecommandations({
    int? exploitationId,
    int? parcelleId,
  }) async {
    try {
      final response = await _apiService.getRecommandations(
        exploitationId: exploitationId,
        parcelleId: parcelleId,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => RecommandationModel.fromJson(json)).toList();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  Future<List<RecommandationModel>> generateRecommandations(int exploitationId) async {
    try {
      final response = await _apiService.generateRecommandations(exploitationId);
      final List<dynamic> data = response.data['recommandations'];
      return data.map((json) => RecommandationModel.fromJson(json)).toList();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  Future<RecommandationModel> updateRecommandationStatus(int id, String statut) async {
    try {
      final response = await _apiService.updateRecommandationStatus(id, statut);
      return RecommandationModel.fromJson(response.data['recommandation']);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }
}

