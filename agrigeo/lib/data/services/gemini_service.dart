import 'package:dio/dio.dart';
import '../models/chat_message_model.dart';

/// Service pour communiquer avec l'API Gemini
class GeminiService {
  final Dio _dio;
  String? _apiKey;
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  GeminiService({Dio? dio, String? apiKey})
      : _dio = dio ?? Dio(),
        _apiKey = apiKey ?? 'AIzaSyABPjT80rKdL1WFSCsEyUJehFgUP8PMnrY';

  /// Configure la clé API
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  /// Système prompt pour limiter le chatbot à l'agriculture
  String _buildSystemPrompt(Map<String, dynamic>? contextData) {
    String prompt = '''
Tu es un assistant agricole expert spécialisé dans l'agriculture au Togo et en Afrique. 
Tu ne dois parler QUE d'agriculture, de gestion des sols, de cultures, d'irrigation, d'intrants, et de pratiques agricoles.
Si on te pose une question qui n'est pas liée à l'agriculture, tu dois poliment rediriger la conversation vers l'agriculture.

Tu peux aider avec :
- Conseils sur la gestion des sols
- Recommandations d'irrigation
- Gestion des intrants agricoles
- Analyse des données de sol (pH, nutriments)
- Planification des cultures
- Pratiques agricoles durables
- Agriculture au Togo et en Afrique

Réponds toujours en français et de manière professionnelle et pédagogique.
''';
    
    if (contextData != null) {
      prompt += '\n\nContexte de l\'application AGRIGEO:\n';
      
      if (contextData['exploitation'] != null) {
        final exp = contextData['exploitation'];
        prompt += '- Exploitation: ${exp['nom'] ?? 'N/A'}, Superficie: ${exp['superficie_totale'] ?? 'N/A'} ha\n';
        if (exp['type_culture_principal'] != null) {
          prompt += '- Type de culture: ${exp['type_culture_principal']}\n';
        }
      }
      
      if (contextData['derniere_analyse'] != null) {
        final analyse = contextData['derniere_analyse'];
        prompt += '\nDernière analyse de sol:\n';
        if (analyse['ph'] != null) prompt += '- pH: ${analyse['ph']}\n';
        if (analyse['azote_n'] != null) prompt += '- Azote (N): ${analyse['azote_n']} mg/kg\n';
        if (analyse['phosphore_p'] != null) prompt += '- Phosphore (P): ${analyse['phosphore_p']} mg/kg\n';
        if (analyse['potassium_k'] != null) prompt += '- Potassium (K): ${analyse['potassium_k']} mg/kg\n';
      }
      
      if (contextData['meteo'] != null) {
        final meteo = contextData['meteo'];
        prompt += '\nMétéo actuelle:\n';
        if (meteo['temperature'] != null) prompt += '- Température: ${meteo['temperature']}°C\n';
        if (meteo['pluviometrie'] != null) prompt += '- Pluviométrie: ${meteo['pluviometrie']} mm\n';
        if (meteo['humidite'] != null) prompt += '- Humidité: ${meteo['humidite']}%\n';
      }
    }
    
    return prompt;
  }

  /// Envoie un message au chatbot Gemini
  Future<String> sendMessage(
    String userMessage, {
    List<ChatMessageModel>? conversationHistory,
    Map<String, dynamic>? contextData,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('Clé API Gemini non configurée');
    }

    try {
      // Construire le prompt système avec le contexte
      final systemPrompt = _buildSystemPrompt(contextData);

      // Construire l'historique de conversation (sans le message de bienvenue système)
      final List<Map<String, dynamic>> contents = [];
      
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        // Filtrer pour ne garder que les messages user/assistant réels
        final filteredHistory = conversationHistory.where((msg) => 
          msg.role == MessageRole.user || 
          (msg.role == MessageRole.assistant && 
           msg.content.isNotEmpty && 
           !msg.content.contains('Bonjour ! Je suis votre assistant'))
        ).toList();
        
        for (final msg in filteredHistory) {
          if (msg.role == MessageRole.user || msg.role == MessageRole.assistant) {
            contents.add({
              'role': msg.role == MessageRole.user ? 'user' : 'model',
              'parts': [{'text': msg.content}]
            });
          }
        }
      }

      // Ajouter le nouveau message de l'utilisateur
      contents.add({
        'role': 'user',
        'parts': [{'text': userMessage}]
      });

      // Préparer les données de la requête
      final requestData = <String, dynamic>{
        'contents': contents,
        'systemInstruction': {
          'parts': [{'text': systemPrompt}]
        },
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 2048,
        },
      };

      // Appel à l'API Gemini (utiliser gemini-2.5-flash qui est disponible)
      final response = await _dio.post(
        '$_baseUrl/models/gemini-2.5-flash:generateContent?key=$_apiKey',
        data: requestData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      // Vérifier les erreurs HTTP
      if (response.statusCode != 200) {
        if (response.data != null && response.data['error'] != null) {
          final error = response.data['error'];
          throw Exception('Erreur Gemini API: ${error['message'] ?? 'Erreur inconnue'} (Code: ${error['code'] ?? response.statusCode})');
        }
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.statusMessage}');
      }

      // Extraire la réponse
      if (response.data == null) {
        throw Exception('Réponse vide de l\'API');
      }
      
      final candidates = response.data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        // Vérifier s'il y a une erreur dans la réponse
        if (response.data['error'] != null) {
          final error = response.data['error'];
          throw Exception('Erreur API: ${error['message'] ?? 'Erreur inconnue'}');
        }
        throw Exception('Aucune réponse du modèle. Réponse: ${response.data}');
      }

      final content = candidates[0]['content'];
      if (content == null) {
        throw Exception('Contenu vide dans la réponse');
      }
      
      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw Exception('Réponse vide du modèle');
      }

      final textPart = parts[0]['text'];
      if (textPart == null || textPart.toString().isEmpty) {
        throw Exception('Texte vide dans la réponse');
      }

      return textPart.toString();
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        if (errorData is Map && errorData['error'] != null) {
          final error = errorData['error'];
          throw Exception('Erreur Gemini API: ${error['message'] ?? e.message}');
        }
        throw Exception('Erreur API: ${errorData.toString()}');
      }
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      if (e.toString().contains('Exception')) {
        rethrow;
      }
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }
}
