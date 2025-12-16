"""
Routes pour la gestion des parcelles
"""
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import db
from models.exploitation import Exploitation, Parcelle
from utils.historique import log_action

parcelles_bp = Blueprint('parcelles', __name__)

@parcelles_bp.route('', methods=['GET'])
@jwt_required()
def get_parcelles():
    """Liste toutes les parcelles d'une exploitation"""
    try:
        exploitation_id = request.args.get('exploitation_id')
        if not exploitation_id:
            return jsonify({'error': 'exploitation_id requis'}), 400
        
        parcelles = Parcelle.query.filter_by(exploitation_id=exploitation_id).all()
        return jsonify([p.to_dict() for p in parcelles]), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@parcelles_bp.route('', methods=['POST'])
@jwt_required()
def create_parcelle():
    """Créer une nouvelle parcelle"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data.get('nom') or not data.get('superficie') or not data.get('exploitation_id'):
            return jsonify({'error': 'Nom, superficie et exploitation_id sont requis'}), 400
        
        # Vérifier que l'exploitation existe et appartient à l'utilisateur
        exploitation = Exploitation.query.get(data['exploitation_id'])
        if not exploitation:
            return jsonify({'error': 'Exploitation non trouvée'}), 404
        
        if exploitation.proprietaire_id != user_id:
            return jsonify({'error': 'Non autorisé'}), 403
        
        parcelle = Parcelle(
            nom=data['nom'],
            superficie=data['superficie'],
            type_culture=data.get('type_culture'),
            exploitation_id=data['exploitation_id']
        )
        
        db.session.add(parcelle)
        db.session.commit()
        
        log_action(user_id, 'create', 'parcelle', parcelle.id, {'nom': parcelle.nom})
        
        return jsonify({
            'message': 'Parcelle créée avec succès',
            'parcelle': parcelle.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@parcelles_bp.route('/<int:parcelle_id>', methods=['GET'])
@jwt_required()
def get_parcelle(parcelle_id):
    """Récupérer une parcelle par ID"""
    try:
        parcelle = Parcelle.query.get(parcelle_id)
        if not parcelle:
            return jsonify({'error': 'Parcelle non trouvée'}), 404
        return jsonify(parcelle.to_dict()), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@parcelles_bp.route('/<int:parcelle_id>', methods=['PUT'])
@jwt_required()
def update_parcelle(parcelle_id):
    """Mettre à jour une parcelle"""
    try:
        user_id = get_jwt_identity()
        parcelle = Parcelle.query.get(parcelle_id)
        
        if not parcelle:
            return jsonify({'error': 'Parcelle non trouvée'}), 404
        
        # Vérifier les permissions
        exploitation = Exploitation.query.get(parcelle.exploitation_id)
        if exploitation.proprietaire_id != user_id:
            return jsonify({'error': 'Non autorisé'}), 403
        
        data = request.get_json()
        
        if 'nom' in data:
            parcelle.nom = data['nom']
        if 'superficie' in data:
            parcelle.superficie = data['superficie']
        if 'type_culture' in data:
            parcelle.type_culture = data['type_culture']
        
        db.session.commit()
        
        log_action(user_id, 'update', 'parcelle', parcelle_id, data)
        
        return jsonify({
            'message': 'Parcelle mise à jour avec succès',
            'parcelle': parcelle.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@parcelles_bp.route('/<int:parcelle_id>', methods=['DELETE'])
@jwt_required()
def delete_parcelle(parcelle_id):
    """Supprimer une parcelle"""
    try:
        user_id = get_jwt_identity()
        parcelle = Parcelle.query.get(parcelle_id)
        
        if not parcelle:
            return jsonify({'error': 'Parcelle non trouvée'}), 404
        
        exploitation = Exploitation.query.get(parcelle.exploitation_id)
        if exploitation.proprietaire_id != user_id:
            return jsonify({'error': 'Non autorisé'}), 403
        
        db.session.delete(parcelle)
        db.session.commit()
        
        log_action(user_id, 'delete', 'parcelle', parcelle_id, {'nom': parcelle.nom})
        
        return jsonify({'message': 'Parcelle supprimée avec succès'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

