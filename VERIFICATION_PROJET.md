# Vérification de Cohérence du Projet AGRIGEO

## 🔴 Problèmes Critiques Identifiés

### 1. Incohérence snake_case / camelCase entre Backend et Frontend

**Problème** : Le backend renvoie des données en `snake_case` (ex: `localisation_texte`, `superficie_totale`) mais le frontend attend du `camelCase` (ex: `localisationTexte`, `superficieTotale`).

**Fichiers affectés** :
- Tous les modèles frontend (`exploitation_model.dart`, `analyse_sol_model.dart`, `intrant_model.dart`, etc.)
- Les fichiers `.g.dart` générés attendent camelCase mais reçoivent snake_case

**Solution** : Ajouter des annotations `@JsonKey` dans tous les modèles pour mapper correctement.

### 2. Erreurs de Compilation

#### exploitation_detail_screen.dart
- Ligne 254 : Accolade manquante
- Lignes 94-107 : Variable `_buildInfoRow` utilisée avant déclaration
- Ligne 66 : Retour manquant dans build()

#### recommandations_screen.dart
- Ligne 112 : Erreur de syntaxe (virgule manquante, fonction nommée incorrecte)
- Lignes 221-224 : Erreurs de syntaxe

#### exploitations_list_screen.dart & home_screen.dart
- `Icons.farm` n'existe pas dans Flutter Material Icons

#### sync_service.dart
- Lignes 107, 139, 171, 195 : Paramètre `message` requis manquant dans `SyncResult`

### 3. Tests Incompatibles

- `test_exploitation_provider.dart` : Utilise des paramètres qui n'existent pas dans les modèles
- `test_auth_provider.dart` : Tentative d'accès à un setter `error` qui n'existe pas

## ✅ Points Positifs

### Routes API Backend
- ✅ Toutes les routes sont bien définies
- ✅ Les endpoints correspondent aux constantes frontend
- ✅ Les méthodes HTTP sont correctes (GET, POST, PUT, DELETE)

### Structure de la Base de Données
- ✅ Tous les modèles sont bien définis
- ✅ Les relations sont correctes
- ✅ Les clés étrangères sont bien configurées

### Communication Frontend-Backend
- ✅ Les endpoints dans `api_constants.dart` correspondent aux routes backend
- ✅ Les méthodes dans `api_service.dart` appellent les bons endpoints
- ✅ La gestion des erreurs est cohérente

## 📋 Actions à Effectuer

### Priorité 1 (Critique)
1. ✅ Ajouter `@JsonKey` dans tous les modèles pour mapper snake_case → camelCase
2. ✅ Corriger les erreurs de compilation dans les screens
3. ✅ Corriger sync_service.dart

### Priorité 2 (Important)
4. ✅ Corriger les tests
5. ✅ Vérifier que tous les champs backend correspondent aux modèles frontend
6. ✅ Ajouter des validations côté backend pour les données reçues

### Priorité 3 (Amélioration)
7. ✅ Nettoyer les imports inutilisés
8. ✅ Uniformiser la gestion des erreurs
9. ✅ Ajouter des tests d'intégration

## 🔍 Détails par Modèle

### ExploitationModel
- Backend : `localisation_texte` → Frontend : `localisationTexte` ❌
- Backend : `superficie_totale` → Frontend : `superficieTotale` ❌
- Backend : `type_culture_principal` → Frontend : `typeCulturePrincipal` ❌
- Backend : `historique_cultural` → Frontend : `historiqueCultural` ❌
- Backend : `proprietaire_id` → Frontend : `proprietaireId` ❌
- Backend : `created_at` → Frontend : `createdAt` ❌
- Backend : `updated_at` → Frontend : `updatedAt` ❌
- Backend : `parcelles_count` → Frontend : `parcellesCount` ❌

### AnalyseSolModel
- Backend : `date_prelevement` → Frontend : `datePrelevement` ❌
- Backend : `azote_n` → Frontend : `azoteN` ❌
- Backend : `phosphore_p` → Frontend : `phosphoreP` ❌
- Backend : `potassium_k` → Frontend : `potassiumK` ❌
- Backend : `exploitation_id` → Frontend : `exploitationId` ❌
- Backend : `parcelle_id` → Frontend : `parcelleId` ❌
- Backend : `technicien_id` → Frontend : `technicienId` ❌
- Backend : `created_at` → Frontend : `createdAt` ❌
- Backend : `updated_at` → Frontend : `updatedAt` ❌

### IntrantModel
- Backend : `type_intrant` → Frontend : `typeIntrant` ❌
- Backend : `nom_commercial` → Frontend : `nomCommercial` ❌
- Backend : `date_application` → Frontend : `dateApplication` ❌
- Backend : `culture_concernée` → Frontend : `cultureConcernee` ❌
- Backend : `exploitation_id` → Frontend : `exploitationId` ❌
- Backend : `parcelle_id` → Frontend : `parcelleId` ❌
- Backend : `created_at` → Frontend : `createdAt` ❌
- Backend : `updated_at` → Frontend : `updatedAt` ❌

## 📝 Notes

- Le backend utilise Python/Flask avec SQLAlchemy
- Le frontend utilise Flutter/Dart avec json_serializable
- La conversion automatique snake_case ↔ camelCase n'est pas configurée
- Il faut soit :
  - Option A : Ajouter @JsonKey dans tous les modèles frontend (recommandé)
  - Option B : Modifier le backend pour renvoyer camelCase (non recommandé, casse la convention Python)

