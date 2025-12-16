"""
AGRIGEO - Backend Flask
Application de gestion intelligente des sols et optimisation des pratiques agricoles
"""
from flask import Flask
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from flask_restful import Api
from flask_swagger_ui import get_swaggerui_blueprint
import os
from dotenv import load_dotenv

from database import db, init_db
from routes.auth import auth_bp
from routes.users import users_bp
from routes.exploitations import exploitations_bp
from routes.parcelles import parcelles_bp
from routes.analyses_sols import analyses_sols_bp
from routes.donnees_climatiques import donnees_climatiques_bp
from routes.intrants import intrants_bp
from routes.recommandations import recommandations_bp

load_dotenv()

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY', 'jwt-secret-key-change-in-production')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = False  # Tokens n'expirent pas (ou configurer selon besoin)
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///agrigeo.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialisation des extensions
db.init_app(app)
CORS(app)
jwt = JWTManager(app)
api = Api(app)

# Configuration Swagger
SWAGGER_URL = '/api/docs'
API_URL = '/static/swagger.json'
swaggerui_blueprint = get_swaggerui_blueprint(
    SWAGGER_URL,
    API_URL,
    config={'app_name': "AGRIGEO API"}
)
app.register_blueprint(swaggerui_blueprint, url_prefix=SWAGGER_URL)

# Enregistrement des blueprints
app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(users_bp, url_prefix='/api/users')
app.register_blueprint(exploitations_bp, url_prefix='/api/exploitations')
app.register_blueprint(parcelles_bp, url_prefix='/api/parcelles')
app.register_blueprint(analyses_sols_bp, url_prefix='/api/analyses-sols')
app.register_blueprint(donnees_climatiques_bp, url_prefix='/api/donnees-climatiques')
app.register_blueprint(intrants_bp, url_prefix='/api/intrants')
app.register_blueprint(recommandations_bp, url_prefix='/api/recommandations')

@app.route('/api/health')
def health_check():
    """Endpoint de vérification de santé de l'API"""
    return {'status': 'ok', 'message': 'AGRIGEO API is running'}, 200

if __name__ == '__main__':
    with app.app_context():
        init_db()
    app.run(debug=True, host='0.0.0.0', port=5000)

