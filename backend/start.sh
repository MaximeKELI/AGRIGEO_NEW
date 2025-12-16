#!/bin/bash

# Script de démarrage du backend AGRIGEO

echo "🚀 Démarrage du backend AGRIGEO..."
echo ""

# Vérifier si Python est installé
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 n'est pas installé"
    exit 1
fi

# Vérifier si les dépendances sont installées
if [ ! -d "venv" ]; then
    echo "📦 Création de l'environnement virtuel..."
    python3 -m venv venv
fi

echo "📦 Activation de l'environnement virtuel..."
source venv/bin/activate

echo "📦 Installation des dépendances..."
pip install -r requirements.txt --quiet

echo ""
echo "✅ Démarrage du serveur Flask sur http://localhost:5000"
echo "📝 Appuyez sur Ctrl+C pour arrêter le serveur"
echo ""

# Démarrer le serveur
python3 app.py

