"""
Tests unitaires pour les routes API
"""
import unittest
import json
from app import app, db
from models.user import User, Role
from models.exploitation import Exploitation
from flask_jwt_extended import create_access_token


class TestRoutes(unittest.TestCase):
    """Tests pour les routes API"""

    def setUp(self):
        """Configuration avant chaque test"""
        app.config['TESTING'] = True
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
        app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
        app.config['JWT_SECRET_KEY'] = 'test-secret-key'
        self.app = app.test_client()
        with app.app_context():
            db.create_all()
            self._create_test_user()

    def tearDown(self):
        """Nettoyage après chaque test"""
        with app.app_context():
            db.session.remove()
            db.drop_all()

    def _create_test_user(self):
        """Créer un utilisateur de test"""
        with app.app_context():
            role = Role(nom='Agriculteur')
            db.session.add(role)
            db.session.commit()

            self.user = User(
                username='testuser',
                email='test@example.com',
                role_id=role.id
            )
            self.user.set_password('password123')
            db.session.add(self.user)
            db.session.commit()

            # Créer un token JWT pour les tests
            self.token = create_access_token(identity=self.user.id)

    def _get_auth_headers(self):
        """Retourne les headers d'authentification"""
        return {'Authorization': f'Bearer {self.token}'}

    def test_health_check(self):
        """Test endpoint de santé"""
        response = self.app.get('/api/health')
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data)
        self.assertEqual(data['status'], 'ok')

    def test_register_user(self):
        """Test enregistrement d'un utilisateur"""
        data = {
            'username': 'newuser',
            'email': 'newuser@example.com',
            'password': 'password123',
            'role_id': 1
        }
        response = self.app.post(
            '/api/auth/register',
            data=json.dumps(data),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 201)
        response_data = json.loads(response.data)
        self.assertIn('user', response_data)

    def test_login(self):
        """Test connexion"""
        data = {
            'username': 'testuser',
            'password': 'password123'
        }
        response = self.app.post(
            '/api/auth/login',
            data=json.dumps(data),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 200)
        response_data = json.loads(response.data)
        self.assertIn('access_token', response_data)
        self.assertIn('user', response_data)

    def test_login_invalid_credentials(self):
        """Test connexion avec identifiants invalides"""
        data = {
            'username': 'testuser',
            'password': 'wrongpassword'
        }
        response = self.app.post(
            '/api/auth/login',
            data=json.dumps(data),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 401)

    def test_get_current_user(self):
        """Test récupération de l'utilisateur connecté"""
        response = self.app.get(
            '/api/auth/me',
            headers=self._get_auth_headers()
        )
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data)
        self.assertEqual(data['username'], 'testuser')

    def test_create_exploitation(self):
        """Test création d'une exploitation"""
        data = {
            'nom': 'Ma Ferme Test',
            'superficie_totale': 15.5,
            'localisation_texte': 'Lomé, Togo'
        }
        response = self.app.post(
            '/api/exploitations',
            data=json.dumps(data),
            content_type='application/json',
            headers=self._get_auth_headers()
        )
        self.assertEqual(response.status_code, 201)
        response_data = json.loads(response.data)
        self.assertIn('exploitation', response_data)
        self.assertEqual(response_data['exploitation']['nom'], 'Ma Ferme Test')

    def test_create_exploitation_invalid_data(self):
        """Test création avec données invalides"""
        data = {
            'nom': 'Ma Ferme',
            # superficie_totale manquante
        }
        response = self.app.post(
            '/api/exploitations',
            data=json.dumps(data),
            content_type='application/json',
            headers=self._get_auth_headers()
        )
        self.assertEqual(response.status_code, 400)

    def test_get_exploitations(self):
        """Test récupération des exploitations"""
        # Créer une exploitation d'abord
        with app.app_context():
            exploitation = Exploitation(
                nom='Ma Ferme',
                superficie_totale=10.5,
                proprietaire_id=self.user.id
            )
            db.session.add(exploitation)
            db.session.commit()

        response = self.app.get(
            '/api/exploitations',
            headers=self._get_auth_headers()
        )
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data)
        self.assertIsInstance(data, dict)
        self.assertIn('items', data)


if __name__ == '__main__':
    unittest.main()




