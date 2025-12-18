"""
Routes pour la gestion des recommandations
"""
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import db
from models.recommandation import Recommandation
from models.exploitation import Exploitation
from services.recommandation_service import generate_recommandations
from utils.historique import log_action
import json

recommandations_bp = Blueprint('recommandations', __name__)

@recommandations_bp.route('', methods=['GET'])
@jwt_required()
def get_recommandations():
    """Liste toutes les recommandations"""
    try:
        exploitation_id = request.args.get('exploitation_id')
        parcelle_id = request.args.get('parcelle_id')
        
        query = Recommandation.query
        
        if exploitation_id:
            query = query.filter_by(exploitation_id=exploitation_id)
        if parcelle_id:
            query = query.filter_by(parcelle_id=parcelle_id)
        
        recommandations = query.all()
        return jsonify([r.to_dict() for r in recommandations]), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@recommandations_bp.route('/generate/<int:exploitation_id>', methods=['POST'])
@jwt_required()
def generate_recommandations_for_exploitation(exploitation_id):
    """Générer des recommandations pour une exploitation"""
    try:
        user_id = get_jwt_identity()
        
        # Vérifier que l'exploitation existe
        exploitation = Exploitation.query.get(exploitation_id)
        if not exploitation:
            return jsonify({'error': 'Exploitation non trouvée'}), 404
        
        # Générer les recommandations basées sur les données réelles
        recommandations = generate_recommandations(exploitation_id)
        
        # Sauvegarder les recommandations
        created_recommendations = []
        for rec_data in recommandations:
            recommandation = Recommandation(
                type_recommandation=rec_data['type_recommandation'],
                titre=rec_data['titre'],
                description=rec_data['description'],
                parametres_utilises=json.dumps(rec_data.get('parametres_utilises', {})),
                priorite=rec_data.get('priorite', 'moyenne'),
                exploitation_id=exploitation_id,
                parcelle_id=rec_data.get('parcelle_id')
            )
            db.session.add(recommandation)
            created_recommendations.append(recommandation)
        
        db.session.commit()
        
        log_action(user_id, 'generate', 'recommandation', exploitation_id, {'count': len(recommandations)})
        
        return jsonify({
            'message': f'{len(recommandations)} recommandations générées',
            'recommandations': [r.to_dict() for r in created_recommendations]
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@recommandations_bp.route('/<int:recommandation_id>', methods=['GET'])
@jwt_required()
def get_recommandation(recommandation_id):
    """Récupérer une recommandation par ID"""
    try:
        recommandation = Recommandation.query.get(recommandation_id)
        if not recommandation:
            return jsonify({'error': 'Recommandation non trouvée'}), 404
        return jsonify(recommandation.to_dict()), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@recommandations_bp.route('/<int:recommandation_id>/status', methods=['PUT'])
@jwt_required()
def update_recommandation_status(recommandation_id):
    """Mettre à jour le statut d'une recommandation"""
    try:
        user_id = get_jwt_identity()
        recommandation = Recommandation.query.get(recommandation_id)
        
        if not recommandation:
            return jsonify({'error': 'Recommandation non trouvée'}), 404
        
        data = request.get_json()
        if 'statut' in data:
            recommandation.statut = data['statut']
        
        db.session.commit()
        
        log_action(user_id, 'update', 'recommandation', recommandation_id, {'statut': data.get('statut')})
        
        return jsonify({
            'message': 'Statut de la recommandation mis à jour',
            'recommandation': recommandation.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@recommandations_bp.route('/<int:recommandation_id>', methods=['DELETE'])
@jwt_required()
def delete_recommandation(recommandation_id):
    """Supprimer une recommandation"""
    try:
        user_id = get_jwt_identity()
        recommandation = Recommandation.query.get(recommandation_id)
        
        if not recommandation:
            return jsonify({'error': 'Recommandation non trouvée'}), 404
        
        db.session.delete(recommandation)
        db.session.commit()
        
        log_action(user_id, 'delete', 'recommandation', recommandation_id, {})
        
        return jsonify({'message': 'Recommandation supprimée avec succès'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500




