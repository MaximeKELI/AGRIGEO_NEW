# Tests Unitaires Flutter - AGRIGEO

## Structure des Tests

```
test/
├── repositories/
│   └── test_auth_repository.dart
├── providers/
│   ├── test_auth_provider.dart
│   └── test_exploitation_provider.dart
├── services/
│   └── test_gemini_service.dart
└── widgets/
    └── test_login_screen.dart
```

## Exécution des Tests

### Tous les tests
```bash
flutter test
```

### Tests spécifiques
```bash
flutter test test/providers/test_auth_provider.dart
```

### Avec couverture
```bash
flutter test --coverage
```

## Génération des Mocks

Les tests utilisent `mockito` pour générer les mocks. Après avoir ajouté de nouveaux tests avec `@GenerateMocks`, exécutez :

```bash
flutter pub run build_runner build
```

## Tests Implémentés

### Repositories
- ✅ `test_auth_repository.dart` - Tests pour AuthRepository
  - Login success/failure
  - Register
  - GetCurrentUser
  - Logout
  - IsLoggedIn

### Providers
- ✅ `test_auth_provider.dart` - Tests pour AuthProvider
  - État initial
  - Login success/failure
  - Register
  - Logout
  - Gestion du loading

- ✅ `test_exploitation_provider.dart` - Tests pour ExploitationProvider
  - Load exploitations
  - Create exploitation
  - Update exploitation
  - Delete exploitation

### Services
- ✅ `test_gemini_service.dart` - Tests pour GeminiService
  - SendMessage success
  - Gestion des erreurs
  - Historique de conversation
  - Contexte des données

### Widgets
- ✅ `test_login_screen.dart` - Tests pour LoginScreen
  - Affichage du formulaire
  - Validation des champs
  - Toggle password visibility
  - Loading state

## Dépendances de Test

Les tests nécessitent :
- `flutter_test` (inclus dans Flutter SDK)
- `mockito` (pour les mocks)
- `build_runner` (pour générer les mocks)

## Notes

- Les tests utilisent des mocks pour isoler les dépendances
- Les tests de widgets nécessitent un environnement Flutter
- Les tests de providers testent la logique métier
- Les tests de repositories testent l'intégration avec les services

