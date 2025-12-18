"""
Tests unitaires pour les validateurs
"""
import unittest
from utils.validators import (
    validate_user_data,
    validate_exploitation_data,
    validate_analyse_sol_data,
    validate_intrant_data
)


class TestValidators(unittest.TestCase):
    """Tests pour les fonctions de validation"""

    def test_validate_user_data_valid(self):
        """Test validation d'un utilisateur valide"""
        data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'password123',
            'role_id': 1
        }
        errors = validate_user_data(data)
        self.assertEqual(len(errors), 0)

    def test_validate_user_data_missing_fields(self):
        """Test validation avec champs manquants"""
        data = {
            'username': 'testuser',
            # email manquant
            'password': 'password123',
            'role_id': 1
        }
        errors = validate_user_data(data)
        self.assertGreater(len(errors), 0)
        self.assertIn('email', str(errors).lower())

    def test_validate_user_data_short_password(self):
        """Test validation avec mot de passe trop court"""
        data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': '12345',  # Trop court
            'role_id': 1
        }
        errors = validate_user_data(data)
        self.assertGreater(len(errors), 0)

    def test_validate_exploitation_data_valid(self):
        """Test validation d'une exploitation valide"""
        data = {
            'nom': 'Ma Ferme',
            'superficie_totale': 10.5
        }
        errors = validate_exploitation_data(data)
        self.assertEqual(len(errors), 0)

    def test_validate_exploitation_data_invalid_superficie(self):
        """Test validation avec superficie invalide"""
        data = {
            'nom': 'Ma Ferme',
            'superficie_totale': -5  # Négative
        }
        errors = validate_exploitation_data(data)
        self.assertGreater(len(errors), 0)

    def test_validate_exploitation_data_invalid_latitude(self):
        """Test validation avec latitude invalide"""
        data = {
            'nom': 'Ma Ferme',
            'superficie_totale': 10.5,
            'latitude': 100  # Invalide (> 90)
        }
        errors = validate_exploitation_data(data)
        self.assertGreater(len(errors), 0)

    def test_validate_analyse_sol_data_valid(self):
        """Test validation d'une analyse de sol valide"""
        data = {
            'date_prelevement': '2024-01-15',
            'exploitation_id': 1,
            'ph': 6.5,
            'azote_n': 20.0,
            'phosphore_p': 15.0,
            'potassium_k': 180.0
        }
        errors = validate_analyse_sol_data(data)
        self.assertEqual(len(errors), 0)

    def test_validate_analyse_sol_data_invalid_ph(self):
        """Test validation avec pH invalide"""
        data = {
            'date_prelevement': '2024-01-15',
            'exploitation_id': 1,
            'ph': 15  # Invalide (> 14)
        }
        errors = validate_analyse_sol_data(data)
        self.assertGreater(len(errors), 0)

    def test_validate_analyse_sol_data_invalid_humidite(self):
        """Test validation avec humidité invalide"""
        data = {
            'date_prelevement': '2024-01-15',
            'exploitation_id': 1,
            'humidite': 150  # Invalide (> 100%)
        }
        errors = validate_analyse_sol_data(data)
        self.assertGreater(len(errors), 0)

    def test_validate_intrant_data_valid(self):
        """Test validation d'un intrant valide"""
        data = {
            'type_intrant': 'Engrais',
            'quantite': 50.0,
            'date_application': '2024-01-15',
            'exploitation_id': 1
        }
        errors = validate_intrant_data(data)
        self.assertEqual(len(errors), 0)

    def test_validate_intrant_data_missing_fields(self):
        """Test validation avec champs manquants"""
        data = {
            'type_intrant': 'Engrais',
            # quantite manquante
            'date_application': '2024-01-15',
            'exploitation_id': 1
        }
        errors = validate_intrant_data(data)
        self.assertGreater(len(errors), 0)

    def test_validate_intrant_data_invalid_quantite(self):
        """Test validation avec quantité invalide"""
        data = {
            'type_intrant': 'Engrais',
            'quantite': -10,  # Négative
            'date_application': '2024-01-15',
            'exploitation_id': 1
        }
        errors = validate_intrant_data(data)
        self.assertGreater(len(errors), 0)


if __name__ == '__main__':
    unittest.main()




