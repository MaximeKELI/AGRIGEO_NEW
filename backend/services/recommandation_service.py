"""
Service de génération de recommandations basées sur les données réelles
⚠️ Aucune donnée par défaut - toutes les recommandations sont basées sur les données saisies
"""
from database import db
from models.analyse_sol import AnalyseSol
from models.donnee_climatique import DonneeClimatique
from models.intrant import Intrant
from models.exploitation import Exploitation, Parcelle
from datetime import datetime, timedelta

def generate_recommandations(exploitation_id):
    """
    Génère des recommandations basées uniquement sur les données réelles saisies
    Retourne une liste de recommandations avec leurs paramètres utilisés
    """
    recommandations = []
    
    # Récupérer toutes les données de l'exploitation
    exploitation = Exploitation.query.get(exploitation_id)
    if not exploitation:
        return recommandations
    
    # Récupérer les analyses de sol les plus récentes
    analyses_sols = AnalyseSol.query.filter_by(exploitation_id=exploitation_id)\
        .order_by(AnalyseSol.date_prelevement.desc()).all()
    
    # Récupérer les données climatiques récentes
    donnees_climatiques = DonneeClimatique.query.filter_by(exploitation_id=exploitation_id)\
        .order_by(DonneeClimatique.date_debut.desc()).limit(5).all()
    
    # Récupérer les intrants récents
    intrants = Intrant.query.filter_by(exploitation_id=exploitation_id)\
        .order_by(Intrant.date_application.desc()).limit(10).all()
    
    # 1. Recommandations basées sur l'analyse de sol
    if analyses_sols:
        derniere_analyse = analyses_sols[0]
        parametres_utilises = {
            'ph': derniere_analyse.ph,
            'azote_n': derniere_analyse.azote_n,
            'phosphore_p': derniere_analyse.phosphore_p,
            'potassium_k': derniere_analyse.potassium_k,
            'date_prelevement': derniere_analyse.date_prelevement.isoformat() if derniere_analyse.date_prelevement else None
        }
        
        # Recommandation pH
        if derniere_analyse.ph is not None:
            if derniere_analyse.ph < 6.0:
                recommandations.append({
                    'type_recommandation': 'Amendement',
                    'titre': 'Sol trop acide',
                    'description': f'Le pH du sol ({derniere_analyse.ph:.2f}) est inférieur à 6.0. Il est recommandé d\'ajouter de la chaux pour augmenter le pH.',
                    'parametres_utilises': parametres_utilises,
                    'priorite': 'élevée',
                    'parcelle_id': derniere_analyse.parcelle_id
                })
            elif derniere_analyse.ph > 7.5:
                recommandations.append({
                    'type_recommandation': 'Amendement',
                    'titre': 'Sol trop alcalin',
                    'description': f'Le pH du sol ({derniere_analyse.ph:.2f}) est supérieur à 7.5. Il est recommandé d\'ajouter du soufre ou des matières organiques pour réduire le pH.',
                    'parametres_utilises': parametres_utilises,
                    'priorite': 'moyenne',
                    'parcelle_id': derniere_analyse.parcelle_id
                })
        
        # Recommandation nutriments
        if derniere_analyse.azote_n is not None and derniere_analyse.phosphore_p is not None and derniere_analyse.potassium_k is not None:
            # Calculer les moyennes si plusieurs analyses existent
            if len(analyses_sols) > 1:
                moy_n = sum(a.azote_n for a in analyses_sols[:3] if a.azote_n) / len([a for a in analyses_sols[:3] if a.azote_n])
                moy_p = sum(a.phosphore_p for a in analyses_sols[:3] if a.phosphore_p) / len([a for a in analyses_sols[:3] if a.phosphore_p])
                moy_k = sum(a.potassium_k for a in analyses_sols[:3] if a.potassium_k) / len([a for a in analyses_sols[:3] if a.potassium_k])
                
                parametres_utilises['moyenne_azote'] = moy_n
                parametres_utilises['moyenne_phosphore'] = moy_p
                parametres_utilises['moyenne_potassium'] = moy_k
                
                # Recommandation basée sur les moyennes
                if moy_n < 20:
                    recommandations.append({
                        'type_recommandation': 'Fertilisation',
                        'titre': 'Carence en azote',
                        'description': f'La teneur moyenne en azote ({moy_n:.2f} mg/kg) est faible. Application d\'engrais azoté recommandée.',
                        'parametres_utilises': parametres_utilises,
                        'priorite': 'élevée',
                        'parcelle_id': derniere_analyse.parcelle_id
                    })
                
                if moy_p < 15:
                    recommandations.append({
                        'type_recommandation': 'Fertilisation',
                        'titre': 'Carence en phosphore',
                        'description': f'La teneur moyenne en phosphore ({moy_p:.2f} mg/kg) est faible. Application d\'engrais phosphaté recommandée.',
                        'parametres_utilises': parametres_utilises,
                        'priorite': 'élevée',
                        'parcelle_id': derniere_analyse.parcelle_id
                    })
                
                if moy_k < 150:
                    recommandations.append({
                        'type_recommandation': 'Fertilisation',
                        'titre': 'Carence en potassium',
                        'description': f'La teneur moyenne en potassium ({moy_k:.2f} mg/kg) est faible. Application d\'engrais potassique recommandée.',
                        'parametres_utilises': parametres_utilises,
                        'priorite': 'moyenne',
                        'parcelle_id': derniere_analyse.parcelle_id
                    })
            else:
                # Utiliser la seule analyse disponible
                if derniere_analyse.azote_n < 20:
                    recommandations.append({
                        'type_recommandation': 'Fertilisation',
                        'titre': 'Carence en azote',
                        'description': f'La teneur en azote ({derniere_analyse.azote_n:.2f} mg/kg) est faible. Application d\'engrais azoté recommandée.',
                        'parametres_utilises': parametres_utilises,
                        'priorite': 'élevée',
                        'parcelle_id': derniere_analyse.parcelle_id
                    })
    
    # 2. Recommandations basées sur les données climatiques
    if donnees_climatiques:
        derniere_donnee = donnees_climatiques[0]
        parametres_climatiques = {
            'temperature_min': derniere_donnee.temperature_min,
            'temperature_max': derniere_donnee.temperature_max,
            'pluviometrie': derniere_donnee.pluviometrie,
            'periode': f"{derniere_donnee.date_debut} à {derniere_donnee.date_fin}"
        }
        
        if derniere_donnee.pluviometrie is not None:
            if derniere_donnee.pluviometrie < 50:
                recommandations.append({
                    'type_recommandation': 'Irrigation',
                    'titre': 'Pluviométrie insuffisante',
                    'description': f'La pluviométrie observée ({derniere_donnee.pluviometrie:.1f} mm) est faible. Irrigation complémentaire recommandée.',
                    'parametres_utilises': parametres_climatiques,
                    'priorite': 'élevée'
                })
            elif derniere_donnee.pluviometrie > 300:
                recommandations.append({
                    'type_recommandation': 'Gestion de l\'eau',
                    'titre': 'Pluviométrie excessive',
                    'description': f'La pluviométrie observée ({derniere_donnee.pluviometrie:.1f} mm) est élevée. Vérifier le drainage et éviter l\'engorgement.',
                    'parametres_utilises': parametres_climatiques,
                    'priorite': 'moyenne'
                })
    
    # 3. Recommandations basées sur l'historique des intrants
    if intrants:
        # Analyser les types d'intrants utilisés
        types_intrants = {}
        for intrant in intrants:
            if intrant.type_intrant not in types_intrants:
                types_intrants[intrant.type_intrant] = []
            types_intrants[intrant.type_intrant].append(intrant)
        
        # Recommandation si pas d'intrants récents
        derniers_intrants = sorted(intrants, key=lambda x: x.date_application, reverse=True)
        if derniers_intrants:
            dernier_intrant = derniers_intrants[0]
            jours_ecoules = (datetime.now().date() - dernier_intrant.date_application).days
            
            if jours_ecoules > 90:
                recommandations.append({
                    'type_recommandation': 'Planification',
                    'titre': 'Révision des intrants nécessaire',
                    'description': f'Aucun intrant appliqué depuis {jours_ecoules} jours. Révision du plan de fertilisation recommandée.',
                    'parametres_utilises': {
                        'dernier_intrant': dernier_intrant.type_intrant,
                        'date_application': dernier_intrant.date_application.isoformat(),
                        'jours_ecoules': jours_ecoules
                    },
                    'priorite': 'moyenne',
                    'parcelle_id': dernier_intrant.parcelle_id
                })
    
    # Si aucune donnée suffisante, retourner une recommandation informative
    if not recommandations and not analyses_sols and not donnees_climatiques:
        recommandations.append({
            'type_recommandation': 'Information',
            'titre': 'Données insuffisantes',
            'description': 'Aucune recommandation ne peut être générée car les données nécessaires (analyses de sol, données climatiques) ne sont pas encore disponibles. Veuillez saisir des données pour obtenir des recommandations personnalisées.',
            'parametres_utilises': {},
            'priorite': 'faible'
        })
    
    return recommandations

