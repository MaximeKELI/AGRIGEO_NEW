import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../providers/analyse_sol_provider.dart';
import '../providers/meteo_provider.dart';
import '../../data/models/exploitation_model.dart';
import '../../data/models/chat_message_model.dart';

class ChatScreen extends StatefulWidget {
  final ExploitationModel? exploitation;

  const ChatScreen({
    super.key,
    this.exploitation,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).addWelcomeMessage();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    // Préparer les données de contexte
    Map<String, dynamic>? contextData;
    if (widget.exploitation != null) {
      contextData = {
        'exploitation': {
          'nom': widget.exploitation!.nom,
          'superficie_totale': widget.exploitation!.superficieTotale,
          'type_culture_principal': widget.exploitation!.typeCulturePrincipal,
        },
      };

      // Ajouter la dernière analyse de sol si disponible
      final analyseProvider = Provider.of<AnalyseSolProvider>(context, listen: false);
      if (analyseProvider.analyses.isNotEmpty) {
        final derniereAnalyse = analyseProvider.analyses.first;
        contextData['derniere_analyse'] = {
          'ph': derniereAnalyse.ph,
          'azote_n': derniereAnalyse.azoteN,
          'phosphore_p': derniereAnalyse.phosphoreP,
          'potassium_k': derniereAnalyse.potassiumK,
        };
      }

      // Ajouter les données météo si disponibles
      final meteoProvider = Provider.of<MeteoProvider>(context, listen: false);
      if (meteoProvider.meteoActuelle != null) {
        final meteo = meteoProvider.meteoActuelle!;
        contextData['meteo'] = {
          'temperature': meteo.temperature,
          'pluviometrie': meteo.pluviometrie,
          'humidite': meteo.humidite,
        };
      }
    }

    await Provider.of<ChatProvider>(context, listen: false).sendMessage(
      message,
      contextData: contextData,
    );

    // Scroll vers le bas
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.agriculture, color: Colors.green),
            SizedBox(width: 8),
            Text('Assistant Agricole'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showApiKeyDialog(context);
            },
            tooltip: 'Configurer la clé API',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false).clearChat();
            },
            tooltip: 'Effacer la conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          // Liste des messages
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                // Afficher les erreurs
                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: Colors.red),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            provider.clearError();
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (provider.messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Commencez une conversation',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          // Zone de saisie
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Posez votre question sur l\'agriculture...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Consumer<ChatProvider>(
                      builder: (context, provider, _) {
                        return IconButton(
                          icon: provider.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.send),
                          onPressed: provider.isLoading ? null : _sendMessage,
                          color: Colors.green,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message) {
    final isUser = message.role == MessageRole.user;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: alignment,
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.green,
                child: const Icon(Icons.agriculture, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isUser ? Colors.green : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.isLoading)
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('En train de réfléchir...'),
                        ],
                      )
                    else
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm').format(message.timestamp),
                      style: TextStyle(
                        color: isUser
                            ? Colors.white70
                            : Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 18, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context) {
    final apiKeyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurer la clé API Gemini'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Entrez votre clé API Gemini pour activer le chatbot.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                labelText: 'Clé API',
                hintText: 'AIzaSy...',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'Obtenez votre clé API sur: https://aistudio.google.com/app/apikey',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (apiKeyController.text.trim().isNotEmpty) {
                Provider.of<ChatProvider>(context, listen: false)
                    .setApiKey(apiKeyController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Clé API configurée avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}

