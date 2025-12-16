import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';

/// Service API pour communiquer avec le backend
class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiService({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ?? Dio(BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          headers: {'Content-Type': 'application/json'},
        )),
        _storage = storage ?? const FlutterSecureStorage();

  /// Ajoute le token JWT aux headers
  Future<void> _addAuthHeader() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Gère les erreurs HTTP
  Failure _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const NetworkFailure('Timeout de connexion');
    }
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      if (statusCode == 401) {
        return const AuthenticationFailure('Non authentifié');
      }
      if (statusCode == 403) {
        return const AuthenticationFailure('Accès refusé');
      }
      final message = error.response!.data['error'] ?? 'Erreur serveur';
      return ServerFailure(message);
    }
    return const NetworkFailure('Erreur de connexion');
  }

  // Auth endpoints
  Future<Response> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'username': username, 'password': password},
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> register(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiConstants.register, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> getCurrentUser() async {
    try {
      await _addAuthHeader();
      final response = await _dio.get(ApiConstants.me);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Exploitations endpoints
  Future<Response> getExploitations() async {
    try {
      await _addAuthHeader();
      final response = await _dio.get(ApiConstants.exploitations);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> createExploitation(Map<String, dynamic> data) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post(ApiConstants.exploitations, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> updateExploitation(int id, Map<String, dynamic> data) async {
    try {
      await _addAuthHeader();
      final response = await _dio.put('${ApiConstants.exploitations}/$id', data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> deleteExploitation(int id) async {
    try {
      await _addAuthHeader();
      final response = await _dio.delete('${ApiConstants.exploitations}/$id');
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Analyses sols endpoints
  Future<Response> getAnalysesSols({int? exploitationId, int? parcelleId}) async {
    try {
      await _addAuthHeader();
      final queryParams = <String, dynamic>{};
      if (exploitationId != null) queryParams['exploitation_id'] = exploitationId;
      if (parcelleId != null) queryParams['parcelle_id'] = parcelleId;
      final response = await _dio.get(ApiConstants.analysesSols, queryParameters: queryParams);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> createAnalyseSol(Map<String, dynamic> data) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post(ApiConstants.analysesSols, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> updateAnalyseSol(int id, Map<String, dynamic> data) async {
    try {
      await _addAuthHeader();
      final response = await _dio.put('${ApiConstants.analysesSols}/$id', data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> deleteAnalyseSol(int id) async {
    try {
      await _addAuthHeader();
      final response = await _dio.delete('${ApiConstants.analysesSols}/$id');
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Intrants endpoints
  Future<Response> getIntrants({int? exploitationId, int? parcelleId}) async {
    try {
      await _addAuthHeader();
      final queryParams = <String, dynamic>{};
      if (exploitationId != null) queryParams['exploitation_id'] = exploitationId;
      if (parcelleId != null) queryParams['parcelle_id'] = parcelleId;
      final response = await _dio.get(ApiConstants.intrants, queryParameters: queryParams);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> createIntrant(Map<String, dynamic> data) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post(ApiConstants.intrants, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> updateIntrant(int id, Map<String, dynamic> data) async {
    try {
      await _addAuthHeader();
      final response = await _dio.put('${ApiConstants.intrants}/$id', data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> deleteIntrant(int id) async {
    try {
      await _addAuthHeader();
      final response = await _dio.delete('${ApiConstants.intrants}/$id');
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Recommandations endpoints
  Future<Response> getRecommandations({int? exploitationId, int? parcelleId}) async {
    try {
      await _addAuthHeader();
      final queryParams = <String, dynamic>{};
      if (exploitationId != null) queryParams['exploitation_id'] = exploitationId;
      if (parcelleId != null) queryParams['parcelle_id'] = parcelleId;
      final response = await _dio.get(ApiConstants.recommandations, queryParameters: queryParams);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> generateRecommandations(int exploitationId) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('${ApiConstants.recommandations}/generate/$exploitationId');
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> updateRecommandationStatus(int id, String statut) async {
    try {
      await _addAuthHeader();
      final response = await _dio.put(
        '${ApiConstants.recommandations}/$id/status',
        data: {'statut': statut},
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> getParcelles({required int exploitationId}) async {
    try {
      await _addAuthHeader();
      final response = await _dio.get(
        ApiConstants.parcelles,
        queryParameters: {'exploitation_id': exploitationId},
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> createParcelle(Map<String, dynamic> data) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post(ApiConstants.parcelles, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> updateParcelle(int id, Map<String, dynamic> data) async {
    try {
      await _addAuthHeader();
      final response = await _dio.put('${ApiConstants.parcelles}/$id', data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> deleteParcelle(int id) async {
    try {
      await _addAuthHeader();
      final response = await _dio.delete('${ApiConstants.parcelles}/$id');
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Météo et irrigation endpoints
  Future<Response> generateConseilsIrrigation(int exploitationId, Map<String, dynamic> meteoData) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post(
        '/api/meteo/conseils-irrigation/$exploitationId',
        data: meteoData,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

