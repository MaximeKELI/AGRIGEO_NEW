# Architecture AGRIGEO

## Vue d'ensemble

AGRIGEO suit une architecture Clean Architecture avec séparation claire entre les couches Frontend (Flutter) et Backend (Flask).

## Backend (Flask)

### Structure

```
backend/
├── app.py                      # Point d'entrée Flask
├── database.py                 # Configuration SQLAlchemy
├── requirements.txt            # Dépendances Python
├── models/                     # Modèles de données (ORM)
│   ├── __init__.py
│   ├── user.py                 # User, Role
│   ├── exploitation.py        # Exploitation, Parcelle
│   ├── analyse_sol.py          # AnalyseSol
│   ├── donnee_climatique.py    # DonneeClimatique
│   ├── intrant.py              # Intrant
│   ├── recommandation.py       # Recommandation
│   └── historique_action.py    # HistoriqueAction
├── routes/                     # Endpoints API (Blueprints)
│   ├── auth.py                 # Authentification
│   ├── users.py                # Gestion utilisateurs
│   ├── exploitations.py        # CRUD exploitations
│   ├── parcelles.py            # CRUD parcelles
│   ├── analyses_sols.py        # CRUD analyses sols
│   ├── donnees_climatiques.py  # CRUD données climatiques
│   ├── intrants.py             # CRUD intrants
│   └── recommandations.py      # Génération recommandations
├── services/                   # Logique métier
│   └── recommandation_service.py  # Génération recommandations basées sur données réelles
└── utils/                      # Utilitaires
    ├── validators.py           # Validation des données
    └── historique.py           # Journalisation des actions
```

### Base de données

- **SGBD**: SQLite
- **ORM**: SQLAlchemy
- **Tables**:
  - `users` - Utilisateurs
  - `roles` - Rôles et permissions
  - `exploitations` - Exploitations agricoles
  - `parcelles` - Parcelles d'une exploitation
  - `analyses_sols` - Analyses de sol
  - `donnees_climatiques` - Données climatiques
  - `intrants` - Intrants agricoles
  - `recommandations` - Recommandations générées
  - `historiques_actions` - Journalisation

### Sécurité

- Authentification JWT
- Hashage des mots de passe avec bcrypt
- Validation des données d'entrée
- Journalisation des actions utilisateur

## Frontend (Flutter)

### Architecture Clean Architecture

```
lib/
├── main.dart                   # Point d'entrée
├── core/                       # Couche core
│   ├── constants/             # Constantes (API, App)
│   ├── errors/                # Classes d'erreur
│   └── utils/                 # Utilitaires
├── data/                       # Couche données
│   ├── models/                # Modèles de données
│   ├── datasources/           # Sources de données (API, Local)
│   └── repositories/          # Repositories
├── domain/                     # Couche domaine (à implémenter)
│   ├── entities/              # Entités métier
│   ├── repositories/          # Interfaces repositories
│   └── usecases/              # Cas d'usage
└── presentation/               # Couche présentation
    ├── providers/              # State management (Provider)
    ├── screens/                # Écrans
    └── widgets/                # Widgets réutilisables
```

### Gestion d'état

- **Provider**: Utilisé pour la gestion d'état globale
- **Providers principaux**:
  - `AuthProvider` - Authentification
  - `ExploitationProvider` - Gestion des exploitations

### Écrans implémentés

1. **LoginScreen** - Authentification
2. **HomeScreen** - Écran principal avec navigation
3. **ExploitationsListScreen** - Liste des exploitations
4. **AddExploitationScreen** - Création d'exploitation
5. **ExploitationDetailScreen** - Détails d'une exploitation

### Modèles de données

Tous les modèles utilisent `json_serializable` pour la sérialisation JSON :
- `UserModel`, `RoleModel`
- `ExploitationModel`
- `ParcelleModel`
- `AnalyseSolModel`
- `DonneeClimatiqueModel`
- `IntrantModel`
- `RecommandationModel`

## Flux de données

1. **Authentification**:
   - User saisit credentials → `AuthProvider.login()` → `AuthRepository` → `ApiService` → Backend
   - Token JWT stocké dans `FlutterSecureStorage`

2. **Gestion des exploitations**:
   - User crée exploitation → `ExploitationProvider.createExploitation()` → `ExploitationRepository` → `ApiService` → Backend
   - Liste chargée via `ExploitationProvider.loadExploitations()`

3. **Recommandations**:
   - Backend analyse les données réelles saisies
   - Génère des recommandations basées sur règles agronomiques explicites
   - Aucune donnée par défaut ou simulée

## Principes respectés

✅ **Aucune donnée par défaut**: Toutes les données sont saisies par l'utilisateur  
✅ **Recommandations traçables**: Chaque recommandation indique les paramètres utilisés  
✅ **Transparence**: Logique métier explicite et déterministe  
✅ **Mode hors-ligne**: Architecture prête pour synchronisation (à implémenter)  
✅ **Sécurité**: Authentification JWT, validation des données  

## Prochaines étapes

1. Implémenter les écrans pour analyses de sol, intrants, recommandations
2. Ajouter la gestion hors-ligne avec SQLite local
3. Implémenter les graphiques et visualisations
4. Ajouter la gestion des parcelles
5. Compléter la couche domain (entities, usecases)
6. Ajouter les tests unitaires et d'intégration

