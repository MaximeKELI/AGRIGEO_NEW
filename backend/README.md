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

   Variables d'environnement requises :
   - `OPENWEATHER_API_KEY` : Clé API OpenWeatherMap (obtenue sur https://openweathermap.org/api)
   - `SECRET_KEY` : Clé secrète Flask (pour la session)
   - `JWT_SECRET_KEY` : Clé secrète JWT (pour les tokens)
   - `DATABASE_URL` : URL de la base de données (par défaut: sqlite:///agrigeo.db)
   
   Exemple de fichier `.env` :
   ```env
   OPENWEATHER_API_KEY=votre_cle_api_openweather
   SECRET_KEY=votre_secret_key
   JWT_SECRET_KEY=votre_jwt_secret_key
   DATABASE_URL=sqlite:///agrigeo.db
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
│   ├── recommandation_service.py
│   ├── irrigation_service.py
│   └── meteo_service.py
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

### Météo (OpenWeatherMap)
- `GET /api/meteo/actuelle?latitude=X&longitude=Y` - Météo actuelle par coordonnées
- `GET /api/meteo/actuelle?exploitation_id=X` - Météo actuelle pour une exploitation
- `GET /api/meteo/previsions?latitude=X&longitude=Y` - Prévisions météo par coordonnées
- `GET /api/meteo/previsions?exploitation_id=X` - Prévisions météo pour une exploitation
- `GET /api/meteo/ville?ville=Paris&pays=FR` - Météo actuelle par nom de ville
- `GET /api/meteo/complete/<exploitation_id>` - Météo actuelle + prévisions pour une exploitation
- `GET /api/meteo/conseils-irrigation/<exploitation_id>` - Conseils d'irrigation avec météo automatique
- `POST /api/meteo/conseils-irrigation/<exploitation_id>` - Conseils d'irrigation avec météo fournie

## Documentation Swagger

Une fois le serveur lancé, la documentation Swagger est accessible sur :
`http://localhost:5000/api/docs`

## Base de données

La base de données SQLite est créée automatiquement au premier lancement dans le fichier `agrigeo.db`.

Pour réinitialiser la base de données, supprimez le fichier `agrigeo.db` et relancez l'application.

