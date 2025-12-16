"""
Modèles SQLAlchemy pour AGRIGEO
"""
from models.user import User, Role
from models.exploitation import Exploitation, Parcelle
from models.analyse_sol import AnalyseSol
from models.donnee_climatique import DonneeClimatique
from models.intrant import Intrant
from models.recommandation import Recommandation
from models.historique_action import HistoriqueAction

__all__ = [
    'User', 'Role',
    'Exploitation', 'Parcelle',
    'AnalyseSol',
    'DonneeClimatique',
    'Intrant',
    'Recommandation',
    'HistoriqueAction'
]

