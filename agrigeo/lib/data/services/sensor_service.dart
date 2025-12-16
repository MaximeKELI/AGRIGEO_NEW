import '../../core/errors/failures.dart';
import '../datasources/api_service.dart';
import '../models/sensor_data_model.dart';

/// Service pour gérer les capteurs IoT et leurs données
class SensorService {
  final ApiService _apiService;

  SensorService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  /// Récupère la liste des capteurs
  Future<List<SensorModel>> getSensors({
    int? exploitationId,
    int? parcelleId,
    String? sensorType,
    bool? isActive,
  }) async {
    try {
      final response = await _apiService.getSensors(
        exploitationId: exploitationId,
        parcelleId: parcelleId,
        sensorType: sensorType,
        isActive: isActive,
      );
      final List<dynamic> sensorsData = response.data;
      return sensorsData.map((json) => SensorModel.fromJson(json)).toList();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Récupère un capteur par ID
  Future<SensorModel> getSensor(int sensorId) async {
    try {
      final response = await _apiService.getSensor(sensorId);
      return SensorModel.fromJson(response.data);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Enregistre un nouveau capteur
  Future<SensorModel> createSensor(SensorModel sensor) async {
    try {
      final response = await _apiService.createSensor(sensor.toJson());
      return SensorModel.fromJson(response.data['sensor']);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Met à jour un capteur
  Future<SensorModel> updateSensor(int sensorId, SensorModel sensor) async {
    try {
      final response = await _apiService.updateSensor(sensorId, sensor.toJson());
      return SensorModel.fromJson(response.data['sensor']);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Récupère les données d'un capteur
  Future<List<SensorDataModel>> getSensorData({
    String? sensorId,
    String? sensorType,
    int? exploitationId,
    int? parcelleId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _apiService.getSensorData(
        sensorId: sensorId,
        sensorType: sensorType,
        exploitationId: exploitationId,
        parcelleId: parcelleId,
        startDate: startDate,
        endDate: endDate,
      );
      final List<dynamic> dataList = response.data['items'] ?? response.data;
      return dataList.map((json) => SensorDataModel.fromJson(json)).toList();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Envoie des données de capteur (pour les capteurs IoT)
  Future<SensorDataModel> sendSensorData(SensorDataModel sensorData) async {
    try {
      final response = await _apiService.sendSensorData(sensorData.toJson());
      return SensorDataModel.fromJson(response.data['sensor_data']);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  /// Convertit les données de capteurs en données d'analyse de sol
  Map<String, dynamic> convertSensorDataToAnalyseSol({
    required List<SensorDataModel> sensorDataList,
    required String datePrelevement,
    required int exploitationId,
    int? parcelleId,
    String? observations,
  }) {
    final Map<String, dynamic> analyseData = {
      'date_prelevement': datePrelevement,
      'exploitation_id': exploitationId,
      if (parcelleId != null) 'parcelle_id': parcelleId,
      if (observations != null) 'observations': observations,
      'sensor_data': sensorDataList.map((data) => data.toJson()).toList(),
    };

    // Convertir les données de capteurs en champs d'analyse
    for (final sensorData in sensorDataList) {
      final converted = sensorData.toAnalyseSolData();
      analyseData.addAll(converted);
    }

    return analyseData;
  }

  /// Récupère les dernières données de capteurs pour une parcelle/exploitation
  Future<Map<String, dynamic>> getLatestSensorDataForAnalyse({
    required int exploitationId,
    int? parcelleId,
  }) async {
    try {
      final sensors = await getSensors(
        exploitationId: exploitationId,
        parcelleId: parcelleId,
        isActive: true,
      );

      final Map<String, dynamic> analyseData = {};
      final List<Map<String, dynamic>> sensorDataList = [];

      for (final sensor in sensors) {
        final data = await getSensorData(
          sensorId: sensor.sensorId,
          exploitationId: exploitationId,
          parcelleId: parcelleId,
        );

        if (data.isNotEmpty) {
          // Prendre la dernière mesure
          final latestData = data.first;
          sensorDataList.add(latestData.toJson());

          // Convertir en données d'analyse
          final converted = latestData.toAnalyseSolData();
          analyseData.addAll(converted);
        }
      }

      if (sensorDataList.isNotEmpty) {
        analyseData['sensor_data'] = sensorDataList;
      }

      return analyseData;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }
}

