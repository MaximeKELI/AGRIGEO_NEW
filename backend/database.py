"""
Configuration de la base de données SQLite avec SQLAlchemy
"""
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

def init_db():
    """Initialise la base de données et crée toutes les tables"""
    # Importer tous les modèles pour qu'ils soient enregistrés
    from models import User, Role, Exploitation, Parcelle, AnalyseSol, DonneeClimatique, Intrant, Recommandation, HistoriqueAction
    db.create_all()
    
    # Créer les rôles de base s'ils n'existent pas
    roles_data = [
        {'nom': 'Agriculteur', 'description': 'Producteur agricole'},
        {'nom': 'Technicien', 'description': 'Technicien agricole'},
        {'nom': 'Agent', 'description': 'Agent de développement agricole'},
    ]
    
    for role_data in roles_data:
        existing_role = Role.query.filter_by(nom=role_data['nom']).first()
        if not existing_role:
            role = Role(nom=role_data['nom'], description=role_data['description'])
            db.session.add(role)
    
    db.session.commit()
    print("Base de données initialisée avec succès")

