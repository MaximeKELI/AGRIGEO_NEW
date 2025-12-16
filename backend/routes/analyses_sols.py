"""
Routes pour la gestion des analyses de sol
"""
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime
from database import db
from models.analyse_sol import AnalyseSol
from models.exploitation import Exploitation
from models.sensor import SensorData
from utils.historique import log_action
from utils.validators import validate_analyse_sol_data
from routes.utils import get_pagination_params, paginate_query
import json

analyses_sols_bp = Blueprint('analyses_sols', __name__)

@analyses_sols_bp.route('', methods=['GET'])
@jwt_required()
def get_analyses():
    """Liste toutes les analyses de sol avec pagination"""
    try:
        exploitation_id = request.args.get('exploitation_id', type=int)
        parcelle_id = request.args.get('parcelle_id', type=int)
        page, per_page = get_pagination_params()
        
        query = AnalyseSol.query
        
        if exploitation_id:
            query = query.filter_by(exploitation_id=exploitation_id)
        if parcelle_id:
            query = query.filter_by(parcelle_id=parcelle_id)
        
        # Tri par date de prélèvement décroissante
        query = query.order_by(AnalyseSol.date_prelevement.desc())
        
        result = paginate_query(query, page, per_page)
        return jsonify(result), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@analyses_sols_bp.route('', methods=['POST'])
@jwt_required()
def create_analyse():
    """Créer une nouvelle analyse de sol"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validation des données
        errors = validate_analyse_sol_data(data)
        if errors:
            return jsonify({'errors': errors}), 400
        
        # Vérifier que l'exploitation existe
        exploitation = Exploitation.query.get(data['exploitation_id'])
        if not exploitation:
            return jsonify({'error': 'Exploitation non trouvée'}), 404
        
        # Parser la date
        date_prelevement = datetime.strptime(data['date_prelevement'], '%Y-%m-%d').date()
        
        # Traiter les données de capteurs si présentes
        sensor_data_json = None
        sensor_ids_list = []
        data_source = 'manual'
        
        if 'sensor_data' in data and data['sensor_data']:
            # Si des données de capteurs sont fournies, les intégrer
            sensor_data_list = data['sensor_data'] if isinstance(data['sensor_data'], list) else [data['sensor_data']]
            
            # Convertir les données de capteurs en données d'analyse
            for sensor_data_item in sensor_data_list:
                sensor_id = sensor_data_item.get('sensor_id')
                sensor_type = sensor_data_item.get('sensor_type', '').lower()
                value = sensor_data_item.get('value')
                
                if sensor_id:
                    sensor_ids_list.append(sensor_id)
                
                # Mapper les données de capteurs aux champs d'analyse
                if sensor_type in ['soil_moisture', 'humidite'] and value is not None:
                    if data.get('humidite') is None:
                        data['humidite'] = value
                elif sensor_type == 'ph' and value is not None:
                    if data.get('ph') is None:
                        data['ph'] = value
                elif sensor_type in ['nitrogen', 'azote', 'n'] and value is not None:
                    if data.get('azote_n') is None:
                        data['azote_n'] = value
                elif sensor_type in ['phosphorus', 'phosphore', 'p'] and value is not None:
                    if data.get('phosphore_p') is None:
                        data['phosphore_p'] = value
                elif sensor_type in ['potassium', 'k'] and value is not None:
                    if data.get('potassium_k') is None:
                        data['potassium_k'] = value
            
            if sensor_data_list:
                sensor_data_json = json.dumps(sensor_data_list)
                data_source = 'sensor' if not any([data.get('ph'), data.get('humidite'), data.get('azote_n'), data.get('phosphore_p'), data.get('potassium_k')]) else 'mixed'
        
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
            technicien_id=user_id,
            sensor_data=sensor_data_json,
            sensor_ids=json.dumps(sensor_ids_list) if sensor_ids_list else None,
            data_source=data_source
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

