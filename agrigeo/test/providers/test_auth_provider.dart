import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:agrigeo/presentation/providers/auth_provider.dart';
import 'package:agrigeo/data/repositories/auth_repository.dart';
import 'package:agrigeo/data/models/user_model.dart';
import 'package:agrigeo/core/errors/failures.dart';

import 'test_auth_provider.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  group('AuthProvider', () {
    late AuthProvider provider;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      provider = AuthProvider(repository: mockRepository);
    });

    test('initial state should be not authenticated', () {
      expect(provider.isAuthenticated, false);
      expect(provider.user, isNull);
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
    });

    test('login should set user on success', () async {
      // Arrange
      final user = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        roleId: 1,
        isActive: true,
      );

      when(mockRepository.login('testuser', 'password123'))
          .thenAnswer((_) async => user);

      // Act
      final result = await provider.login('testuser', 'password123');

      // Assert
      expect(result, true);
      expect(provider.isAuthenticated, true);
      expect(provider.user, isNotNull);
      expect(provider.user?.username, 'testuser');
      expect(provider.error, isNull);
    });

    test('login should set error on failure', () async {
      // Arrange
      when(mockRepository.login('testuser', 'wrongpassword'))
          .thenThrow(AuthenticationFailure('Identifiants invalides'));

      // Act
      final result = await provider.login('testuser', 'wrongpassword');

      // Assert
      expect(result, false);
      expect(provider.isAuthenticated, false);
      expect(provider.user, isNull);
      expect(provider.error, isNotNull);
      expect(provider.error, contains('invalides'));
    });

    test('login should set isLoading during request', () async {
      // Arrange
      final user = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        roleId: 1,
        isActive: true,
      );

      when(mockRepository.login('testuser', 'password123'))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return user;
      });

      // Act
      final future = provider.login('testuser', 'password123');

      // Assert - isLoading should be true during request
      expect(provider.isLoading, true);

      await future;
      expect(provider.isLoading, false);
    });

    test('register should set user on success', () async {
      // Arrange
      final user = UserModel(
        id: 1,
        username: 'newuser',
        email: 'new@example.com',
        roleId: 1,
        isActive: true,
      );

      final data = {
        'username': 'newuser',
        'email': 'new@example.com',
        'password': 'password123',
        'role_id': 1,
      };

      when(mockRepository.register(data))
          .thenAnswer((_) async => user);

      // Act
      final result = await provider.register(data);

      // Assert
      expect(result, true);
      expect(provider.user, isNotNull);
      expect(provider.user?.username, 'newuser');
    });

    test('logout should clear user', () async {
      // Arrange
      provider = AuthProvider(repository: mockRepository);
      provider.login('testuser', 'password123');

      when(mockRepository.logout())
          .thenAnswer((_) async => {});

      // Act
      await provider.logout();

      // Assert
      expect(provider.isAuthenticated, false);
      expect(provider.user, isNull);
      verify(mockRepository.logout()).called(1);
    });

    test('clearError should remove error', () {
      // Arrange
      provider.error = 'Test error';

      // Act
      provider.clearError();

      // Assert
      expect(provider.error, isNull);
    });
  });
}

