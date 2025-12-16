"""
Modèle pour les intrants agricoles
"""
from database import db
from datetime import datetime

class Intrant(db.Model):
    """Intrant agricole utilisé"""
    __tablename__ = 'intrants'
    
    id = db.Column(db.Integer, primary_key=True)
    type_intrant = db.Column(db.String(100), nullable=False)  # Engrais, Pesticide, Semence, etc.
    nom_commercial = db.Column(db.String(200))
    quantite = db.Column(db.Float, nullable=False)
    unite = db.Column(db.String(20), default='kg')  # kg, L, unités, etc.
    date_application = db.Column(db.Date, nullable=False)
    culture_concernée = db.Column(db.String(100))
    exploitation_id = db.Column(db.Integer, db.ForeignKey('exploitations.id'), nullable=False)
    parcelle_id = db.Column(db.Integer, db.ForeignKey('parcelles.id'))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'type_intrant': self.type_intrant,
            'nom_commercial': self.nom_commercial,
            'quantite': self.quantite,
            'unite': self.unite,
            'date_application': self.date_application.isoformat() if self.date_application else None,
            'culture_concernée': self.culture_concernée,
            'exploitation_id': self.exploitation_id,
            'parcelle_id': self.parcelle_id,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

