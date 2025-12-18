import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

import 'package:agrigeo/data/services/meteo_service.dart';
import 'package:agrigeo/data/repositories/meteo_repository.dart';
import 'package:agrigeo/presentation/providers/meteo_provider.dart';
import 'package:agrigeo/data/models/meteo_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('Test d\'intégration météo - Chaîne complète', () {
    late MockDio mockDio;
    late MeteoService meteoService;
    late MeteoRepository meteoRepository;
    late MeteoProvider meteoProvider;

    setUp(() {
      mockDio = MockDio();
      meteoService = MeteoService(dio: mockDio, apiKey: 'test_api_key');
      meteoRepository = MeteoRepository(meteoService: meteoService);
      meteoProvider = MeteoProvider(repository: meteoRepository);
    });

    test('Test complet: Service -> Repository -> Provider', () async {
      // Arrange - Données météo complètes
      final currentWeatherData = {
        'main': {
          'temp': 22.5,
          'temp_min': 18.0,
          'temp_max': 26.0,
          'humidity': 70.0,
          'pressure': 1015.0,
        },
        'weather': [
          {
            'description': 'partiellement nuageux',
            'icon': '02d',
          }
        ],
        'wind': {
          'speed': 4.5,
          'deg': 180,
        },
        'rain': {
          '1h': 0.0,
        },
        'dt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      final forecastData = {
        'list': [
          {
            'main': {
              'temp': 23.0,
              'temp_min': 19.0,
              'temp_max': 27.0,
              'humidity': 65.0,
              'pressure': 1014.0,
            },
            'weather': [
              {
                'description': 'ensoleillé',
                'icon': '01d',
              }
            ],
            'wind': {
              'speed': 5.0,
            },
            'rain': {
              '1h': 0.0,
            },
            'dt': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600,
          },
          {
            'main': {
              'temp': 21.0,
              'temp_min': 17.0,
              'temp_max': 24.0,
              'humidity': 75.0,
              'pressure': 1013.0,
            },
            'weather': [
              {
                'description': 'pluie légère',
                'icon': '10d',
              }
            ],
            'wind': {
              'speed': 6.5,
            },
            'rain': {
              '1h': 2.5,
            },
            'dt': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 7200,
          },
        ],
      };

      // Mock des réponses API
      when(() => mockDio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: any(named: 'queryParameters'),
      )).thenAnswer((_) async => Response(
        data: currentWeatherData,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      when(() => mockDio.get(
        'https://api.openweathermap.org/data/2.5/forecast',
        queryParameters: any(named: 'queryParameters'),
      )).thenAnswer((_) async => Response(
        data: forecastData,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      // Act - Test de la chaîne complète
      const latitude = 48.8566; // Paris
      const longitude = 2.3522;

      // 1. Configuration de la clé API
      meteoProvider.setApiKey('test_api_key');
      expect(meteoProvider.error, isNull);

      // 2. Chargement de la météo actuelle via le provider
      await meteoProvider.loadMeteoActuelle(
        latitude: latitude,
        longitude: longitude,
      );

      // Assert - Vérification de la météo actuelle
      expect(meteoProvider.isLoading, false);
      expect(meteoProvider.error, isNull);
      expect(meteoProvider.meteoActuelle, isNotNull);
      expect(meteoProvider.meteoActuelle!.temperature, 22.5);
      expect(meteoProvider.meteoActuelle!.temperatureMin, 18.0);
      expect(meteoProvider.meteoActuelle!.temperatureMax, 26.0);
      expect(meteoProvider.meteoActuelle!.humidite, 70.0);
      expect(meteoProvider.meteoActuelle!.vitesseVent, 4.5);
      expect(meteoProvider.meteoActuelle!.description, 'partiellement nuageux');
      expect(meteoProvider.meteoActuelle!.icon, '02d');
      expect(meteoProvider.meteoActuelle!.latitude, latitude);
      expect(meteoProvider.meteoActuelle!.longitude, longitude);

      // 3. Chargement des prévisions
      await meteoProvider.loadPrevisions(
        latitude: latitude,
        longitude: longitude,
      );

      // Assert - Vérification des prévisions
      expect(meteoProvider.isLoading, false);
      expect(meteoProvider.error, isNull);
      expect(meteoProvider.previsions, isNotEmpty);
      expect(meteoProvider.previsions.length, 2);
      expect(meteoProvider.previsions[0].temperature, 23.0);
      expect(meteoProvider.previsions[1].temperature, 21.0);
      expect(meteoProvider.previsions[1].pluviometrie, 2.5);
      expect(meteoProvider.previsions[1].description, 'pluie légère');

      // 4. Test de loadMeteoComplete (actuelle + prévisions)
      await meteoProvider.loadMeteoComplete(
        latitude: latitude,
        longitude: longitude,
      );

      // Assert - Vérification de la météo complète
      expect(meteoProvider.isLoading, false);
      expect(meteoProvider.error, isNull);
      expect(meteoProvider.meteoActuelle, isNotNull);
      expect(meteoProvider.previsions, isNotEmpty);
      expect(meteoProvider.previsions.length, 2);

      print('✅ Test d\'intégration météo réussi !');
      print('   - Météo actuelle: ${meteoProvider.meteoActuelle!.temperature}°C');
      print('   - Description: ${meteoProvider.meteoActuelle!.description}');
      print('   - Humidité: ${meteoProvider.meteoActuelle!.humidite}%');
      print('   - Vent: ${meteoProvider.meteoActuelle!.vitesseVent} m/s');
      print('   - Prévisions: ${meteoProvider.previsions.length} périodes');
    });

    test('Test gestion d\'erreur dans la chaîne complète', () async {
      // Arrange - Simuler une erreur API
      when(() => mockDio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          data: {'message': 'Invalid API key'},
          statusCode: 401,
          requestOptions: RequestOptions(path: ''),
        ),
      ));

      // Act
      await meteoProvider.loadMeteoActuelle(
        latitude: 48.8566,
        longitude: 2.3522,
      );

      // Assert
      expect(meteoProvider.isLoading, false);
      expect(meteoProvider.error, isNotNull);
      expect(meteoProvider.error, contains('Erreur météo'));
      expect(meteoProvider.meteoActuelle, isNull);

      print('✅ Test de gestion d\'erreur réussi !');
      print('   - Erreur capturée: ${meteoProvider.error}');
    });

    test('Test avec clé API manquante', () async {
      // Arrange - Provider sans clé API
      final providerSansCle = MeteoProvider(
        repository: MeteoRepository(
          meteoService: MeteoService(dio: mockDio),
        ),
      );

      // Act
      await providerSansCle.loadMeteoActuelle(
        latitude: 48.8566,
        longitude: 2.3522,
      );

      // Assert - L'erreur devrait être capturée
      expect(providerSansCle.isLoading, false);
      expect(providerSansCle.error, isNotNull);
      expect(providerSansCle.error, contains('Clé API'));
      expect(providerSansCle.meteoActuelle, isNull);

      print('✅ Test clé API manquante réussi !');
      print('   - Erreur: ${providerSansCle.error}');
    });

    test('Test des états de chargement', () async {
      // Arrange
      final responseData = {
        'main': {
          'temp': 20.0,
          'temp_min': 18.0,
          'temp_max': 22.0,
          'humidity': 60.0,
          'pressure': 1013.0,
        },
        'weather': [
          {
            'description': 'ciel dégagé',
            'icon': '01d',
          }
        ],
        'wind': {
          'speed': 3.0,
        },
        'rain': {
          '1h': 0.0,
        },
        'dt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      when(() => mockDio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenAnswer((_) async {
        // Simuler un délai
        await Future.delayed(const Duration(milliseconds: 100));
        return Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );
      });

      // Act
      final future = meteoProvider.loadMeteoActuelle(
        latitude: 48.8566,
        longitude: 2.3522,
      );

      // Vérifier que isLoading est true pendant le chargement
      expect(meteoProvider.isLoading, true);

      await future;

      // Vérifier que isLoading est false après le chargement
      expect(meteoProvider.isLoading, false);
      expect(meteoProvider.meteoActuelle, isNotNull);

      print('✅ Test des états de chargement réussi !');
      print('   - État initial: isLoading = true');
      print('   - État final: isLoading = false');
    });
  });
}

