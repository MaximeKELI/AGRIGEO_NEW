# Guide des Tests - AGRIGEO

## 📋 Vue d'ensemble

Des tests unitaires complets ont été créés pour le frontend (Flutter) et le backend (Flask).

## 🔧 Backend (Python/Flask)

### Structure
```
backend/tests/
├── __init__.py
├── test_models.py          # Tests des modèles SQLAlchemy
├── test_validators.py     # Tests des validateurs
├── test_recommandation_service.py  # Tests du service de recommandations
├── test_irrigation_service.py      # Tests du service d'irrigation
└── test_routes.py         # Tests des routes API
```

### Exécution

```bash
cd backend
pip install -r requirements.txt
pytest tests/ -v
```

### Tests Disponibles

1. **test_models.py** (6 tests)
   - Création de rôles
   - Création d'utilisateurs avec hashage password
   - Création d'exploitations
   - Création de parcelles
   - Création d'analyses de sol
   - Création d'intrants

2. **test_validators.py** (10 tests)
   - Validation utilisateur (champs, email, password)
   - Validation exploitation (superficie, coordonnées)
   - Validation analyse de sol (pH, humidité, nutriments)
   - Validation intrant (champs, quantité)

3. **test_recommandation_service.py** (5 tests)
   - Recommandations sol acide
   - Recommandations carence azote
   - Recommandations faible pluviométrie
   - Gestion cas sans données
   - Vérification paramètres utilisés

4. **test_irrigation_service.py** (6 tests)
   - Conseils déficit hydrique élevé
   - Conseils pluviométrie suffisante
   - Conseils température élevée
   - Conseils humidité faible
   - Vérification paramètres
   - Différences selon culture

5. **test_routes.py** (8 tests)
   - Health check
   - Register/Login
   - Get current user
   - CRUD exploitations
   - Validation données

**Total : ~35 tests backend**

## 📱 Frontend (Flutter/Dart)

### Structure
```
agrigeo/test/
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

### Exécution

```bash
cd agrigeo
flutter pub get
flutter pub run build_runner build  # Générer les mocks
flutter test
```

### Tests Disponibles

1. **test_auth_repository.dart** (7 tests)
   - Login success/failure
   - Register
   - GetCurrentUser
   - Logout
   - IsLoggedIn

2. **test_auth_provider.dart** (7 tests)
   - État initial
   - Login avec gestion loading
   - Register
   - Logout
   - Gestion erreurs

3. **test_exploitation_provider.dart** (5 tests)
   - Load exploitations
   - Create exploitation
   - Update exploitation
   - Delete exploitation
   - Gestion erreurs

4. **test_gemini_service.dart** (5 tests)
   - SendMessage success
   - Gestion erreurs API
   - Historique conversation
   - Contexte données
   - SetApiKey

5. **test_login_screen.dart** (4 tests)
   - Affichage formulaire
   - Validation champs
   - Toggle password visibility
   - Loading state

**Total : ~28 tests frontend**

## 🎯 Couverture des Tests

### Backend
- ✅ Modèles de données
- ✅ Validation des données
- ✅ Services métier (recommandations, irrigation)
- ✅ Routes API (authentification, CRUD)

### Frontend
- ✅ Repositories (couche données)
- ✅ Providers (gestion d'état)
- ✅ Services (API externes)
- ✅ Widgets (interface utilisateur)

## 📊 Métriques

- **Backend** : ~35 tests unitaires
- **Frontend** : ~28 tests unitaires
- **Total** : ~63 tests unitaires

## 🚀 Commandes Rapides

### Backend
```bash
# Tous les tests
pytest tests/ -v

# Avec couverture
pytest tests/ --cov=. --cov-report=html

# Test spécifique
pytest tests/test_models.py::TestModels::test_user_creation -v
```

### Frontend
```bash
# Tous les tests
flutter test

# Test spécifique
flutter test test/providers/test_auth_provider.dart

# Avec couverture
flutter test --coverage
```

## 📝 Notes Importantes

1. **Mocks** : Les tests Flutter utilisent `mockito` - générer les mocks avec `build_runner`
2. **Isolation** : Chaque test est isolé avec setUp/tearDown
3. **Base de données** : Les tests backend utilisent une DB en mémoire
4. **Authentification** : Les tests de routes nécessitent des tokens JWT valides

## 🔄 Intégration Continue

Ces tests peuvent être intégrés dans un pipeline CI/CD :
- GitHub Actions
- GitLab CI
- Jenkins
- etc.

---

**Les tests sont prêts à être exécutés !** ✅




