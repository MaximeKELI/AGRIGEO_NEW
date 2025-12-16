"""
Routes pour la gestion des analyses de sol
"""
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime
from database import db
from models.analyse_sol import AnalyseSol
from models.exploitation import Exploitation
from utils.historique import log_action

analyses_sols_bp = Blueprint('analyses_sols', __name__)

@analyses_sols_bp.route('', methods=['GET'])
@jwt_required()
def get_analyses():
    """Liste toutes les analyses de sol"""
    try:
        exploitation_id = request.args.get('exploitation_id')
        parcelle_id = request.args.get('parcelle_id')
        
        query = AnalyseSol.query
        
        if exploitation_id:
            query = query.filter_by(exploitation_id=exploitation_id)
        if parcelle_id:
            query = query.filter_by(parcelle_id=parcelle_id)
        
        analyses = query.all()
        return jsonify([a.to_dict() for a in analyses]), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@analyses_sols_bp.route('', methods=['POST'])
@jwt_required()
def create_analyse():
    """Créer une nouvelle analyse de sol"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data.get('date_prelevement') or not data.get('exploitation_id'):
            return jsonify({'error': 'date_prelevement et exploitation_id sont requis'}), 400
        
        # Vérifier que l'exploitation existe
        exploitation = Exploitation.query.get(data['exploitation_id'])
        if not exploitation:
            return jsonify({'error': 'Exploitation non trouvée'}), 404
        
        # Parser la date
        date_prelevement = datetime.strptime(data['date_prelevement'], '%Y-%m-%d').date()
        
        analyse = AnalyseSol(
            date_prelevement=date_prelevement,
            ph=data.get('ph'),
            humidite=data.get('humidite'),
            texture=data.get('texture'),
            azote_n=data.get('azote_n'),
            phosphore_p=data.get('phosphore_p'),
            potassium_k=data.get('potassium_k'),
            observations=data.get('observations'),
            exploitation_id=data['exploitation_id'],
            parcelle_id=data.get('parcelle_id'),
            technicien_id=user_id
        )
        
        db.session.add(analyse)
        db.session.commit()
        
        log_action(user_id, 'create', 'analyse_sol', analyse.id, {'exploitation_id': data['exploitation_id']})
        
        return jsonify({
            'message': 'Analyse de sol créée avec succès',
            'analyse': analyse.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@analyses_sols_bp.route('/<int:analyse_id>', methods=['GET'])
@jwt_required()
def get_analyse(analyse_id):
    """Récupérer une analyse par ID"""
    try:
        analyse = AnalyseSol.query.get(analyse_id)
        if not analyse:
            return jsonify({'error': 'Analyse non trouvée'}), 404
        return jsonify(analyse.to_dict()), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@analyses_sols_bp.route('/<int:analyse_id>', methods=['PUT'])
@jwt_required()
def update_analyse(analyse_id):
    """Mettre à jour une analyse"""
    try:
        user_id = get_jwt_identity()
        analyse = AnalyseSol.query.get(analyse_id)
        
        if not analyse:
            return jsonify({'error': 'Analyse non trouvée'}), 404
        
        data = request.get_json()
        
        if 'date_prelevement' in data:
            analyse.date_prelevement = datetime.strptime(data['date_prelevement'], '%Y-%m-%d').date()
        if 'ph' in data:
            analyse.ph = data['ph']
        if 'humidite' in data:
            analyse.humidite = data['humidite']
        if 'texture' in data:
            analyse.texture = data['texture']
        if 'azote_n' in data:
            analyse.azote_n = data['azote_n']
        if 'phosphore_p' in data:
            analyse.phosphore_p = data['phosphore_p']
        if 'potassium_k' in data:
            analyse.potassium_k = data['potassium_k']
        if 'observations' in data:
            analyse.observations = data['observations']
        
        db.session.commit()
        
        log_action(user_id, 'update', 'analyse_sol', analyse_id, data)
        
        return jsonify({
            'message': 'Analyse mise à jour avec succès',
            'analyse': analyse.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@analyses_sols_bp.route('/<int:analyse_id>', methods=['DELETE'])
@jwt_required()
def delete_analyse(analyse_id):
    """Supprimer une analyse"""
    try:
        user_id = get_jwt_identity()
        analyse = AnalyseSol.query.get(analyse_id)
        
        if not analyse:
            return jsonify({'error': 'Analyse non trouvée'}), 404
        
        db.session.delete(analyse)
        db.session.commit()
        
        log_action(user_id, 'delete', 'analyse_sol', analyse_id, {})
        
        return jsonify({'message': 'Analyse supprimée avec succès'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

