"""
Service de génération de conseils d'irrigation basés sur la météo
⚠️ Basé uniquement sur les données météo réelles fournies
"""
from datetime import datetime, timedelta
from typing import Dict, List, Optional

def generate_conseils_irrigation(
    meteo_actuelle: Dict,
    previsions: List[Dict],
    derniere_pluviometrie: Optional[float] = None,
    type_culture: Optional[str] = None,
) -> List[Dict]:
    """
    Génère des conseils d'irrigation basés sur les données météo réelles
    
    Args:
        meteo_actuelle: Données météo actuelles (température, humidité, pluviométrie)
        previsions: Liste des prévisions météo (prochaines heures/jours)
        derniere_pluviometrie: Dernière pluviométrie enregistrée (mm)
        type_culture: Type de culture pour adapter les conseils
    
    Returns:
        Liste de conseils d'irrigation avec paramètres utilisés
    """
    conseils = []
    parametres_utilises = {
        'temperature_actuelle': meteo_actuelle.get('temperature'),
        'humidite_actuelle': meteo_actuelle.get('humidite'),
        'pluviometrie_actuelle': meteo_actuelle.get('pluviometrie', 0),
        'date_analyse': datetime.now().isoformat(),
    }

    # 1. Analyse de la pluviométrie actuelle et prévue
    pluviometrie_actuelle = meteo_actuelle.get('pluviometrie', 0) or 0
    pluviometrie_prevue_24h = sum(
        p.get('pluviometrie', 0) or 0 for p in previsions[:8]  # 8 * 3h = 24h
    )
    pluviometrie_totale = pluviometrie_actuelle + pluviometrie_prevue_24h

    parametres_utilises['pluviometrie_prevue_24h'] = pluviometrie_prevue_24h
    parametres_utilises['pluviometrie_totale'] = pluviometrie_totale

    # 2. Analyse de la température
    temperature = meteo_actuelle.get('temperature')
    temperature_max = meteo_actuelle.get('temperature_max', temperature)
    humidite = meteo_actuelle.get('humidite')

    # 3. Besoins en eau selon la culture (valeurs indicatives basées sur données utilisateur)
    besoins_eau_journaliers = {
        'maïs': 5.0,  # mm/jour
        'riz': 8.0,
        'coton': 6.0,
        'manioc': 3.0,
        'igname': 4.0,
        'tomate': 4.5,
        'haricot': 3.5,
    }
    
    besoin_eau = besoins_eau_journaliers.get(type_culture.lower() if type_culture else '', 4.0)
    parametres_utilises['besoin_eau_culture'] = besoin_eau
    parametres_utilises['type_culture'] = type_culture

    # 4. Calcul du déficit hydrique
    besoin_eau_24h = besoin_eau * 1  # Besoin pour 24h
    deficit_hydrique = besoin_eau_24h - pluviometrie_totale

    parametres_utilises['besoin_eau_24h'] = besoin_eau_24h
    parametres_utilises['deficit_hydrique'] = deficit_hydrique

    # 5. Conseils basés sur le déficit hydrique
    if deficit_hydrique > 5:
        conseils.append({
            'type': 'irrigation_urgente',
            'titre': 'Irrigation urgente recommandée',
            'description': f'Le déficit hydrique est de {deficit_hydrique:.1f} mm. '
                          f'La pluviométrie prévue ({pluviometrie_prevue_24h:.1f} mm) est insuffisante '
                          f'pour couvrir les besoins de la culture ({besoin_eau_24h:.1f} mm/jour). '
                          f'Irrigation immédiate recommandée.',
            'quantite_recommandee': f'{deficit_hydrique:.1f} mm',
            'priorite': 'élevée',
            'parametres_utilises': parametres_utilises.copy(),
        })
    elif deficit_hydrique > 2:
        conseils.append({
            'type': 'irrigation_recommandee',
            'titre': 'Irrigation recommandée',
            'description': f'Déficit hydrique modéré de {deficit_hydrique:.1f} mm. '
                          f'Irrigation complémentaire recommandée pour optimiser la croissance.',
            'quantite_recommandee': f'{deficit_hydrique:.1f} mm',
            'priorite': 'moyenne',
            'parametres_utilises': parametres_utilises.copy(),
        })
    elif pluviometrie_totale >= besoin_eau_24h:
        conseils.append({
            'type': 'irrigation_non_necessaire',
            'titre': 'Irrigation non nécessaire',
            'description': f'La pluviométrie prévue ({pluviometrie_prevue_24h:.1f} mm) '
                          f'couvre les besoins de la culture. Aucune irrigation supplémentaire nécessaire pour le moment.',
            'quantite_recommandee': '0 mm',
            'priorite': 'faible',
            'parametres_utilises': parametres_utilises.copy(),
        })

    # 6. Conseils basés sur la température élevée
    if temperature_max and temperature_max > 35:
        conseils.append({
            'type': 'irrigation_rafraichissement',
            'titre': 'Température élevée - Irrigation de rafraîchissement',
            'description': f'Température maximale élevée ({temperature_max:.1f}°C). '
                          f'Irrigation légère recommandée pour rafraîchir les cultures et réduire le stress thermique.',
            'quantite_recommandee': '2-3 mm',
            'priorite': 'moyenne',
            'parametres_utilises': parametres_utilises.copy(),
        })

    # 7. Conseils basés sur l'humidité de l'air
    if humidite and humidite < 40:
        conseils.append({
            'type': 'irrigation_humidite',
            'titre': 'Air sec - Irrigation recommandée',
            'description': f'Humidité relative faible ({humidite:.0f}%). '
                          f'L\'évapotranspiration est élevée. Irrigation recommandée pour compenser les pertes d\'eau.',
            'quantite_recommandee': '3-5 mm',
            'priorite': 'moyenne',
            'parametres_utilises': parametres_utilises.copy(),
        })

    # 8. Analyse des prévisions à 48h
    if len(previsions) >= 16:  # 16 * 3h = 48h
        pluviometrie_48h = sum(
            p.get('pluviometrie', 0) or 0 for p in previsions[:16]
        )
        besoin_eau_48h = besoin_eau * 2
        deficit_48h = besoin_eau_48h - pluviometrie_48h

        if deficit_48h > 10:
            conseils.append({
                'type': 'planification_irrigation',
                'titre': 'Planification irrigation sur 48h',
                'description': f'Sur les 48 prochaines heures, le déficit hydrique prévu est de {deficit_48h:.1f} mm. '
                              f'Planifier une irrigation de {deficit_48h:.1f} mm répartie sur 2 jours.',
                'quantite_recommandee': f'{deficit_48h:.1f} mm',
                'priorite': 'moyenne',
                'parametres_utilises': {
                    **parametres_utilises,
                    'pluviometrie_prevue_48h': pluviometrie_48h,
                    'deficit_hydrique_48h': deficit_48h,
                },
            })

    # Si aucun conseil généré, ajouter un message informatif
    if not conseils:
        conseils.append({
            'type': 'information',
            'titre': 'Données météo insuffisantes',
            'description': 'Les données météo disponibles ne permettent pas de générer des conseils d\'irrigation précis. '
                          'Veuillez vérifier que les coordonnées GPS de l\'exploitation sont correctes.',
            'quantite_recommandee': 'N/A',
            'priorite': 'faible',
            'parametres_utilises': parametres_utilises,
        })

    return conseils

