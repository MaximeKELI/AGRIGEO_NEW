"""
Tests unitaires pour les modèles SQLAlchemy
"""
import unittest
from datetime import datetime
from app import app, db
from models.user import User, Role
from models.exploitation import Exploitation, Parcelle
from models.analyse_sol import AnalyseSol
from models.intrant import Intrant
from werkzeug.security import check_password_hash


class TestModels(unittest.TestCase):
    """Tests pour les modèles de données"""

    def setUp(self):
        """Configuration avant chaque test"""
        app.config['TESTING'] = True
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
        app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
        self.app = app.test_client()
        with app.app_context():
            db.create_all()

    def tearDown(self):
        """Nettoyage après chaque test"""
        with app.app_context():
            db.session.remove()
            db.drop_all()

    def test_role_creation(self):
        """Test création d'un rôle"""
        with app.app_context():
            role = Role(
                nom='Agriculteur',
                description='Producteur agricole',
                permissions='{"read": true, "write": true}'
            )
            db.session.add(role)
            db.session.commit()

            self.assertEqual(role.nom, 'Agriculteur')
            self.assertIsNotNone(role.id)
            self.assertIsNotNone(role.created_at)

    def test_user_creation(self):
        """Test création d'un utilisateur"""
        with app.app_context():
            # Créer un rôle d'abord
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

            self.assertEqual(user.username, 'testuser')
            self.assertTrue(user.check_password('password123'))
            self.assertFalse(user.check_password('wrongpassword'))
            self.assertIsNotNone(user.password_hash)

    def test_exploitation_creation(self):
        """Test création d'une exploitation"""
        with app.app_context():
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

            exploitation = Exploitation(
                nom='Ma Ferme',
                superficie_totale=10.5,
                localisation_texte='Lomé, Togo',
                latitude=6.1375,
                longitude=1.2123,
                proprietaire_id=user.id
            )
            db.session.add(exploitation)
            db.session.commit()

            self.assertEqual(exploitation.nom, 'Ma Ferme')
            self.assertEqual(exploitation.superficie_totale, 10.5)
            self.assertEqual(exploitation.proprietaire_id, user.id)
            self.assertIsNotNone(exploitation.created_at)

    def test_parcelle_creation(self):
        """Test création d'une parcelle"""
        with app.app_context():
            role = Role(nom='Agriculteur')
            db.session.add(role)
            db.session.commit()

            user = User(username='testuser', email='test@example.com', role_id=role.id)
            user.set_password('password123')
            db.session.add(user)
            db.session.commit()

            exploitation = Exploitation(
                nom='Ma Ferme',
                superficie_totale=10.5,
                proprietaire_id=user.id
            )
            db.session.add(exploitation)
            db.session.commit()

            parcelle = Parcelle(
                nom='Parcelle Nord',
                superficie=2.5,
                type_culture='Maïs',
                exploitation_id=exploitation.id
            )
            db.session.add(parcelle)
            db.session.commit()

            self.assertEqual(parcelle.nom, 'Parcelle Nord')
            self.assertEqual(parcelle.superficie, 2.5)
            self.assertEqual(parcelle.exploitation_id, exploitation.id)

    def test_analyse_sol_creation(self):
        """Test création d'une analyse de sol"""
        with app.app_context():
            role = Role(nom='Technicien')
            db.session.add(role)
            db.session.commit()

            user = User(username='tech', email='tech@example.com', role_id=role.id)
            user.set_password('password123')
            db.session.add(user)
            db.session.commit()

            exploitation = Exploitation(
                nom='Ma Ferme',
                superficie_totale=10.5,
                proprietaire_id=user.id
            )
            db.session.add(exploitation)
            db.session.commit()

            analyse = AnalyseSol(
                date_prelevement=datetime.now().date(),
                ph=6.5,
                humidite=25.0,
                texture='Argileux',
                azote_n=20.5,
                phosphore_p=15.2,
                potassium_k=180.0,
                observations='Sol en bon état',
                exploitation_id=exploitation.id,
                technicien_id=user.id
            )
            db.session.add(analyse)
            db.session.commit()

            self.assertEqual(analyse.ph, 6.5)
            self.assertEqual(analyse.azote_n, 20.5)
            self.assertEqual(analyse.exploitation_id, exploitation.id)

    def test_intrant_creation(self):
        """Test création d'un intrant"""
        with app.app_context():
            role = Role(nom='Agriculteur')
            db.session.add(role)
            db.session.commit()

            user = User(username='testuser', email='test@example.com', role_id=role.id)
            user.set_password('password123')
            db.session.add(user)
            db.session.commit()

            exploitation = Exploitation(
                nom='Ma Ferme',
                superficie_totale=10.5,
                proprietaire_id=user.id
            )
            db.session.add(exploitation)
            db.session.commit()

            intrant = Intrant(
                type_intrant='Engrais',
                nom_commercial='NPK 15-15-15',
                quantite=50.0,
                unite='kg',
                date_application=datetime.now().date(),
                culture_concernée='Maïs',
                exploitation_id=exploitation.id
            )
            db.session.add(intrant)
            db.session.commit()

            self.assertEqual(intrant.type_intrant, 'Engrais')
            self.assertEqual(intrant.quantite, 50.0)
            self.assertEqual(intrant.exploitation_id, exploitation.id)


if __name__ == '__main__':
    unittest.main()




