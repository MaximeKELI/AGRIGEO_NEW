# AGRIGEO Backend API

API REST Flask pour la plateforme AGRIGEO.

## Installation

1. Créer un environnement virtuel :
```bash
python -m venv venv
source venv/bin/activate  # Sur Windows: venv\Scripts\activate
```

2. Installer les dépendances :
```bash
pip install -r requirements.txt
```

3. Configurer les variables d'environnement :
```bash
cp .env.example .env
# Éditer .env avec vos valeurs
```

4. Lancer le serveur :
```bash
python app.py
```

Le serveur sera accessible sur `http://localhost:5000`

## Structure

```
backend/
├── app.py                 # Point d'entrée de l'application
├── database.py            # Configuration de la base de données
├── models/                # Modèles SQLAlchemy
│   ├── user.py
│   ├── exploitation.py
│   ├── analyse_sol.py
│   ├── donnee_climatique.py
│   ├── intrant.py
│   ├── recommandation.py
│   └── historique_action.py
├── routes/                # Routes API
│   ├── auth.py
│   ├── users.py
│   ├── exploitations.py
│   ├── parcelles.py
│   ├── analyses_sols.py
│   ├── donnees_climatiques.py
│   ├── intrants.py
│   └── recommandations.py
├── services/              # Logique métier
│   └── recommandation_service.py
└── utils/                 # Utilitaires
    ├── validators.py
    └── historique.py
```

## Endpoints API

### Authentification
- `POST /api/auth/register` - Enregistrement d'un nouvel utilisateur
- `POST /api/auth/login` - Connexion
- `GET /api/auth/me` - Informations de l'utilisateur connecté

### Exploitations
- `GET /api/exploitations` - Liste des exploitations
- `POST /api/exploitations` - Créer une exploitation
- `GET /api/exploitations/<id>` - Détails d'une exploitation
- `PUT /api/exploitations/<id>` - Mettre à jour une exploitation
- `DELETE /api/exploitations/<id>` - Supprimer une exploitation

### Analyses de sol
- `GET /api/analyses-sols` - Liste des analyses
- `POST /api/analyses-sols` - Créer une analyse
- `GET /api/analyses-sols/<id>` - Détails d'une analyse
- `PUT /api/analyses-sols/<id>` - Mettre à jour une analyse
- `DELETE /api/analyses-sols/<id>` - Supprimer une analyse

### Recommandations
- `GET /api/recommandations` - Liste des recommandations
- `POST /api/recommandations/generate/<exploitation_id>` - Générer des recommandations
- `PUT /api/recommandations/<id>/status` - Mettre à jour le statut

## Documentation Swagger

Une fois le serveur lancé, la documentation Swagger est accessible sur :
`http://localhost:5000/api/docs`

## Base de données

La base de données SQLite est créée automatiquement au premier lancement dans le fichier `agrigeo.db`.

Pour réinitialiser la base de données, supprimez le fichier `agrigeo.db` et relancez l'application.

