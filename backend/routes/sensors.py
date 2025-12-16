"""
Routes pour la gestion des capteurs IoT
"""
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime
from database import db
from models.sensor import Sensor, SensorData
from models.exploitation import Exploitation
from utils.historique import log_action
from routes.utils import get_pagination_params, paginate_query
import json

sensors_bp = Blueprint('sensors', __name__)

@sensors_bp.route('/data', methods=['POST'])
def receive_sensor_data():
    """Endpoint pour recevoir les données des capteurs (peut être public avec authentification par API key)"""
    try:
        data = request.get_json()
        
        # Validation des données minimales
        if not data.get('sensor_id') or not data.get('sensor_type') or data.get('value') is None:
            return jsonify({'error': 'sensor_id, sensor_type et value sont requis'}), 400
        
        # Vérifier si le capteur existe
        sensor = Sensor.query.filter_by(sensor_id=data['sensor_id']).first()
        if not sensor:
            return jsonify({'error': 'Capteur non enregistré'}), 404
        
        if not sensor.is_active:
            return jsonify({'error': 'Capteur désactivé'}), 400
        
        # Créer l'enregistrement de données
        sensor_data = SensorData(
            sensor_id=data['sensor_id'],
            sensor_type=data['sensor_type'],
            value=float(data['value']),
            unit=data.get('unit', ''),
            latitude=data.get('latitude'),
            longitude=data.get('longitude'),
            parcelle_id=data.get('parcelle_id') or sensor.parcelle_id,
            exploitation_id=data.get('exploitation_id') or sensor.exploitation_id,
            timestamp=datetime.fromisoformat(data['timestamp'].replace('Z', '+00:00')) if data.get('timestamp') else datetime.utcnow(),
            battery_level=data.get('battery_level'),
            signal_strength=data.get('signal_strength'),
            metadata=json.dumps(data.get('metadata', {})) if data.get('metadata') else None
        )
        
        db.session.add(sensor_data)
        
        # Mettre à jour le capteur
        sensor.last_reading = datetime.utcnow()
        if 'battery_level' in data:
            sensor.battery_level = data['battery_level']
        
        db.session.commit()
        
        return jsonify({
            'message': 'Données de capteur enregistrées avec succès',
            'sensor_data': sensor_data.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@sensors_bp.route('/data', methods=['GET'])
@jwt_required()
def get_sensor_data():
    """Récupérer les données des capteurs"""
    try:
        sensor_id = request.args.get('sensor_id')
        sensor_type = request.args.get('sensor_type')
        exploitation_id = request.args.get('exploitation_id', type=int)
        parcelle_id = request.args.get('parcelle_id', type=int)
        start_date = request.args.get('start_date')
        end_date = request.args.get('end_date')
        page, per_page = get_pagination_params()
        
        query = SensorData.query
        
        if sensor_id:
            query = query.filter_by(sensor_id=sensor_id)
        if sensor_type:
            query = query.filter_by(sensor_type=sensor_type)
        if exploitation_id:
            query = query.filter_by(exploitation_id=exploitation_id)
        if parcelle_id:
            query = query.filter_by(parcelle_id=parcelle_id)
        if start_date:
            query = query.filter(SensorData.timestamp >= datetime.fromisoformat(start_date))
        if end_date:
            query = query.filter(SensorData.timestamp <= datetime.fromisoformat(end_date))
        
        query = query.order_by(SensorData.timestamp.desc())
        
        result = paginate_query(query, page, per_page)
        return jsonify(result), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@sensors_bp.route('', methods=['GET'])
@jwt_required()
def get_sensors():
    """Liste tous les capteurs"""
    try:
        exploitation_id = request.args.get('exploitation_id', type=int)
        parcelle_id = request.args.get('parcelle_id', type=int)
        sensor_type = request.args.get('sensor_type')
        is_active = request.args.get('is_active', type=bool)
        
        query = Sensor.query
        
        if exploitation_id:
            query = query.filter_by(exploitation_id=exploitation_id)
        if parcelle_id:
            query = query.filter_by(parcelle_id=parcelle_id)
        if sensor_type:
            query = query.filter_by(sensor_type=sensor_type)
        if is_active is not None:
            query = query.filter_by(is_active=is_active)
        
        sensors = query.all()
        return jsonify([sensor.to_dict() for sensor in sensors]), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@sensors_bp.route('', methods=['POST'])
@jwt_required()
def create_sensor():
    """Enregistrer un nouveau capteur"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data.get('sensor_id') or not data.get('sensor_name') or not data.get('sensor_type'):
            return jsonify({'error': 'sensor_id, sensor_name et sensor_type sont requis'}), 400
        
        # Vérifier si le capteur existe déjà
        existing = Sensor.query.filter_by(sensor_id=data['sensor_id']).first()
        if existing:
            return jsonify({'error': 'Capteur déjà enregistré'}), 400
        
        sensor = Sensor(
            sensor_id=data['sensor_id'],
            sensor_name=data['sensor_name'],
            sensor_type=data['sensor_type'],
            description=data.get('description'),
            parcelle_id=data.get('parcelle_id'),
            exploitation_id=data.get('exploitation_id'),
            latitude=data.get('latitude'),
            longitude=data.get('longitude'),
            is_active=data.get('is_active', True)
        )
        
        db.session.add(sensor)
        db.session.commit()
        
        log_action(user_id, 'create', 'sensor', sensor.id, {'sensor_id': data['sensor_id']})
        
        return jsonify({
            'message': 'Capteur enregistré avec succès',
            'sensor': sensor.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@sensors_bp.route('/<int:sensor_id>', methods=['GET'])
@jwt_required()
def get_sensor(sensor_id):
    """Récupérer un capteur par ID"""
    try:
        sensor = Sensor.query.get(sensor_id)
        if not sensor:
            return jsonify({'error': 'Capteur non trouvé'}), 404
        return jsonify(sensor.to_dict()), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@sensors_bp.route('/<int:sensor_id>', methods=['PUT'])
@jwt_required()
def update_sensor(sensor_id):
    """Mettre à jour un capteur"""
    try:
        user_id = get_jwt_identity()
        sensor = Sensor.query.get(sensor_id)
        
        if not sensor:
            return jsonify({'error': 'Capteur non trouvé'}), 404
        
        data = request.get_json()
        
        if 'sensor_name' in data:
            sensor.sensor_name = data['sensor_name']
        if 'description' in data:
            sensor.description = data['description']
        if 'parcelle_id' in data:
            sensor.parcelle_id = data['parcelle_id']
        if 'exploitation_id' in data:
            sensor.exploitation_id = data['exploitation_id']
        if 'latitude' in data:
            sensor.latitude = data['latitude']
        if 'longitude' in data:
            sensor.longitude = data['longitude']
        if 'is_active' in data:
            sensor.is_active = data['is_active']
        
        db.session.commit()
        
        log_action(user_id, 'update', 'sensor', sensor_id, data)
        
        return jsonify({
            'message': 'Capteur mis à jour avec succès',
            'sensor': sensor.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

