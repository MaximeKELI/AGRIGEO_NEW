import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/repositories/chat_repository.dart';
import 'dart:math';

class ChatProvider with ChangeNotifier {
  final ChatRepository _repository;
  final List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider({ChatRepository? repository})
      : _repository = repository ?? ChatRepository();

  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Configure la clé API
  void setApiKey(String apiKey) {
    _repository.setApiKey(apiKey);
  }

  /// Envoie un message au chatbot
  Future<void> sendMessage(
    String message, {
    Map<String, dynamic>? contextData,
  }) async {
    if (message.trim().isEmpty) return;

    // Ajouter le message de l'utilisateur
    final userMessage = ChatMessageModel(
      id: _generateId(),
      role: MessageRole.user,
      content: message.trim(),
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    notifyListeners();

    // Ajouter un message de chargement
    final loadingMessage = ChatMessageModel(
      id: _generateId(),
      role: MessageRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      isLoading: true,
    );
    _messages.add(loadingMessage);
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Récupérer l'historique (sans le message de chargement)
      final history = _messages
          .where((m) => m.id != loadingMessage.id)
          .toList();

      // Envoyer au repository
      final response = await _repository.sendMessage(
        message,
        conversationHistory: history,
        contextData: contextData,
      );

      // Remplacer le message de chargement par la réponse
      final index = _messages.indexWhere((m) => m.id == loadingMessage.id);
      if (index != -1) {
        _messages[index] = ChatMessageModel(
          id: loadingMessage.id,
          role: MessageRole.assistant,
          content: response,
          timestamp: DateTime.now(),
          isLoading: false,
        );
      }

      _isLoading = false;
      notifyListeners();
    } on Failure catch (e) {
      // Remplacer le message de chargement par l'erreur
      final index = _messages.indexWhere((m) => m.id == loadingMessage.id);
      if (index != -1) {
        _messages.removeAt(index);
      }
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      final index = _messages.indexWhere((m) => m.id == loadingMessage.id);
      if (index != -1) {
        _messages.removeAt(index);
      }
      _error = 'Erreur inattendue: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Efface l'historique de conversation
  void clearChat() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }

  /// Ajoute un message système (bienvenue)
  void addWelcomeMessage() {
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessageModel(
          id: _generateId(),
          role: MessageRole.assistant,
          content: 'Bonjour ! Je suis votre assistant agricole AGRIGEO. '
              'Je suis spécialisé dans l\'agriculture, la gestion des sols, l\'irrigation et les pratiques agricoles. '
              'Comment puis-je vous aider aujourd\'hui ?',
          timestamp: DateTime.now(),
        ),
      );
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }
}

