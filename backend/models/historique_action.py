"""
Modèle pour l'historique des actions utilisateur
"""
from database import db
from datetime import datetime

class HistoriqueAction(db.Model):
    """Journalisation des actions utilisateur"""
    __tablename__ = 'historiques_actions'
    
    id = db.Column(db.Integer, primary_key=True)
    action = db.Column(db.String(100), nullable=False)  # create, update, delete, view
    entite = db.Column(db.String(50), nullable=False)  # exploitation, analyse_sol, etc.
    entite_id = db.Column(db.Integer)
    details = db.Column(db.Text)  # Détails de l'action en JSON
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'action': self.action,
            'entite': self.entite,
            'entite_id': self.entite_id,
            'details': self.details,
            'user_id': self.user_id,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }




