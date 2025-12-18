"""
Modèle pour les recommandations générées
"""
from database import db
from datetime import datetime

class Recommandation(db.Model):
    """Recommandation basée sur les données saisies"""
    __tablename__ = 'recommandations'
    
    id = db.Column(db.Integer, primary_key=True)
    type_recommandation = db.Column(db.String(100), nullable=False)  # Fertilisation, Irrigation, Traitement, etc.
    titre = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text, nullable=False)
    parametres_utilises = db.Column(db.Text)  # JSON string des paramètres utilisés pour générer la recommandation
    priorite = db.Column(db.String(20), default='moyenne')  # faible, moyenne, élevée
    statut = db.Column(db.String(20), default='non_appliquée')  # non_appliquée, en_cours, appliquée
    exploitation_id = db.Column(db.Integer, db.ForeignKey('exploitations.id'), nullable=False)
    parcelle_id = db.Column(db.Integer, db.ForeignKey('parcelles.id'))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'type_recommandation': self.type_recommandation,
            'titre': self.titre,
            'description': self.description,
            'parametres_utilises': self.parametres_utilises,
            'priorite': self.priorite,
            'statut': self.statut,
            'exploitation_id': self.exploitation_id,
            'parcelle_id': self.parcelle_id,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }




