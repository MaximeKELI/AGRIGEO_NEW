import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/chat_message_model.dart';

/// Service pour communiquer avec l'API Gemini
class GeminiService {
  final Dio _dio;
  String? _apiKey;
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  GeminiService({Dio? dio, String? apiKey})
      : _dio = dio ?? Dio(),
        _apiKey = apiKey ?? 'AIzaSyCwt5NygybBr9oasALOG7Ht-XhM2Dk-sIk';

  /// Configure la clé API
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  /// Système prompt pour limiter le chatbot à l'agriculture
  String get _systemPrompt => '''
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

  /// Envoie un message au chatbot Gemini
  Future<String> sendMessage(
    String userMessage, {
    List<ChatMessageModel>? conversationHistory,
    Map<String, dynamic>? contextData,
  }) async {
    if (_apiKey == null) {
      throw Exception('Clé API Gemini non configurée');
    }

    try {
      // Construire le contexte avec les données de l'application
      String contextPrompt = _systemPrompt;
      
      if (contextData != null) {
        contextPrompt += '\n\nContexte de l\'application AGRIGEO:\n';
        
        if (contextData['exploitation'] != null) {
          final exp = contextData['exploitation'];
          contextPrompt += '- Exploitation: ${exp['nom'] ?? 'N/A'}, Superficie: ${exp['superficie_totale'] ?? 'N/A'} ha\n';
          if (exp['type_culture_principal'] != null) {
            contextPrompt += '- Type de culture: ${exp['type_culture_principal']}\n';
          }
        }
        
        if (contextData['derniere_analyse'] != null) {
          final analyse = contextData['derniere_analyse'];
          contextPrompt += '\nDernière analyse de sol:\n';
          if (analyse['ph'] != null) contextPrompt += '- pH: ${analyse['ph']}\n';
          if (analyse['azote_n'] != null) contextPrompt += '- Azote (N): ${analyse['azote_n']} mg/kg\n';
          if (analyse['phosphore_p'] != null) contextPrompt += '- Phosphore (P): ${analyse['phosphore_p']} mg/kg\n';
          if (analyse['potassium_k'] != null) contextPrompt += '- Potassium (K): ${analyse['potassium_k']} mg/kg\n';
        }
        
        if (contextData['meteo'] != null) {
          final meteo = contextData['meteo'];
          contextPrompt += '\nMétéo actuelle:\n';
          if (meteo['temperature'] != null) contextPrompt += '- Température: ${meteo['temperature']}°C\n';
          if (meteo['pluviometrie'] != null) contextPrompt += '- Pluviométrie: ${meteo['pluviometrie']} mm\n';
          if (meteo['humidite'] != null) contextPrompt += '- Humidité: ${meteo['humidite']}%\n';
        }
      }

      // Construire l'historique de conversation
      final List<Map<String, dynamic>> contents = [];
      
      // Ajouter le contexte système comme premier message
      contents.add({
        'role': 'user',
        'parts': [{'text': contextPrompt}]
      });
      contents.add({
        'role': 'model',
        'parts': [{'text': 'Bonjour ! Je suis votre assistant agricole AGRIGEO. Je suis là pour vous aider avec toutes vos questions sur l\'agriculture, la gestion des sols, l\'irrigation et les pratiques agricoles. Comment puis-je vous aider aujourd\'hui ?'}]
      });

      // Ajouter l'historique de conversation
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        for (final msg in conversationHistory) {
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

      // Appel à l'API Gemini
      final response = await _dio.post(
        '$_baseUrl/models/gemini-pro:generateContent?key=$_apiKey',
        data: {
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
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

      return parts[0]['text'] as String;
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception('Erreur Gemini API: ${errorData['error']?['message'] ?? e.message}');
      }
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }
}

