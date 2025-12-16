import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../models/image_analysis_result_model.dart';

/// Service pour l'analyse d'images avec Gemini Vision API
class GeminiVisionService {
  final Dio _dio;
  String? _apiKey;
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  GeminiVisionService({Dio? dio, String? apiKey})
      : _dio = dio ?? Dio(),
        _apiKey = apiKey ?? 'AIzaSyCwt5NygybBr9oasALOG7Ht-XhM2Dk-sIk';

  /// Configure la clé API
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  /// Analyse une image avec Gemini Vision
  /// Retourne une analyse structurée selon le type demandé
  Future<Map<String, dynamic>> analyzeImage({
    required File imageFile,
    required AnalysisType analysisType,
    double? latitude,
    double? longitude,
  }) async {
    if (_apiKey == null) {
      throw Exception('Clé API Gemini non configurée');
    }

    try {
      // Lire et encoder l'image en base64
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Construire le prompt selon le type d'analyse
      final prompt = _buildPrompt(analysisType, latitude, longitude);

      // Appel à l'API Gemini Vision
      final response = await _dio.post(
        '$_baseUrl/models/gemini-pro-vision:generateContent?key=$_apiKey',
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text': prompt,
                },
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image,
                  },
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.4,
            'topK': 32,
            'topP': 1,
            'maxOutputTokens': 2048,
          },
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      // Extraire la réponse
      final candidates = response.data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Aucune réponse du modèle');
      }

      final content = candidates[0]['content'];
      final parts = content['parts'] as List;
      if (parts.isEmpty) {
        throw Exception('Réponse vide du modèle');
      }

      final textResponse = parts[0]['text'] as String;

      // Parser la réponse JSON
      try {
        // Essayer d'extraire le JSON de la réponse
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(textResponse);
        if (jsonMatch != null) {
          return jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
        }
      } catch (e) {
        // Si le parsing JSON échoue, créer une structure à partir du texte
        return _parseTextResponse(textResponse, analysisType);
      }

      return _parseTextResponse(textResponse, analysisType);
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception('Erreur Gemini API: ${errorData['error']?['message'] ?? e.message}');
      }
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de l\'analyse: ${e.toString()}');
    }
  }

  /// Construit le prompt selon le type d'analyse
  String _buildPrompt(AnalysisType type, double? lat, double? lon) {
    final locationContext = (lat != null && lon != null)
        ? '\n\nLocalisation: Latitude $lat, Longitude $lon'
        : '';

    switch (type) {
      case AnalysisType.disease:
        return '''
Analyse cette image agricole pour détecter les maladies des plantes. 
Retourne un JSON avec la structure suivante:
{
  "diseases": [
    {
      "name": "nom de la maladie",
      "description": "description détaillée",
      "confidence": 0.0-1.0,
      "severity": "légère|modérée|sévère",
      "treatments": ["traitement 1", "traitement 2"],
      "affectedArea": "description de la zone affectée"
    }
  ],
  "confidence": 0.0-1.0
}
${locationContext}
Réponds UNIQUEMENT en JSON valide, sans texte supplémentaire.
''';

      case AnalysisType.plant:
        return '''
Analyse cette image pour identifier les plantes agricoles visibles.
Retourne un JSON avec la structure suivante:
{
  "plants": [
    {
      "name": "nom commun",
      "scientificName": "nom scientifique",
      "confidence": 0.0-1.0,
      "growthStage": "stade de croissance",
      "healthStatus": "bon|moyen|mauvais"
    }
  ],
  "confidence": 0.0-1.0
}
${locationContext}
Réponds UNIQUEMENT en JSON valide, sans texte supplémentaire.
''';

      case AnalysisType.soil:
        return '''
Analyse cette image pour évaluer l'état du sol agricole.
Retourne un JSON avec la structure suivante:
{
  "soilAnalysis": {
    "texture": "sableux|argileux|limoneux",
    "color": "couleur du sol",
    "moistureLevel": 0.0-1.0,
    "quality": "excellent|bon|moyen|mauvais",
    "issues": ["problème 1", "problème 2"]
  },
  "confidence": 0.0-1.0
}
${locationContext}
Réponds UNIQUEMENT en JSON valide, sans texte supplémentaire.
''';

      case AnalysisType.weather:
        return '''
Analyse cette image pour déterminer les conditions météorologiques visibles.
Retourne un JSON avec la structure suivante:
{
  "weather": {
    "condition": "ensoleillé|nuageux|pluvieux|brumeux",
    "temperature": température estimée en °C,
    "humidity": humidité estimée en %,
    "cloudCover": "faible|moyenne|forte",
    "visibility": "bonne|moyenne|faible"
  },
  "confidence": 0.0-1.0
}
${locationContext}
Réponds UNIQUEMENT en JSON valide, sans texte supplémentaire.
''';

      case AnalysisType.field:
        return '''
Analyse cette image d'une zone agricole/champ.
Détecte les plantes, l'état du sol, les maladies potentielles, et les conditions météo.
Retourne un JSON complet avec toutes les informations détectées.
${locationContext}
Réponds UNIQUEMENT en JSON valide, sans texte supplémentaire.
''';

      case AnalysisType.general:
      default:
        return '''
Analyse cette image agricole de manière complète.
Détecte:
- Les plantes visibles
- Les maladies potentielles
- L'état du sol
- Les conditions météorologiques
- Donne des recommandations agricoles

Retourne un JSON complet avec toutes les informations.
${locationContext}
Réponds UNIQUEMENT en JSON valide, sans texte supplémentaire.
''';
    }
  }

  /// Parse une réponse texte en structure JSON
  Map<String, dynamic> _parseTextResponse(String text, AnalysisType type) {
    // Essayer d'extraire des informations structurées du texte
    final result = <String, dynamic>{};

    // Détection de maladies
    if (text.toLowerCase().contains('maladie') ||
        text.toLowerCase().contains('disease')) {
      result['diseases'] = [
        {
          'name': 'Maladie détectée',
          'description': text,
          'confidence': 0.7,
          'severity': 'modérée',
        }
      ];
    }

    // Détection de plantes
    if (text.toLowerCase().contains('plante') ||
        text.toLowerCase().contains('plant')) {
      result['plants'] = [
        {
          'name': 'Plante détectée',
          'scientificName': 'Inconnu',
          'confidence': 0.7,
        }
      ];
    }

    result['confidence'] = 0.6;
    result['rawText'] = text;

    return result;
  }
}

