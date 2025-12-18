"""
Modèle pour les récoltes agricoles
"""
from database import db
from datetime import datetime

class Recolte(db.Model):
    """Récolte agricole"""
    __tablename__ = 'recoltes'
    
    id = db.Column(db.Integer, primary_key=True)
    exploitation_id = db.Column(db.Integer, db.ForeignKey('exploitations.id'), nullable=False)
    parcelle_id = db.Column(db.Integer, db.ForeignKey('parcelles.id'))
    type_culture = db.Column(db.String(100), nullable=False)  # Type de culture
    mois = db.Column(db.Integer, nullable=False)  # Mois (1-12)
    annee = db.Column(db.Integer, nullable=False)  # Année
    quantite_recoltee = db.Column(db.Float, nullable=False)  # Quantité récoltée
    unite_mesure = db.Column(db.String(20), nullable=False, default='kg')  # Unité de mesure
    superficie_recoltee = db.Column(db.Float)  # Superficie en hectares
    rendement = db.Column(db.Float)  # Rendement en kg/ha ou tonnes/ha
    prix_vente = db.Column(db.Float)  # Prix de vente unitaire
    cout_production = db.Column(db.Float)  # Coût de production total
    qualite = db.Column(db.String(50))  # 'excellente', 'bonne', 'moyenne', 'mauvaise'
    conditions_climatiques = db.Column(db.Text)  # Conditions météo
    observations = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'exploitation_id': self.exploitation_id,
            'parcelle_id': self.parcelle_id,
            'type_culture': self.type_culture,
            'mois': self.mois,
            'annee': self.annee,
            'quantite_recoltee': self.quantite_recoltee,
            'unite_mesure': self.unite_mesure,
            'superficie_recoltee': self.superficie_recoltee,
            'rendement': self.rendement or (self.quantite_recoltee / self.superficie_recoltee if self.superficie_recoltee else None),
            'prix_vente': self.prix_vente,
            'cout_production': self.cout_production,
            'qualite': self.qualite,
            'conditions_climatiques': self.conditions_climatiques,
            'observations': self.observations,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }




