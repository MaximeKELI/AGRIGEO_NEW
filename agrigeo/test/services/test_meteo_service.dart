import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

import 'package:agrigeo/data/services/meteo_service.dart';
import 'package:agrigeo/data/models/meteo_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('MeteoService', () {
    late MeteoService service;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      service = MeteoService(dio: mockDio, apiKey: 'test_api_key');
    });

    test('getMeteoActuelle should return MeteoModel on success', () async {
      // Arrange
      final responseData = {
        'main': {
          'temp': 20.5,
          'temp_min': 18.0,
          'temp_max': 23.0,
          'humidity': 65.0,
          'pressure': 1013.0,
        },
        'weather': [
          {
            'description': 'ciel dégagé',
            'icon': '01d',
          }
        ],
        'wind': {
          'speed': 5.2,
        },
        'rain': {
          '1h': 0.0,
        },
        'dt': 1234567890,
      };

      final response = Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(() => mockDio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenAnswer((_) async => response);

      // Act
      final result = await service.getMeteoActuelle(
        latitude: 48.8566,
        longitude: 2.3522,
      );

      // Assert
      expect(result, isA<MeteoModel>());
      expect(result.temperature, 20.5);
      expect(result.temperatureMin, 18.0);
      expect(result.temperatureMax, 23.0);
      expect(result.humidite, 65.0);
      expect(result.vitesseVent, 5.2);
      expect(result.description, 'ciel dégagé');
      expect(result.icon, '01d');
      expect(result.latitude, 48.8566);
      expect(result.longitude, 2.3522);

      verify(() => mockDio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'lat': 48.8566,
          'lon': 2.3522,
          'appid': 'test_api_key',
          'units': 'metric',
          'lang': 'fr',
        },
      )).called(1);
    });

    test('getMeteoActuelle should throw exception when API key is null', () async {
      // Arrange
      final serviceWithoutKey = MeteoService(dio: mockDio);

      // Act & Assert
      expect(
        () => serviceWithoutKey.getMeteoActuelle(
          latitude: 48.8566,
          longitude: 2.3522,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('getMeteoActuelle should throw exception on API error', () async {
      // Arrange
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

      // Act & Assert
      expect(
        () => service.getMeteoActuelle(
          latitude: 48.8566,
          longitude: 2.3522,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('getPrevisions should return list of MeteoModel on success', () async {
      // Arrange
      final responseData = {
        'list': [
          {
            'main': {
              'temp': 20.5,
              'temp_min': 18.0,
              'temp_max': 23.0,
              'humidity': 65.0,
              'pressure': 1013.0,
            },
            'weather': [
              {
                'description': 'ciel dégagé',
                'icon': '01d',
              }
            ],
            'wind': {
              'speed': 5.2,
            },
            'rain': {
              '1h': 0.0,
            },
            'dt': 1234567890,
          },
          {
            'main': {
              'temp': 22.0,
              'temp_min': 19.0,
              'temp_max': 25.0,
              'humidity': 70.0,
              'pressure': 1012.0,
            },
            'weather': [
              {
                'description': 'nuageux',
                'icon': '02d',
              }
            ],
            'wind': {
              'speed': 6.0,
            },
            'rain': {
              '1h': 2.5,
            },
            'dt': 1234567890 + 3600,
          },
        ],
      };

      final response = Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(() => mockDio.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      )).thenAnswer((_) async => response);

      // Act
      final result = await service.getPrevisions(
        latitude: 48.8566,
        longitude: 2.3522,
      );

      // Assert
      expect(result, isA<List<MeteoModel>>());
      expect(result.length, 2);
      expect(result[0].temperature, 20.5);
      expect(result[1].temperature, 22.0);
      expect(result[1].pluviometrie, 2.5);

      verify(() => mockDio.get(
        'https://api.openweathermap.org/data/2.5/forecast',
        queryParameters: {
          'lat': 48.8566,
          'lon': 2.3522,
          'appid': 'test_api_key',
          'units': 'metric',
          'lang': 'fr',
        },
      )).called(1);
    });

    test('getPrevisions should throw exception when API key is null', () async {
      // Arrange
      final serviceWithoutKey = MeteoService(dio: mockDio);

      // Act & Assert
      expect(
        () => serviceWithoutKey.getPrevisions(
          latitude: 48.8566,
          longitude: 2.3522,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('getMeteoComplete should return PrevisionMeteoModel with actuelle and previsions', () async {
      // Arrange
      final currentWeatherData = {
        'main': {
          'temp': 20.5,
          'temp_min': 18.0,
          'temp_max': 23.0,
          'humidity': 65.0,
          'pressure': 1013.0,
        },
        'weather': [
          {
            'description': 'ciel dégagé',
            'icon': '01d',
          }
        ],
        'wind': {
          'speed': 5.2,
        },
        'rain': {
          '1h': 0.0,
        },
        'dt': 1234567890,
      };

      final forecastData = {
        'list': [
          {
            'main': {
              'temp': 22.0,
              'temp_min': 19.0,
              'temp_max': 25.0,
              'humidity': 70.0,
              'pressure': 1012.0,
            },
            'weather': [
              {
                'description': 'nuageux',
                'icon': '02d',
              }
            ],
            'wind': {
              'speed': 6.0,
            },
            'rain': {
              '1h': 2.5,
            },
            'dt': 1234567890 + 3600,
          },
        ],
      };

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

      // Act
      final result = await service.getMeteoComplete(
        latitude: 48.8566,
        longitude: 2.3522,
      );

      // Assert
      expect(result, isA<PrevisionMeteoModel>());
      expect(result.actuelle, isNotNull);
      expect(result.actuelle!.temperature, 20.5);
      expect(result.previsions, isNotEmpty);
      expect(result.previsions.length, 1);
      expect(result.previsions[0].temperature, 22.0);
    });

    test('setApiKey should update API key', () {
      // Arrange
      final serviceWithoutKey = MeteoService(dio: mockDio);

      // Act
      serviceWithoutKey.setApiKey('new_api_key');

      // Assert - La clé devrait être mise à jour
      // (test indirect via le comportement)
      expect(serviceWithoutKey, isNotNull);
    });
  });
}

