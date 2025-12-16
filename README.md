# AGRIGEO - Plateforme Agricole Intelligente

AGRIGEO est une plateforme agricole révolutionnaire qui combine l'intelligence artificielle, la cartographie avancée, et les technologies mobiles pour transformer l'agriculture au Togo et en Afrique.

## 🌟 Vision

Créer un écosystème agricole intelligent qui permet aux producteurs d'optimiser leurs rendements, d'accéder aux marchés internationaux, et de contribuer à la sécurité alimentaire de l'Afrique.

## 📋 Objectif Général

Concevoir et implémenter une application professionnelle nommée AGRIGEO, destinée à la gestion intelligente des sols et à l'optimisation des pratiques agricoles, basée exclusivement sur les données saisies par les utilisateurs (agriculteurs, techniciens, agents).

⚠️ **Aucune donnée par défaut, simulée ou inventée n'est autorisée.** Toutes les analyses, recommandations et visualisations doivent être strictement dérivées des données réelles fournies par l'utilisateur.

## 🏗️ Architecture Technique

### Frontend (Flutter)
- **Framework**: Flutter (Dart)
- **Cibles**: Android (prioritaire), iOS (optionnel), Web (optionnel)
- **Architecture**: Clean Architecture / MVVM
- **Gestion d'état**: Provider
- **Communication API**: REST (HTTP / JSON)

### Backend (Flask)
- **Langage**: Python 3.11+
- **Framework**: Flask
- **Architecture**:
  - `routes/` (API endpoints)
  - `services/` (logique métier)
  - `models/` (ORM / schéma DB)
  - `utils/` (validation, calculs, helpers)
- **Validation**: Marshmallow
- **Sécurité**: JWT (authentification)

### Base de données
- **SGBD**: SQLite
- **ORM**: SQLAlchemy
- **Contraintes**:
  - Relations normalisées
  - Intégrité référentielle
  - Historisation des données (timestamp)

## 🚀 Installation et Démarrage

### Backend

1. Installer les dépendances Python :
```bash
cd backend
pip install -r requirements.txt
```

2. Configurer les variables d'environnement :
```bash
cp .env.example .env
# Éditer .env avec vos valeurs
```

3. Lancer le serveur Flask :
```bash
python app.py
```

Le serveur sera accessible sur `http://localhost:5000`

### Frontend (Flutter)

1. Installer les dépendances Flutter :
```bash
cd agrigeo
flutter pub get
```

2. Générer les fichiers JSON (après avoir installé build_runner) :
```bash
flutter pub run build_runner build
```

3. Lancer l'application :
```bash
flutter run
```

## 📱 Fonctionnalités

### Rôles Utilisateurs
- **Agriculteur**: Gère ses exploitations et consulte les recommandations
- **Technicien agricole**: Effectue des analyses de sol et génère des recommandations
- **Agent de suivi / administrateur**: Gère les utilisateurs et supervise le système

### Données Gérées
1. **Exploitations agricoles**: Nom, localisation, superficie, type de culture, historique
2. **Données du sol**: pH, humidité, texture, nutriments (N, P, K), observations
3. **Données climatiques**: Température (min/max), pluviométrie, période observée
4. **Intrants agricoles**: Type, quantité, date d'application, culture concernée
5. **Recommandations**: Générées automatiquement basées sur les données réelles saisies

## 🔐 Sécurité & Éthique

- Données locales, non partagées sans consentement
- Aucun envoi externe automatique
- Export manuel uniquement (CSV / PDF)
- Respect total de la confidentialité des données agricoles

## 📊 Structure de la Base de Données

- `users`: Utilisateurs de l'application
- `roles`: Rôles et permissions
- `exploitations`: Exploitations agricoles
- `parcelles`: Parcelles d'une exploitation
- `analyses_sols`: Analyses de sol
- `donnees_climatiques`: Données climatiques
- `intrants`: Intrants agricoles
- `recommandations`: Recommandations générées
- `historiques_actions`: Journalisation des actions

## 🛑 Interdictions Absolues

❌ Données fictives  
❌ Valeurs par défaut agronomiques  
❌ Recommandations sans données  
❌ Dépendance à une API externe non validée par l'utilisateur  

## ✅ Critères de Succès

L'application AGRIGEO est considérée réussie si :
- Elle fonctionne uniquement avec les données utilisateur
- Elle est compréhensible, traçable et transparente
- Elle peut être utilisée en milieu rural avec faible connectivité

## 📄 Documentation

- Documentation technique: Voir les commentaires dans le code
- Guide utilisateur: À venir
- API Documentation: Accessible sur `/api/docs` (Swagger)

## 👥 Contribution

Ce projet est développé pour transformer l'agriculture en Afrique. Toute contribution est la bienvenue !

## 📝 Licence

[À définir]
