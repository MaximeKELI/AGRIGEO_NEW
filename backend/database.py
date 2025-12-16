"""
Configuration de la base de données SQLite avec SQLAlchemy
"""
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

def init_db():
    """Initialise la base de données et crée toutes les tables"""
    # Importer tous les modèles pour qu'ils soient enregistrés
    from models import User, Role, Exploitation, Parcelle, AnalyseSol, DonneeClimatique, Intrant, Recommandation, HistoriqueAction
    db.create_all()
    print("Base de données initialisée avec succès")

