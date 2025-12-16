# Tests Unitaires Backend - AGRIGEO

## Structure des Tests

```
tests/
├── __init__.py
├── test_models.py
├── test_validators.py
├── test_recommandation_service.py
├── test_irrigation_service.py
└── test_routes.py
```

## Exécution des Tests

### Avec unittest (Python standard)
```bash
cd backend
python -m pytest tests/ -v
```

### Tests spécifiques
```bash
python -m pytest tests/test_models.py -v
python -m pytest tests/test_validators.py -v
python -m pytest tests/test_routes.py -v
```

### Avec couverture
```bash
pip install pytest-cov
pytest tests/ --cov=. --cov-report=html
```

## Tests Implémentés

### Modèles (`test_models.py`)
- ✅ Test création de Role
- ✅ Test création de User avec hashage password
- ✅ Test création d'Exploitation
- ✅ Test création de Parcelle
- ✅ Test création d'AnalyseSol
- ✅ Test création d'Intrant

### Validateurs (`test_validators.py`)
- ✅ Validation utilisateur (champs requis, format email, longueur password)
- ✅ Validation exploitation (superficie, coordonnées GPS)
- ✅ Validation analyse de sol (pH, humidité, nutriments)
- ✅ Validation intrant (champs requis, quantité positive)

### Service de Recommandations (`test_recommandation_service.py`)
- ✅ Recommandations pour sol acide
- ✅ Recommandations pour carence en azote
- ✅ Recommandations pour faible pluviométrie
- ✅ Gestion du cas sans données
- ✅ Vérification des paramètres utilisés

### Service d'Irrigation (`test_irrigation_service.py`)
- ✅ Conseils avec déficit hydrique élevé
- ✅ Conseils avec pluviométrie suffisante
- ✅ Conseils avec température élevée
- ✅ Conseils avec humidité faible
- ✅ Vérification des paramètres utilisés
- ✅ Différences selon le type de culture

### Routes API (`test_routes.py`)
- ✅ Health check
- ✅ Register user
- ✅ Login (success et failure)
- ✅ Get current user
- ✅ Create exploitation
- ✅ Validation des données
- ✅ Get exploitations avec pagination

## Configuration

### Dépendances de Test

Les tests nécessitent :
- `pytest` (recommandé) ou `unittest` (standard)
- `pytest-cov` (pour la couverture, optionnel)

Installation :
```bash
pip install pytest pytest-cov
```

### Base de Données de Test

Les tests utilisent une base de données en mémoire (`sqlite:///:memory:`) pour l'isolation complète.

## Notes

- Chaque test est isolé avec `setUp` et `tearDown`
- Les tests utilisent des données de test réalistes
- Les tests vérifient les cas de succès et d'échec
- Les tests de routes nécessitent l'authentification JWT

## Exemples d'Exécution

```bash
# Tous les tests
pytest tests/ -v

# Tests avec couverture
pytest tests/ --cov=. --cov-report=term-missing

# Tests spécifiques avec détails
pytest tests/test_models.py::TestModels::test_user_creation -v

# Tests avec sortie détaillée
pytest tests/ -v -s
```

