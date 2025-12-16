"""
Modèle pour les analyses de sol
"""
from database import db
from datetime import datetime

class AnalyseSol(db.Model):
    """Analyse de sol d'une parcelle"""
    __tablename__ = 'analyses_sols'
    
    id = db.Column(db.Integer, primary_key=True)
    date_prelevement = db.Column(db.Date, nullable=False)
    ph = db.Column(db.Float)  # pH du sol
    humidite = db.Column(db.Float)  # Humidité (%)
    texture = db.Column(db.String(100))  # Texture libre (sableux, argileux, etc.)
    azote_n = db.Column(db.Float)  # Azote (N) en mg/kg
    phosphore_p = db.Column(db.Float)  # Phosphore (P) en mg/kg
    potassium_k = db.Column(db.Float)  # Potassium (K) en mg/kg
    observations = db.Column(db.Text)  # Observations libres
    exploitation_id = db.Column(db.Integer, db.ForeignKey('exploitations.id'), nullable=False)
    parcelle_id = db.Column(db.Integer, db.ForeignKey('parcelles.id'))
    technicien_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'date_prelevement': self.date_prelevement.isoformat() if self.date_prelevement else None,
            'ph': self.ph,
            'humidite': self.humidite,
            'texture': self.texture,
            'azote_n': self.azote_n,
            'phosphore_p': self.phosphore_p,
            'potassium_k': self.potassium_k,
            'observations': self.observations,
            'exploitation_id': self.exploitation_id,
            'parcelle_id': self.parcelle_id,
            'technicien_id': self.technicien_id,
            'technicien': self.technicien.to_dict() if self.technicien else None,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

