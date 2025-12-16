import '../../core/errors/failures.dart';
import '../datasources/api_service.dart';
import '../models/parcelle_model.dart';

class ParcelleRepository {
  final ApiService _apiService;

  ParcelleRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<List<ParcelleModel>> getParcelles(int exploitationId) async {
    try {
      final response = await _apiService.getParcelles(exploitationId: exploitationId);
      final List<dynamic> data = response.data;
      return data.map((json) => ParcelleModel.fromJson(json)).toList();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  Future<ParcelleModel> createParcelle(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.createParcelle(data);
      return ParcelleModel.fromJson(response.data['parcelle']);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  Future<ParcelleModel> updateParcelle(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.updateParcelle(id, data);
      return ParcelleModel.fromJson(response.data['parcelle']);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  Future<void> deleteParcelle(int id) async {
    try {
      await _apiService.deleteParcelle(id);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }
}

