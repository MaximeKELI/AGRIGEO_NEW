import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../data/models/image_analysis_result_model.dart';
import '../../data/services/image_analysis_service.dart';

/// Provider pour gérer l'analyse d'images IA
class ImageAnalysisProvider with ChangeNotifier {
  final ImageAnalysisService _service;
  
  File? _selectedImage;
  ImageAnalysisResultModel? _lastAnalysisResult;
  List<ImageAnalysisResultModel> _analysisHistory = [];
  bool _isAnalyzing = false;
  String? _error;
  AnalysisType _selectedAnalysisType = AnalysisType.general;

  ImageAnalysisProvider({ImageAnalysisService? service})
      : _service = service ?? ImageAnalysisService();

  File? get selectedImage => _selectedImage;
  ImageAnalysisResultModel? get lastAnalysisResult => _lastAnalysisResult;
  List<ImageAnalysisResultModel> get analysisHistory => _analysisHistory;
  bool get isAnalyzing => _isAnalyzing;
  String? get error => _error;
  AnalysisType get selectedAnalysisType => _selectedAnalysisType;

  /// Configure les credentials Sentinel Hub
  Future<void> setSentinelHubCredentials({
    required String apiKey,
    required String apiSecret,
  }) async {
    try {
      await _service.setSentinelHubCredentials(
        apiKey: apiKey,
        apiSecret: apiSecret,
      );
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Charge les credentials depuis le stockage
  Future<void> loadCredentials() async {
    try {
      await _service.loadCredentials();
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  /// Sélectionne une image pour l'analyse
  void selectImage(File imageFile) {
    _selectedImage = imageFile;
    _error = null;
    notifyListeners();
  }

  /// Définit le type d'analyse souhaité
  void setAnalysisType(AnalysisType type) {
    _selectedAnalysisType = type;
    notifyListeners();
  }

  /// Analyse l'image sélectionnée
  Future<void> analyzeImage({
    double? latitude,
    double? longitude,
  }) async {
    if (_selectedImage == null) {
      _error = 'Aucune image sélectionnée';
      notifyListeners();
      return;
    }

    _isAnalyzing = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.analyzeImage(
        imageFile: _selectedImage!,
        analysisType: _selectedAnalysisType,
        latitude: latitude,
        longitude: longitude,
      );

      _lastAnalysisResult = result;
      _analysisHistory.insert(0, result); // Ajouter au début de l'historique
      _isAnalyzing = false;
      notifyListeners();
    } on Failure catch (e) {
      _error = e.message;
      _isAnalyzing = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l\'analyse: ${e.toString()}';
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Analyse rapide (détection automatique)
  Future<void> quickAnalyze() async {
    if (_selectedImage == null) {
      _error = 'Aucune image sélectionnée';
      notifyListeners();
      return;
    }

    _isAnalyzing = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.quickAnalyze(_selectedImage!);
      _lastAnalysisResult = result;
      _analysisHistory.insert(0, result);
      _isAnalyzing = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l\'analyse: ${e.toString()}';
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Analyse spécifique pour les maladies
  Future<void> analyzeForDiseases() async {
    if (_selectedImage == null) {
      _error = 'Aucune image sélectionnée';
      notifyListeners();
      return;
    }

    _isAnalyzing = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.analyzeForDiseases(_selectedImage!);
      _lastAnalysisResult = result;
      _analysisHistory.insert(0, result);
      _isAnalyzing = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l\'analyse: ${e.toString()}';
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Analyse spécifique pour les plantes
  Future<void> analyzeForPlants() async {
    if (_selectedImage == null) {
      _error = 'Aucune image sélectionnée';
      notifyListeners();
      return;
    }

    _isAnalyzing = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.analyzeForPlants(_selectedImage!);
      _lastAnalysisResult = result;
      _analysisHistory.insert(0, result);
      _isAnalyzing = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l\'analyse: ${e.toString()}';
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Analyse spécifique pour le sol
  Future<void> analyzeForSoil() async {
    if (_selectedImage == null) {
      _error = 'Aucune image sélectionnée';
      notifyListeners();
      return;
    }

    _isAnalyzing = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.analyzeForSoil(_selectedImage!);
      _lastAnalysisResult = result;
      _analysisHistory.insert(0, result);
      _isAnalyzing = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l\'analyse: ${e.toString()}';
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Analyse spécifique pour la météo
  Future<void> analyzeForWeather() async {
    if (_selectedImage == null) {
      _error = 'Aucune image sélectionnée';
      notifyListeners();
      return;
    }

    _isAnalyzing = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.analyzeForWeather(_selectedImage!);
      _lastAnalysisResult = result;
      _analysisHistory.insert(0, result);
      _isAnalyzing = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l\'analyse: ${e.toString()}';
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Efface l'image sélectionnée
  void clearImage() {
    _selectedImage = null;
    _error = null;
    notifyListeners();
  }

  /// Efface les résultats
  void clearResults() {
    _lastAnalysisResult = null;
    notifyListeners();
  }

  /// Efface l'historique
  void clearHistory() {
    _analysisHistory.clear();
    notifyListeners();
  }

  /// Efface l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

