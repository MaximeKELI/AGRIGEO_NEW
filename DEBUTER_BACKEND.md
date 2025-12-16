# Guide de démarrage du backend AGRIGEO

## Prérequis

- Python 3.8 ou supérieur
- pip (gestionnaire de paquets Python)

## Installation

1. **Installer les dépendances** :
```bash
cd backend
pip install -r requirements.txt
```

2. **Vérifier que Flask est installé** :
```bash
python3 -c "import flask; print('Flask installé')"
```

## Démarrage du serveur

1. **Se placer dans le dossier backend** :
```bash
cd /home/maxime/AGRIGEO_NEW/backend
```

2. **Démarrer le serveur Flask** :
```bash
python3 app.py
```

Ou avec Flask directement :
```bash
flask run --host=0.0.0.0 --port=5000
```

3. **Vérifier que le serveur fonctionne** :
   - Ouvrir un navigateur et aller sur : `http://localhost:5000/api/health`
   - Vous devriez voir : `{"status": "ok", "message": "AGRIGEO API is running"}`

## Configuration

Le backend écoute par défaut sur :
- **Host** : `0.0.0.0` (toutes les interfaces)
- **Port** : `5000`
- **URL de base** : `http://localhost:5000/api`

## Vérification de la connexion depuis Flutter

L'application Flutter est configurée pour se connecter à `http://localhost:5000/api`.

Si vous utilisez un appareil physique ou un émulateur, vous devrez peut-être modifier l'URL dans :
- `agrigeo/lib/core/constants/api_constants.dart`

## Dépannage

### Erreur "Connection refused"
- Vérifiez que le backend est démarré
- Vérifiez que le port 5000 n'est pas utilisé par un autre processus :
  ```bash
  lsof -i :5000
  ```

### Erreur "Module not found"
- Réinstallez les dépendances :
  ```bash
  pip install -r requirements.txt
  ```

### Erreur de base de données
- Le backend créera automatiquement la base de données SQLite au premier démarrage
- Vérifiez que vous avez les permissions d'écriture dans le dossier backend

## Arrêt du serveur

Appuyez sur `Ctrl+C` dans le terminal où le serveur est en cours d'exécution.

