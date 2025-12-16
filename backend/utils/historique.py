"""
Utilitaires pour l'historique des actions
"""
from database import db
from models.historique_action import HistoriqueAction
import json

def log_action(user_id, action, entite, entite_id, details=None):
    """Enregistre une action dans l'historique"""
    try:
        historique = HistoriqueAction(
            action=action,
            entite=entite,
            entite_id=entite_id,
            details=json.dumps(details) if details else None,
            user_id=user_id
        )
        db.session.add(historique)
        db.session.commit()
    except Exception as e:
        # Ne pas faire échouer l'opération principale si l'historique échoue
        print(f"Erreur lors de l'enregistrement de l'historique: {e}")
        db.session.rollback()

