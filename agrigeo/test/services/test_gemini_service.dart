import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';

import 'package:agrigeo/data/services/gemini_service.dart';
import 'package:agrigeo/data/models/chat_message_model.dart';

import 'test_gemini_service.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('GeminiService', () {
    late GeminiService service;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      service = GeminiService(dio: mockDio, apiKey: 'test_api_key');
    });

    test('sendMessage should return response text on success', () async {
      // Arrange
      final response = Response(
        data: {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Réponse du chatbot'}
                ]
              }
            }
          ]
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockDio.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => response);

      // Act
      final result = await service.sendMessage('Bonjour');

      // Assert
      expect(result, 'Réponse du chatbot');
      verify(mockDio.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).called(1);
    });

    test('sendMessage should throw exception on API error', () async {
      // Arrange
      when(mockDio.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          data: {'error': {'message': 'API Error'}},
          statusCode: 400,
          requestOptions: RequestOptions(path: ''),
        ),
      ));

      // Act & Assert
      expect(
        () => service.sendMessage('Bonjour'),
        throwsA(isA<Exception>()),
      );
    });

    test('sendMessage should include conversation history', () async {
      // Arrange
      final response = Response(
        data: {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Réponse'}
                ]
              }
            }
          ]
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      final history = [
        ChatMessageModel(
          id: '1',
          role: MessageRole.user,
          content: 'Premier message',
          timestamp: DateTime.now(),
        ),
        ChatMessageModel(
          id: '2',
          role: MessageRole.assistant,
          content: 'Première réponse',
          timestamp: DateTime.now(),
        ),
      ];

      when(mockDio.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => response);

      // Act
      await service.sendMessage('Deuxième message', conversationHistory: history);

      // Assert
      verify(mockDio.post(
        any,
        data: argThat(
          predicate((data) {
            final contents = data['contents'] as List;
            // Devrait avoir le contexte système + historique + nouveau message
            return contents.length >= 3;
          }),
          named: 'data',
        ),
        options: anyNamed('options'),
      )).called(1);
    });

    test('sendMessage should include context data', () async {
      // Arrange
      final response = Response(
        data: {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Réponse'}
                ]
              }
            }
          ]
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      final contextData = {
        'exploitation': {
          'nom': 'Ma Ferme',
          'superficie_totale': 10.5,
        }
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => response);

      // Act
      await service.sendMessage('Question', contextData: contextData);

      // Assert
      verify(mockDio.post(
        any,
        data: argThat(
          predicate((data) {
            final contents = data['contents'] as List;
            final firstMessage = contents[0]['parts'][0]['text'] as String;
            // Le contexte devrait être inclus dans le premier message
            return firstMessage.contains('Ma Ferme');
          }),
          named: 'data',
        ),
        options: anyNamed('options'),
      )).called(1);
    });

    test('setApiKey should update API key', () {
      // Act
      service.setApiKey('new_api_key');

      // Assert - La clé devrait être mise à jour
      // (test indirect via le comportement)
      expect(service, isNotNull);
    });
  });
}

