import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import '../models/image_analysis_result_model.dart';
import '../../core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour l'analyse d'images agricoles avec IA
/// Support pour Sentinel Hub API (à configurer avec la clé API)
class ImageAnalysisService {
  final Dio _dio;
  String? _sentinelHubApiKey;
  String? _sentinelHubApiSecret;
  
  // Base URL Sentinel Hub (à ajuster selon la configuration)
  static const String sentinelHubBaseUrl = 'https://services.sentinel-hub.com/api/v1';
  
  ImageAnalysisService({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(
          baseUrl: sentinelHubBaseUrl,
          headers: {'Content-Type': 'application/json'},
        ));

  /// Configure les clés API Sentinel Hub
  Future<void> setSentinelHubCredentials({
    required String apiKey,
    required String apiSecret,
  }) async {
    _sentinelHubApiKey = apiKey;
    _sentinelHubApiSecret = apiSecret;
    
    // Sauvegarder dans les préférences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${AppConstants.sentinelHubApiKey}_key', apiKey);
    await prefs.setString('${AppConstants.sentinelHubApiKey}_secret', apiSecret);
  }

  /// Charge les credentials depuis les préférences
  Future<void> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    _sentinelHubApiKey = prefs.getString('${AppConstants.sentinelHubApiKey}_key');
    _sentinelHubApiSecret = prefs.getString('${AppConstants.sentinelHubApiKey}_secret');
  }

  /// Vérifie que les credentials sont configurés
  void _checkCredentials() {
    if (_sentinelHubApiKey == null || _sentinelHubApiSecret == null) {
      throw Exception('Clés API Sentinel Hub non configurées. Veuillez les configurer dans les paramètres.');
    }
  }

  /// Convertit une image en base64
  Future<String> _imageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  /// Redimensionne une image si nécessaire (max 10MB pour l'API)
  Future<File> _resizeImageIfNeeded(File imageFile) async {
    final fileSize = await imageFile.length();
    const maxSize = 10 * 1024 * 1024; // 10MB

    if (fileSize <= maxSize) {
      return imageFile;
    }

    // Lire et redimensionner l'image
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) {
      throw Exception('Impossible de décoder l\'image');
    }

    // Redimensionner à 80% de la taille originale jusqu'à ce que ça rentre
    img.Image resized = image;
    double scale = 0.8;
    
    while ((resized.width * resized.height * 4) > maxSize && scale > 0.1) {
      final newWidth = (resized.width * scale).round();
      final newHeight = (resized.height * scale).round();
      resized = img.copyResize(resized, width: newWidth, height: newHeight);
      scale *= 0.8;
    }

    // Encoder en JPEG avec qualité réduite
    final resizedBytes = img.encodeJpg(resized, quality: 85);
    final resizedFile = File(imageFile.path.replaceAll('.jpg', '_resized.jpg')
        .replaceAll('.png', '_resized.jpg')
        .replaceAll('.jpeg', '_resized.jpg'));
    
    await resizedFile.writeAsBytes(resizedBytes);
    return resizedFile;
  }

  /// Analyse une image avec Sentinel Hub API
  /// [imageFile] : Fichier image à analyser
  /// [analysisType] : Type d'analyse souhaitée
  /// [latitude] et [longitude] : Coordonnées GPS optionnelles pour contexte géographique
  Future<ImageAnalysisResultModel> analyzeImage({
    required File imageFile,
    required AnalysisType analysisType,
    double? latitude,
    double? longitude,
  }) async {
    _checkCredentials();
    await loadCredentials();
    _checkCredentials();

    try {
      // Redimensionner l'image si nécessaire
      final processedImage = await _resizeImageIfNeeded(imageFile);
      final imageBase64 = await _imageToBase64(processedImage);

      // Préparer la requête pour Sentinel Hub
      // Note: Cette structure devra être ajustée selon l'API Sentinel Hub réelle
      final requestData = {
        'image': imageBase64,
        'analysis_type': analysisType.name,
        if (latitude != null && longitude != null) ...{
          'latitude': latitude,
          'longitude': longitude,
        },
        'options': {
          'detect_diseases': analysisType == AnalysisType.disease || analysisType == AnalysisType.general,
          'detect_plants': analysisType == AnalysisType.plant || analysisType == AnalysisType.general,
          'analyze_weather': analysisType == AnalysisType.weather || analysisType == AnalysisType.general,
          'analyze_soil': analysisType == AnalysisType.soil || analysisType == AnalysisType.general,
        },
      };

      // Appel API Sentinel Hub
      // TODO: Ajuster l'endpoint selon la documentation Sentinel Hub
      final response = await _dio.post(
        '/analyze',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_sentinelHubApiKey',
            // Ou selon le format d'authentification Sentinel Hub
          },
        ),
      );

      // Parser la réponse
      return _parseAnalysisResponse(
        response.data,
        imageFile.path,
        analysisType,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMsg = e.response!.data['message'] ?? e.message;
        throw Exception('Erreur lors de l\'analyse: $errorMsg');
      }
      throw Exception('Erreur lors de l\'analyse: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de l\'analyse: $e');
    }
  }

  /// Parse la réponse de l'API Sentinel Hub
  ImageAnalysisResultModel _parseAnalysisResponse(
    Map<String, dynamic> response,
    String imagePath,
    AnalysisType analysisType,
  ) {
    return ImageAnalysisResultModel(
      id: response['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      analyzedAt: DateTime.now(),
      type: analysisType,
      diseases: response['diseases'] != null
          ? (response['diseases'] as List)
              .map((d) => DiseaseDetection.fromJson(d))
              .toList()
          : null,
      plants: response['plants'] != null
          ? (response['plants'] as List)
              .map((p) => PlantDetection.fromJson(p))
              .toList()
          : null,
      weather: response['weather'] != null
          ? WeatherInfo.fromJson(response['weather'])
          : null,
      recommendations: response['recommendations'] != null
          ? (response['recommendations'] as List)
              .map((r) => Recommendation.fromJson(r))
              .toList()
          : null,
      soilAnalysis: response['soil_analysis'] != null
          ? SoilAnalysis.fromJson(response['soil_analysis'])
          : null,
      confidence: response['confidence']?.toDouble(),
      metadata: response['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Analyse rapide avec détection automatique du type
  Future<ImageAnalysisResultModel> quickAnalyze(File imageFile) async {
    return analyzeImage(
      imageFile: imageFile,
      analysisType: AnalysisType.general,
    );
  }

  /// Analyse spécifique pour les maladies
  Future<ImageAnalysisResultModel> analyzeForDiseases(File imageFile) async {
    return analyzeImage(
      imageFile: imageFile,
      analysisType: AnalysisType.disease,
    );
  }

  /// Analyse spécifique pour les plantes
  Future<ImageAnalysisResultModel> analyzeForPlants(File imageFile) async {
    return analyzeImage(
      imageFile: imageFile,
      analysisType: AnalysisType.plant,
    );
  }

  /// Analyse spécifique pour le sol
  Future<ImageAnalysisResultModel> analyzeForSoil(File imageFile) async {
    return analyzeImage(
      imageFile: imageFile,
      analysisType: AnalysisType.soil,
    );
  }

  /// Analyse spécifique pour la météo
  Future<ImageAnalysisResultModel> analyzeForWeather(File imageFile) async {
    return analyzeImage(
      imageFile: imageFile,
      analysisType: AnalysisType.weather,
    );
  }
}

