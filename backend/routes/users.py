"""
Routes pour la gestion des utilisateurs
"""
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import db
from models.user import User, Role
from utils.historique import log_action

users_bp = Blueprint('users', __name__)

@users_bp.route('', methods=['GET'])
@jwt_required()
def get_users():
    """Liste tous les utilisateurs"""
    try:
        users = User.query.all()
        return jsonify([user.to_dict() for user in users]), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@users_bp.route('/<int:user_id>', methods=['GET'])
@jwt_required()
def get_user(user_id):
    """Récupérer un utilisateur par ID"""
    try:
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'Utilisateur non trouvé'}), 404
        return jsonify(user.to_dict()), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@users_bp.route('/roles', methods=['GET'])
@jwt_required()
def get_roles():
    """Liste tous les rôles"""
    try:
        roles = Role.query.all()
        return jsonify([role.to_dict() for role in roles]), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@users_bp.route('/roles', methods=['POST'])
@jwt_required()
def create_role():
    """Créer un nouveau rôle"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data.get('nom'):
            return jsonify({'error': 'Le nom du rôle est requis'}), 400
        
        role = Role(
            nom=data['nom'],
            description=data.get('description'),
            permissions=data.get('permissions')
        )
        
        db.session.add(role)
        db.session.commit()
        
        log_action(current_user_id, 'create', 'role', role.id, {'nom': role.nom})
        
        return jsonify({
            'message': 'Rôle créé avec succès',
            'role': role.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500




