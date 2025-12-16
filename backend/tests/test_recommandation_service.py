"""
Tests unitaires pour le service de recommandations
"""
import unittest
from datetime import datetime, timedelta
from app import app, db
from models.user import User, Role
from models.exploitation import Exploitation
from models.analyse_sol import AnalyseSol
from models.donnee_climatique import DonneeClimatique
from models.intrant import Intrant
from services.recommandation_service import generate_recommandations


class TestRecommandationService(unittest.TestCase):
    """Tests pour le service de génération de recommandations"""

    def setUp(self):
        """Configuration avant chaque test"""
        app.config['TESTING'] = True
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
        app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
        self.app = app.test_client()
        with app.app_context():
            db.create_all()
            self._create_test_data()

    def tearDown(self):
        """Nettoyage après chaque test"""
        with app.app_context():
            db.session.remove()
            db.drop_all()

    def _create_test_data(self):
        """Créer des données de test"""
        with app.app_context():
            # Créer un rôle et un utilisateur
            role = Role(nom='Agriculteur')
            db.session.add(role)
            db.session.commit()

            user = User(
                username='testuser',
                email='test@example.com',
                role_id=role.id
            )
            user.set_password('password123')
            db.session.add(user)
            db.session.commit()

            # Créer une exploitation
            self.exploitation = Exploitation(
                nom='Ma Ferme',
                superficie_totale=10.5,
                proprietaire_id=user.id
            )
            db.session.add(self.exploitation)
            db.session.commit()

    def test_generate_recommandations_with_acidic_soil(self):
        """Test génération de recommandations pour sol acide"""
        with app.app_context():
            role = Role.query.first()
            user = User.query.first()

            # Créer une analyse avec pH acide
            analyse = AnalyseSol(
                date_prelevement=datetime.now().date(),
                ph=5.5,  # Acide (< 6.0)
                exploitation_id=self.exploitation.id,
                technicien_id=user.id
            )
            db.session.add(analyse)
            db.session.commit()

            recommandations = generate_recommandations(self.exploitation.id)

            self.assertGreater(len(recommandations), 0)
            # Vérifier qu'il y a une recommandation pour le pH
            ph_recommendations = [r for r in recommandations if 'acide' in r['titre'].lower() or 'ph' in r['titre'].lower()]
            self.assertGreater(len(ph_recommendations), 0)

    def test_generate_recommandations_with_low_nitrogen(self):
        """Test génération de recommandations pour carence en azote"""
        with app.app_context():
            user = User.query.first()

            # Créer une analyse avec faible azote
            analyse = AnalyseSol(
                date_prelevement=datetime.now().date(),
                azote_n=10.0,  # Faible (< 20)
                phosphore_p=15.0,
                potassium_k=150.0,
                exploitation_id=self.exploitation.id,
                technicien_id=user.id
            )
            db.session.add(analyse)
            db.session.commit()

            recommandations = generate_recommandations(self.exploitation.id)

            self.assertGreater(len(recommandations), 0)
            # Vérifier qu'il y a une recommandation pour l'azote
            azote_recommendations = [r for r in recommandations if 'azote' in r['titre'].lower() or 'nitrogen' in r['description'].lower()]
            self.assertGreater(len(azote_recommendations), 0)

    def test_generate_recommandations_with_low_rainfall(self):
        """Test génération de recommandations pour faible pluviométrie"""
        with app.app_context():
            # Créer une donnée climatique avec faible pluviométrie
            donnee = DonneeClimatique(
                date_debut=datetime.now().date(),
                date_fin=(datetime.now() + timedelta(days=7)).date(),
                pluviometrie=30.0,  # Faible (< 50)
                exploitation_id=self.exploitation.id
            )
            db.session.add(donnee)
            db.session.commit()

            recommandations = generate_recommandations(self.exploitation.id)

            self.assertGreater(len(recommandations), 0)
            # Vérifier qu'il y a une recommandation d'irrigation
            irrigation_recommendations = [r for r in recommandations if 'irrigation' in r['type_recommandation'].lower()]
            self.assertGreater(len(irrigation_recommendations), 0)

    def test_generate_recommandations_with_no_data(self):
        """Test génération sans données"""
        with app.app_context():
            recommandations = generate_recommandations(self.exploitation.id)

            # Devrait retourner une recommandation informative
            self.assertGreater(len(recommandations), 0)
            info_recommendations = [r for r in recommandations if 'insuffisantes' in r['titre'].lower() or 'données' in r['titre'].lower()]
            self.assertGreater(len(info_recommendations), 0)

    def test_recommendations_include_parameters(self):
        """Test que les recommandations incluent les paramètres utilisés"""
        with app.app_context():
            user = User.query.first()

            analyse = AnalyseSol(
                date_prelevement=datetime.now().date(),
                ph=5.5,
                azote_n=10.0,
                exploitation_id=self.exploitation.id,
                technicien_id=user.id
            )
            db.session.add(analyse)
            db.session.commit()

            recommandations = generate_recommandations(self.exploitation.id)

            for rec in recommandations:
                self.assertIn('parametres_utilises', rec)
                self.assertIsNotNone(rec['parametres_utilises'])


if __name__ == '__main__':
    unittest.main()

