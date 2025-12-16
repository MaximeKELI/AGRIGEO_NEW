"""
Routes pour la gestion des intrants agricoles
"""
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime
from database import db
from models.intrant import Intrant
from models.exploitation import Exploitation
from utils.historique import log_action
from utils.validators import validate_intrant_data

intrants_bp = Blueprint('intrants', __name__)

@intrants_bp.route('', methods=['GET'])
@jwt_required()
def get_intrants():
    """Liste tous les intrants"""
    try:
        exploitation_id = request.args.get('exploitation_id')
        parcelle_id = request.args.get('parcelle_id')
        
        query = Intrant.query
        
        if exploitation_id:
            query = query.filter_by(exploitation_id=exploitation_id)
        if parcelle_id:
            query = query.filter_by(parcelle_id=parcelle_id)
        
        intrants = query.all()
        return jsonify([i.to_dict() for i in intrants]), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@intrants_bp.route('', methods=['POST'])
@jwt_required()
def create_intrant():
    """Créer un nouvel intrant"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validation des données
        errors = validate_intrant_data(data)
        if errors:
            return jsonify({'errors': errors}), 400
        
        # Vérifier que l'exploitation existe
        exploitation = Exploitation.query.get(data['exploitation_id'])
        if not exploitation:
            return jsonify({'error': 'Exploitation non trouvée'}), 404
        
        date_application = datetime.strptime(data['date_application'], '%Y-%m-%d').date()
        
        intrant = Intrant(
            type_intrant=data['type_intrant'],
            nom_commercial=data.get('nom_commercial'),
            quantite=data['quantite'],
            unite=data.get('unite', 'kg'),
            date_application=date_application,
            culture_concernée=data.get('culture_concernée'),
            exploitation_id=data['exploitation_id'],
            parcelle_id=data.get('parcelle_id')
        )
        
        db.session.add(intrant)
        db.session.commit()
        
        log_action(user_id, 'create', 'intrant', intrant.id, {'type': data['type_intrant']})
        
        return jsonify({
            'message': 'Intrant créé avec succès',
            'intrant': intrant.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@intrants_bp.route('/<int:intrant_id>', methods=['GET'])
@jwt_required()
def get_intrant(intrant_id):
    """Récupérer un intrant par ID"""
    try:
        intrant = Intrant.query.get(intrant_id)
        if not intrant:
            return jsonify({'error': 'Intrant non trouvé'}), 404
        return jsonify(intrant.to_dict()), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@intrants_bp.route('/<int:intrant_id>', methods=['PUT'])
@jwt_required()
def update_intrant(intrant_id):
    """Mettre à jour un intrant"""
    try:
        user_id = get_jwt_identity()
        intrant = Intrant.query.get(intrant_id)
        
        if not intrant:
            return jsonify({'error': 'Intrant non trouvé'}), 404
        
        data = request.get_json()
        
        if 'type_intrant' in data:
            intrant.type_intrant = data['type_intrant']
        if 'nom_commercial' in data:
            intrant.nom_commercial = data['nom_commercial']
        if 'quantite' in data:
            intrant.quantite = data['quantite']
        if 'unite' in data:
            intrant.unite = data['unite']
        if 'date_application' in data:
            intrant.date_application = datetime.strptime(data['date_application'], '%Y-%m-%d').date()
        if 'culture_concernée' in data:
            intrant.culture_concernée = data['culture_concernée']
        
        db.session.commit()
        
        log_action(user_id, 'update', 'intrant', intrant_id, data)
        
        return jsonify({
            'message': 'Intrant mis à jour avec succès',
            'intrant': intrant.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@intrants_bp.route('/<int:intrant_id>', methods=['DELETE'])
@jwt_required()
def delete_intrant(intrant_id):
    """Supprimer un intrant"""
    try:
        user_id = get_jwt_identity()
        intrant = Intrant.query.get(intrant_id)
        
        if not intrant:
            return jsonify({'error': 'Intrant non trouvé'}), 404
        
        db.session.delete(intrant)
        db.session.commit()
        
        log_action(user_id, 'delete', 'intrant', intrant_id, {})
        
        return jsonify({'message': 'Intrant supprimé avec succès'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

