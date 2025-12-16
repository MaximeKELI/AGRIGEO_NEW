import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import 'package:agrigeo/data/repositories/auth_repository.dart';
import 'package:agrigeo/data/datasources/api_service.dart';
import 'package:agrigeo/data/models/user_model.dart';

import 'test_auth_repository.mocks.dart';

@GenerateMocks([ApiService, FlutterSecureStorage])
void main() {
  group('AuthRepository', () {
    late AuthRepository repository;
    late MockApiService mockApiService;
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      mockApiService = MockApiService();
      mockStorage = MockFlutterSecureStorage();
      repository = AuthRepository(
        apiService: mockApiService,
        storage: mockStorage,
      );
    });

    test('login should return UserModel on success', () async {
      // Arrange
      final response = Response(
        data: {
          'access_token': 'test_token',
          'user': {
            'id': 1,
            'username': 'testuser',
            'email': 'test@example.com',
            'role_id': 1,
            'is_active': true,
          }
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(() => mockApiService.login('testuser', 'password123'))
          .thenAnswer((_) async => response);
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.login('testuser', 'password123');

      // Assert
      expect(result, isA<UserModel>());
      expect(result.username, 'testuser');
      verify(() => mockApiService.login('testuser', 'password123')).called(1);
      verify(() => mockStorage.write(key: 'auth_token', value: 'test_token')).called(1);
    });

    test('login should throw Failure on error', () async {
      // Arrange
      when(() => mockApiService.login('testuser', 'wrongpassword'))
          .thenThrow(ServerFailure('Identifiants invalides'));

      // Act & Assert
      expect(
        () => repository.login('testuser', 'wrongpassword'),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('register should return UserModel on success', () async {
      // Arrange
      final response = Response(
        data: {
          'user': {
            'id': 1,
            'username': 'newuser',
            'email': 'new@example.com',
            'role_id': 1,
            'is_active': true,
          }
        },
        statusCode: 201,
        requestOptions: RequestOptions(path: ''),
      );

      final data = {
        'username': 'newuser',
        'email': 'new@example.com',
        'password': 'password123',
        'role_id': 1,
      };

      when(() => mockApiService.register(data))
          .thenAnswer((_) async => response);

      // Act
      final result = await repository.register(data);

      // Assert
      expect(result, isA<UserModel>());
      expect(result.username, 'newuser');
      verify(() => mockApiService.register(data)).called(1);
    });

    test('getCurrentUser should return UserModel when logged in', () async {
      // Arrange
      final response = Response(
        data: {
          'id': 1,
          'username': 'testuser',
          'email': 'test@example.com',
          'role_id': 1,
          'is_active': true,
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(() => mockApiService.getCurrentUser())
          .thenAnswer((_) async => response);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result, isNotNull);
      expect(result?.username, 'testuser');
    });

    test('getCurrentUser should return null on error', () async {
      // Arrange
      when(() => mockApiService.getCurrentUser())
          .thenThrow(ServerFailure('Erreur'));

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result, isNull);
    });

    test('logout should clear storage', () async {
      // Arrange
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async => {});

      // Act
      await repository.logout();

      // Assert
      verify(() => mockStorage.delete(key: 'auth_token')).called(1);
      verify(() => mockStorage.delete(key: 'user_data')).called(1);
    });

    test('isLoggedIn should return true when token exists', () async {
      // Arrange
      when(() => mockStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => 'test_token');

      // Act
      final result = await repository.isLoggedIn();

      // Assert
      expect(result, true);
    });

    test('isLoggedIn should return false when no token', () async {
      // Arrange
      when(mockStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.isLoggedIn();

      // Assert
      expect(result, false);
    });
  });
}

