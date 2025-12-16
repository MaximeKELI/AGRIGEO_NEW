"""
Modèle pour les données climatiques
"""
from database import db
from datetime import datetime

class DonneeClimatique(db.Model):
    """Données climatiques pour une exploitation"""
    __tablename__ = 'donnees_climatiques'
    
    id = db.Column(db.Integer, primary_key=True)
    date_debut = db.Column(db.Date, nullable=False)
    date_fin = db.Column(db.Date, nullable=False)
    temperature_min = db.Column(db.Float)  # Température minimale (°C)
    temperature_max = db.Column(db.Float)  # Température maximale (°C)
    pluviometrie = db.Column(db.Float)  # Pluviométrie en mm
    periode_observée = db.Column(db.String(100))  # Description de la période
    exploitation_id = db.Column(db.Integer, db.ForeignKey('exploitations.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'date_debut': self.date_debut.isoformat() if self.date_debut else None,
            'date_fin': self.date_fin.isoformat() if self.date_fin else None,
            'temperature_min': self.temperature_min,
            'temperature_max': self.temperature_max,
            'pluviometrie': self.pluviometrie,
            'periode_observée': self.periode_observée,
            'exploitation_id': self.exploitation_id,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

