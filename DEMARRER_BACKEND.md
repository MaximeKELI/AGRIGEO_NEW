# 🚀 Guide de démarrage du Backend AGRIGEO

## Méthode 1 : Démarrage simple (recommandé)

```bash
cd /home/maxime/AGRIGEO_NEW/backend
python3 app.py
```

Le serveur démarrera sur `http://localhost:5000`

## Méthode 2 : Avec le script de démarrage

```bash
cd /home/maxime/AGRIGEO_NEW/backend
./start.sh
```

## Méthode 3 : Avec Flask directement

```bash
cd /home/maxime/AGRIGEO_NEW/backend
export FLASK_APP=app.py
flask run --host=0.0.0.0 --port=5000
```

## Vérification que le serveur fonctionne

Une fois le serveur démarré, vous devriez voir :
```
 * Running on http://127.0.0.1:5000
 * Running on http://[::]:5000
```

Pour vérifier que tout fonctionne, ouvrez un navigateur et allez sur :
- **Health check** : http://localhost:5000/api/health
- Vous devriez voir : `{"status": "ok", "message": "AGRIGEO API is running"}`

## Arrêter le serveur

Appuyez sur `Ctrl+C` dans le terminal où le serveur tourne.

## Dépannage

### Port déjà utilisé
Si le port 5000 est déjà utilisé :
```bash
# Trouver le processus qui utilise le port 5000
lsof -i :5000

# Ou utiliser un autre port
python3 app.py --port 5001
```

### Erreur "Module not found"
Installez les dépendances :
```bash
cd /home/maxime/AGRIGEO_NEW/backend
pip3 install -r requirements.txt
```

### Erreur de base de données
La base de données sera créée automatiquement au premier démarrage.

## Configuration

- **Host** : `0.0.0.0` (accessible depuis toutes les interfaces réseau)
- **Port** : `5000`
- **URL API** : `http://localhost:5000/api`
- **Base de données** : `agrigeo.db` (SQLite, créée automatiquement)

## Notes importantes

- Gardez le terminal ouvert pendant que le serveur tourne
- Le serveur doit être démarré avant de lancer l'application Flutter
- Les modifications du code nécessitent un redémarrage du serveur

