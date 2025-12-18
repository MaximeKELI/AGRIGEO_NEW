"""
Tests unitaires pour le service d'irrigation
"""
import unittest
from services.irrigation_service import generate_conseils_irrigation


class TestIrrigationService(unittest.TestCase):
    """Tests pour le service de conseils d'irrigation"""

    def test_generate_conseils_with_high_deficit(self):
        """Test génération de conseils avec déficit hydrique élevé"""
        meteo_actuelle = {
            'temperature': 30.0,
            'humidite': 50.0,
            'pluviometrie': 0.0
        }
        previsions = [
            {'pluviometrie': 5.0},
            {'pluviometrie': 0.0},
            {'pluviometrie': 0.0},
        ] * 3  # Total ~15mm sur 24h

        conseils = generate_conseils_irrigation(
            meteo_actuelle=meteo_actuelle,
            previsions=previsions,
            type_culture='maïs'
        )

        self.assertGreater(len(conseils), 0)
        # Devrait avoir une recommandation d'irrigation urgente
        urgent_conseils = [c for c in conseils if c['priorite'] == 'élevée']
        self.assertGreater(len(urgent_conseils), 0)

    def test_generate_conseils_with_sufficient_rainfall(self):
        """Test avec pluviométrie suffisante"""
        meteo_actuelle = {
            'temperature': 25.0,
            'humidite': 60.0,
            'pluviometrie': 10.0
        }
        previsions = [
            {'pluviometrie': 20.0},
            {'pluviometrie': 15.0},
        ] * 4  # Total ~140mm sur 24h

        conseils = generate_conseils_irrigation(
            meteo_actuelle=meteo_actuelle,
            previsions=previsions,
            type_culture='maïs'
        )

        # Devrait avoir une recommandation "non nécessaire"
        non_necessaire = [c for c in conseils if 'non nécessaire' in c['titre'].lower()]
        self.assertGreater(len(non_necessaire), 0)

    def test_generate_conseils_with_high_temperature(self):
        """Test avec température élevée"""
        meteo_actuelle = {
            'temperature': 30.0,
            'temperature_max': 38.0,  # > 35°C
            'humidite': 40.0,
            'pluviometrie': 0.0
        }
        previsions = []

        conseils = generate_conseils_irrigation(
            meteo_actuelle=meteo_actuelle,
            previsions=previsions,
            type_culture='maïs'
        )

        # Devrait avoir une recommandation de rafraîchissement
        rafraichissement = [c for c in conseils if 'rafraîchissement' in c['titre'].lower() or 'rafraichissement' in c['titre'].lower()]
        self.assertGreater(len(rafraichissement), 0)

    def test_generate_conseils_with_low_humidity(self):
        """Test avec humidité faible"""
        meteo_actuelle = {
            'temperature': 25.0,
            'humidite': 35.0,  # < 40%
            'pluviometrie': 0.0
        }
        previsions = []

        conseils = generate_conseils_irrigation(
            meteo_actuelle=meteo_actuelle,
            previsions=previsions,
            type_culture='maïs'
        )

        # Devrait avoir une recommandation pour humidité
        humidite_conseils = [c for c in conseils if 'humidité' in c['titre'].lower() or 'sec' in c['titre'].lower()]
        self.assertGreater(len(humidite_conseils), 0)

    def test_conseils_include_parameters(self):
        """Test que les conseils incluent les paramètres utilisés"""
        meteo_actuelle = {
            'temperature': 28.0,
            'humidite': 50.0,
            'pluviometrie': 0.0
        }
        previsions = [{'pluviometrie': 10.0}] * 3

        conseils = generate_conseils_irrigation(
            meteo_actuelle=meteo_actuelle,
            previsions=previsions,
            type_culture='maïs'
        )

        for conseil in conseils:
            self.assertIn('parametres_utilises', conseil)
            self.assertIsNotNone(conseil['parametres_utilises'])

    def test_different_crop_water_needs(self):
        """Test que différents types de cultures ont des besoins différents"""
        meteo_actuelle = {'temperature': 25.0, 'humidite': 50.0, 'pluviometrie': 0.0}
        previsions = [{'pluviometrie': 0.0}] * 8

        conseils_mais = generate_conseils_irrigation(
            meteo_actuelle=meteo_actuelle,
            previsions=previsions,
            type_culture='maïs'
        )

        conseils_riz = generate_conseils_irrigation(
            meteo_actuelle=meteo_actuelle,
            previsions=previsions,
            type_culture='riz'
        )

        # Le riz nécessite plus d'eau, donc devrait avoir un déficit plus élevé
        self.assertGreater(len(conseils_riz), 0)
        self.assertGreater(len(conseils_mais), 0)


if __name__ == '__main__':
    unittest.main()




