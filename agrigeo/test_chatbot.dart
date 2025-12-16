#!/usr/bin/env dart
/// Script de test pour vérifier que le chatbot Gemini fonctionne
import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  print('🤖 Test du Chatbot AGRIGEO - API Gemini\n');
  print('=' * 50);
  
  // Clé API depuis home_screen.dart
  const apiKey = 'AIzaSyCwt5NygybBr9oasALOG7Ht-XhM2Dk-sIk';
  const baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  
  final dio = Dio();
  
  // Message de test
  const testMessage = 'Bonjour ! Peux-tu me donner un conseil rapide sur la gestion des sols agricoles ?';
  
  print('\n📤 Envoi du message de test...');
  print('Message: "$testMessage"\n');
  
  try {
    // Construire le prompt système
    const systemPrompt = '''
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

    // Préparer la requête
    final requestData = {
      'contents': [
        {
          'role': 'user',
          'parts': [{'text': testMessage}]
        }
      ],
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

    print('🔄 Appel à l\'API Gemini...');
    print('URL: $baseUrl/models/gemini-1.5-flash:generateContent\n');

    // Appel à l'API
    final response = await dio.post(
      '$baseUrl/models/gemini-1.5-flash:generateContent?key=$apiKey',
      data: requestData,
      options: Options(
        headers: {'Content-Type': 'application/json'},
        validateStatus: (status) => status! < 500,
      ),
    );

    print('📥 Réponse reçue (Status: ${response.statusCode})\n');

    // Vérifier les erreurs
    if (response.statusCode != 200) {
      if (response.data != null && response.data['error'] != null) {
        final error = response.data['error'];
        print('❌ ERREUR API:');
        print('   Message: ${error['message'] ?? 'Erreur inconnue'}');
        print('   Code: ${error['code'] ?? response.statusCode}');
        if (error['details'] != null) {
          print('   Détails: ${error['details']}');
        }
        exit(1);
      }
      print('❌ Erreur HTTP ${response.statusCode}: ${response.statusMessage}');
      print('Réponse: ${response.data}');
      exit(1);
    }

    // Extraire la réponse
    if (response.data == null) {
      print('❌ Réponse vide de l\'API');
      exit(1);
    }

    final candidates = response.data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      if (response.data['error'] != null) {
        final error = response.data['error'];
        print('❌ Erreur API: ${error['message'] ?? 'Erreur inconnue'}');
        exit(1);
      }
      print('❌ Aucune réponse du modèle');
      print('Réponse complète: ${response.data}');
      exit(1);
    }

    final content = candidates[0]['content'];
    if (content == null) {
      print('❌ Contenu vide dans la réponse');
      exit(1);
    }

    final parts = content['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      print('❌ Réponse vide du modèle');
      exit(1);
    }

    final textPart = parts[0]['text'];
    if (textPart == null || textPart.toString().isEmpty) {
      print('❌ Texte vide dans la réponse');
      exit(1);
    }

    // Afficher le succès
    print('✅ SUCCÈS ! Le chatbot fonctionne correctement.\n');
    print('=' * 50);
    print('\n📨 Réponse du chatbot:\n');
    print('─' * 50);
    print(textPart.toString());
    print('─' * 50);
    print('\n✅ Test réussi ! Le chatbot est opérationnel.\n');

  } on DioException catch (e) {
    print('\n❌ ERREUR DE CONNEXION:');
    if (e.response != null) {
      final errorData = e.response!.data;
      if (errorData is Map && errorData['error'] != null) {
        final error = errorData['error'];
        print('   Message: ${error['message'] ?? e.message}');
        print('   Code: ${error['code'] ?? e.response!.statusCode}');
      } else {
        print('   ${errorData.toString()}');
      }
    } else {
      print('   ${e.message}');
      print('   Type: ${e.type}');
    }
    exit(1);
  } catch (e) {
    print('\n❌ ERREUR INATTENDUE:');
    print('   ${e.toString()}');
    exit(1);
  }
}

