import 'dart:convert';
import '../../core/errors/failures.dart';
import '../datasources/api_service.dart';
import '../datasources/local_database.dart';
import '../models/intrant_model.dart';
import '../../core/utils/network_info.dart';

class IntrantRepository {
  final ApiService _apiService;
  final LocalDatabase _localDb;
  final NetworkInfo _networkInfo;

  IntrantRepository({
    ApiService? apiService,
    LocalDatabase? localDb,
    NetworkInfo? networkInfo,
  })  : _apiService = apiService ?? ApiService(),
        _localDb = localDb ?? LocalDatabase(),
        _networkInfo = networkInfo ?? NetworkInfoImpl();

  Future<List<IntrantModel>> getIntrants({
    int? exploitationId,
    int? parcelleId,
  }) async {
    try {
      final isConnected = await _networkInfo.isConnected;
      
      if (isConnected) {
        try {
          final response = await _apiService.getIntrants(
            exploitationId: exploitationId,
            parcelleId: parcelleId,
          );
          final List<dynamic> data = response.data;
          return data.map((json) => IntrantModel.fromJson(json)).toList();
        } catch (e) {
          // Si erreur réseau, utiliser les données locales
        }
      }

      final localData = await _localDb.getIntrants(
        exploitationId: exploitationId,
      );
      return localData.map((json) {
        return IntrantModel.fromJson({
          'id': json['id'],
          'type_intrant': json['type_intrant'],
          'nom_commercial': json['nom_commercial'],
          'quantite': json['quantite'],
          'unite': json['unite'] ?? 'kg',
          'date_application': json['date_application'],
          'culture_concernée': json['culture_concernée'],
          'exploitation_id': json['exploitation_id'],
          'parcelle_id': json['parcelle_id'],
          'created_at': json['created_at'],
        });
      }).toList();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  Future<IntrantModel> createIntrant(Map<String, dynamic> data) async {
    try {
      final isConnected = await _networkInfo.isConnected;

      if (isConnected) {
        try {
          final response = await _apiService.createIntrant(data);
          return IntrantModel.fromJson(response.data['intrant']);
        } catch (e) {
          // Si erreur, sauvegarder localement
        }
      }

      final localData = Map<String, dynamic>.from(data);
      localData['synced'] = 0;
      localData['created_at'] = DateTime.now().toIso8601String();
      
      final localId = await _localDb.insertIntrant(localData);
      localData['id'] = localId;
      
      return IntrantModel.fromJson(localData);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  Future<IntrantModel> updateIntrant(int id, Map<String, dynamic> data) async {
    try {
      final isConnected = await _networkInfo.isConnected;

      if (isConnected) {
        final response = await _apiService.updateIntrant(id, data);
        return IntrantModel.fromJson(response.data['intrant']);
      }

      final localData = Map<String, dynamic>.from(data);
      localData['synced'] = 0;
      localData['updated_at'] = DateTime.now().toIso8601String();
      
      await _localDb.updateIntrant(id, localData);
      localData['id'] = id;
      
      return IntrantModel.fromJson(localData);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  Future<void> deleteIntrant(int id) async {
    try {
      final isConnected = await _networkInfo.isConnected;

      if (isConnected) {
        await _apiService.deleteIntrant(id);
        return;
      }

      await _localDb.deleteIntrant(id);
      await _localDb.addToSyncQueue('delete', 'intrant', {'id': id});
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }
}

