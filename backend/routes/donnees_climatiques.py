"""
Routes pour la gestion des données climatiques
"""
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime
from database import db
from models.donnee_climatique import DonneeClimatique
from models.exploitation import Exploitation
from utils.historique import log_action

donnees_climatiques_bp = Blueprint('donnees_climatiques', __name__)

@donnees_climatiques_bp.route('', methods=['GET'])
@jwt_required()
def get_donnees_climatiques():
    """Liste toutes les données climatiques"""
    try:
        exploitation_id = request.args.get('exploitation_id')
        
        query = DonneeClimatique.query
        if exploitation_id:
            query = query.filter_by(exploitation_id=exploitation_id)
        
        donnees = query.all()
        return jsonify([d.to_dict() for d in donnees]), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@donnees_climatiques_bp.route('', methods=['POST'])
@jwt_required()
def create_donnee_climatique():
    """Créer une nouvelle donnée climatique"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data.get('date_debut') or not data.get('date_fin') or not data.get('exploitation_id'):
            return jsonify({'error': 'date_debut, date_fin et exploitation_id sont requis'}), 400
        
        # Vérifier que l'exploitation existe
        exploitation = Exploitation.query.get(data['exploitation_id'])
        if not exploitation:
            return jsonify({'error': 'Exploitation non trouvée'}), 404
        
        date_debut = datetime.strptime(data['date_debut'], '%Y-%m-%d').date()
        date_fin = datetime.strptime(data['date_fin'], '%Y-%m-%d').date()
        
        donnee = DonneeClimatique(
            date_debut=date_debut,
            date_fin=date_fin,
            temperature_min=data.get('temperature_min'),
            temperature_max=data.get('temperature_max'),
            pluviometrie=data.get('pluviometrie'),
            periode_observée=data.get('periode_observée'),
            exploitation_id=data['exploitation_id']
        )
        
        db.session.add(donnee)
        db.session.commit()
        
        log_action(user_id, 'create', 'donnee_climatique', donnee.id, {'exploitation_id': data['exploitation_id']})
        
        return jsonify({
            'message': 'Donnée climatique créée avec succès',
            'donnee': donnee.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@donnees_climatiques_bp.route('/<int:donnee_id>', methods=['GET'])
@jwt_required()
def get_donnee_climatique(donnee_id):
    """Récupérer une donnée climatique par ID"""
    try:
        donnee = DonneeClimatique.query.get(donnee_id)
        if not donnee:
            return jsonify({'error': 'Donnée climatique non trouvée'}), 404
        return jsonify(donnee.to_dict()), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@donnees_climatiques_bp.route('/<int:donnee_id>', methods=['PUT'])
@jwt_required()
def update_donnee_climatique(donnee_id):
    """Mettre à jour une donnée climatique"""
    try:
        user_id = get_jwt_identity()
        donnee = DonneeClimatique.query.get(donnee_id)
        
        if not donnee:
            return jsonify({'error': 'Donnée climatique non trouvée'}), 404
        
        data = request.get_json()
        
        if 'date_debut' in data:
            donnee.date_debut = datetime.strptime(data['date_debut'], '%Y-%m-%d').date()
        if 'date_fin' in data:
            donnee.date_fin = datetime.strptime(data['date_fin'], '%Y-%m-%d').date()
        if 'temperature_min' in data:
            donnee.temperature_min = data['temperature_min']
        if 'temperature_max' in data:
            donnee.temperature_max = data['temperature_max']
        if 'pluviometrie' in data:
            donnee.pluviometrie = data['pluviometrie']
        if 'periode_observée' in data:
            donnee.periode_observée = data['periode_observée']
        
        db.session.commit()
        
        log_action(user_id, 'update', 'donnee_climatique', donnee_id, data)
        
        return jsonify({
            'message': 'Donnée climatique mise à jour avec succès',
            'donnee': donnee.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@donnees_climatiques_bp.route('/<int:donnee_id>', methods=['DELETE'])
@jwt_required()
def delete_donnee_climatique(donnee_id):
    """Supprimer une donnée climatique"""
    try:
        user_id = get_jwt_identity()
        donnee = DonneeClimatique.query.get(donnee_id)
        
        if not donnee:
            return jsonify({'error': 'Donnée climatique non trouvée'}), 404
        
        db.session.delete(donnee)
        db.session.commit()
        
        log_action(user_id, 'delete', 'donnee_climatique', donnee_id, {})
        
        return jsonify({'message': 'Donnée climatique supprimée avec succès'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500




