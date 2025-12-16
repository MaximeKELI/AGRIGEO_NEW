import '../../core/errors/failures.dart';
import '../models/chat_message_model.dart';
import '../services/gemini_service.dart';

class ChatRepository {
  final GeminiService _geminiService;

  ChatRepository({GeminiService? geminiService})
      : _geminiService = geminiService ?? GeminiService();

  /// Configure la clé API
  void setApiKey(String apiKey) {
    _geminiService.setApiKey(apiKey);
  }

  /// Envoie un message et récupère la réponse
  Future<String> sendMessage(
    String message, {
    List<ChatMessageModel>? conversationHistory,
    Map<String, dynamic>? contextData,
  }) async {
    try {
      return await _geminiService.sendMessage(
        message,
        conversationHistory: conversationHistory,
        contextData: contextData,
      );
    } catch (e) {
      throw ServerFailure('Erreur chatbot: ${e.toString()}');
    }
  }
}

