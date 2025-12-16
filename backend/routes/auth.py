"""
Routes d'authentification
"""
from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from database import db
from models.user import User, Role
from utils.validators import validate_user_data
from utils.historique import log_action

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/roles', methods=['GET'])
def get_public_roles():
    """Liste tous les rôles disponibles pour l'inscription (endpoint public)"""
    try:
        roles = Role.query.all()
        return jsonify([role.to_dict() for role in roles]), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/register', methods=['POST'])
def register():
    """Enregistrement d'un nouvel utilisateur"""
    try:
        data = request.get_json()
        
        # Validation des données
        errors = validate_user_data(data)
        if errors:
            return jsonify({'errors': errors}), 400
        
        # Vérifier si l'utilisateur existe déjà
        if User.query.filter_by(username=data['username']).first():
            return jsonify({'error': 'Username déjà utilisé'}), 400
        
        if User.query.filter_by(email=data['email']).first():
            return jsonify({'error': 'Email déjà utilisé'}), 400
        
        # Vérifier que le rôle existe
        role = Role.query.get(data['role_id'])
        if not role:
            return jsonify({'error': 'Rôle invalide'}), 400
        
        # Créer l'utilisateur
        user = User(
            username=data['username'],
            email=data['email'],
            nom=data.get('nom'),
            prenom=data.get('prenom'),
            telephone=data.get('telephone'),
            zone_intervention=data.get('zone_intervention'),
            role_id=data['role_id']
        )
        user.set_password(data['password'])
        
        db.session.add(user)
        db.session.commit()
        
        log_action(user.id, 'create', 'user', user.id, {'username': user.username})
        
        return jsonify({
            'message': 'Utilisateur créé avec succès',
            'user': user.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    """Authentification de l'utilisateur"""
    try:
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')
        
        if not username or not password:
            return jsonify({'error': 'Username et password requis'}), 400
        
        user = User.query.filter_by(username=username).first()
        
        if not user or not user.check_password(password):
            return jsonify({'error': 'Identifiants invalides'}), 401
        
        if not user.is_active:
            return jsonify({'error': 'Compte désactivé'}), 403
        
        access_token = create_access_token(identity=user.id)
        
        log_action(user.id, 'login', 'auth', None, {'username': user.username})
        
        return jsonify({
            'access_token': access_token,
            'user': user.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/me', methods=['GET'])
@jwt_required()
def get_current_user():
    """Récupérer les informations de l'utilisateur connecté"""
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        if not user:
            return jsonify({'error': 'Utilisateur non trouvé'}), 404
        
        return jsonify(user.to_dict()), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

