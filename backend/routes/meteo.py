"""
Routes pour la gestion de la météo et conseils d'irrigation
"""
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from services.irrigation_service import generate_conseils_irrigation
from services.meteo_service import get_current_weather, get_weather_forecast, get_weather_by_city
from models.exploitation import Exploitation

meteo_bp = Blueprint('meteo', __name__)

@meteo_bp.route('/test/ville', methods=['GET'])
def test_meteo_ville():
    """
    Endpoint de test public pour la météo par ville (sans authentification)
    Utile pour tester l'intégration OpenWeatherMap
    """
    try:
        ville = request.args.get('ville')
        pays = request.args.get('pays')
        
        if not ville:
            return jsonify({'error': 'Paramètre "ville" requis'}), 400
        
        meteo = get_weather_by_city(ville, pays)
        
        return jsonify({
            'meteo': meteo,
            'message': 'Test réussi - Endpoint public de test'
        }), 200
        
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@meteo_bp.route('/test/coord', methods=['GET'])
def test_meteo_coord():
    """
    Endpoint de test public pour la météo par coordonnées (sans authentification)
    Utile pour tester l'intégration OpenWeatherMap
    """
    try:
        latitude = request.args.get('latitude', type=float)
        longitude = request.args.get('longitude', type=float)
        
        if latitude is None or longitude is None:
            return jsonify({'error': 'Paramètres latitude et longitude requis'}), 400
        
        meteo = get_current_weather(latitude, longitude)
        
        return jsonify({
            'meteo': meteo,
            'message': 'Test réussi - Endpoint public de test'
        }), 200
        
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@meteo_bp.route('/test/previsions', methods=['GET'])
def test_meteo_previsions():
    """
    Endpoint de test public pour les prévisions météo par coordonnées (sans authentification)
    """
    try:
        latitude = request.args.get('latitude', type=float)
        longitude = request.args.get('longitude', type=float)
        
        if latitude is None or longitude is None:
            return jsonify({'error': 'Paramètres latitude et longitude requis'}), 400
        
        previsions = get_weather_forecast(latitude, longitude)
        
        return jsonify({
            'previsions': previsions,
            'message': 'Prévisions récupérées - Endpoint public de test'
        }), 200
        
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@meteo_bp.route('/conseils-irrigation/<int:exploitation_id>', methods=['POST', 'GET'])
@jwt_required()
def get_conseils_irrigation(exploitation_id):
    """
    Génère des conseils d'irrigation basés sur la météo
    Si POST: utilise les données météo fournies dans le body
    Si GET: récupère automatiquement les données depuis OpenWeather
    """
    try:
        user_id = get_jwt_identity()
        
        # Vérifier que l'exploitation existe
        exploitation = Exploitation.query.get(exploitation_id)
        if not exploitation:
            return jsonify({'error': 'Exploitation non trouvée'}), 404
        
        if exploitation.proprietaire_id != user_id:
            return jsonify({'error': 'Non autorisé'}), 403
        
        if not exploitation.latitude or not exploitation.longitude:
            return jsonify({'error': 'Coordonnées GPS non définies pour cette exploitation'}), 400
        
        # Si GET, récupérer automatiquement depuis OpenWeather
        if request.method == 'GET':
            meteo_actuelle = get_current_weather(exploitation.latitude, exploitation.longitude)
            previsions = get_weather_forecast(exploitation.latitude, exploitation.longitude)
            derniere_pluviometrie = None  # Peut être récupéré depuis la base de données si nécessaire
        else:
            # Si POST, utiliser les données fournies
            data = request.get_json() or {}
            meteo_actuelle = data.get('meteo_actuelle', {})
            previsions = data.get('previsions', [])
            derniere_pluviometrie = data.get('derniere_pluviometrie')
            
            # Si aucune donnée n'est fournie, récupérer depuis OpenWeather
            if not meteo_actuelle:
                meteo_actuelle = get_current_weather(exploitation.latitude, exploitation.longitude)
                previsions = get_weather_forecast(exploitation.latitude, exploitation.longitude) if not previsions else previsions
        
        if not meteo_actuelle:
            return jsonify({'error': 'Impossible de récupérer les données météo'}), 500
        
        # Générer les conseils d'irrigation
        conseils = generate_conseils_irrigation(
            meteo_actuelle=meteo_actuelle,
            previsions=previsions,
            derniere_pluviometrie=derniere_pluviometrie,
            type_culture=exploitation.type_culture_principal,
        )
        
        return jsonify({
            'conseils': conseils,
            'exploitation_id': exploitation_id,
            'meteo_actuelle': meteo_actuelle,
            'previsions': previsions[:5] if previsions else []  # Limiter à 5 prévisions pour la réponse
        }), 200
        
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@meteo_bp.route('/actuelle', methods=['GET'])
@jwt_required()
def get_meteo_actuelle():
    """
    Récupère la météo actuelle par coordonnées ou par exploitation
    Query params: latitude, longitude OU exploitation_id
    """
    try:
        user_id = get_jwt_identity()
        latitude = request.args.get('latitude', type=float)
        longitude = request.args.get('longitude', type=float)
        exploitation_id = request.args.get('exploitation_id', type=int)
        
        # Si exploitation_id est fourni, utiliser ses coordonnées
        if exploitation_id:
            exploitation = Exploitation.query.get(exploitation_id)
            if not exploitation:
                return jsonify({'error': 'Exploitation non trouvée'}), 404
            
            if exploitation.proprietaire_id != user_id:
                return jsonify({'error': 'Non autorisé'}), 403
            
            if not exploitation.latitude or not exploitation.longitude:
                return jsonify({'error': 'Coordonnées GPS non définies pour cette exploitation'}), 400
            
            latitude = exploitation.latitude
            longitude = exploitation.longitude
        
        # Vérifier qu'on a des coordonnées
        if latitude is None or longitude is None:
            return jsonify({'error': 'Coordonnées GPS requises (latitude, longitude) ou exploitation_id'}), 400
        
        meteo = get_current_weather(latitude, longitude)
        
        return jsonify({
            'meteo': meteo,
            'exploitation_id': exploitation_id if exploitation_id else None
        }), 200
        
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@meteo_bp.route('/previsions', methods=['GET'])
@jwt_required()
def get_previsions():
    """
    Récupère les prévisions météo par coordonnées ou par exploitation
    Query params: latitude, longitude OU exploitation_id
    """
    try:
        user_id = get_jwt_identity()
        latitude = request.args.get('latitude', type=float)
        longitude = request.args.get('longitude', type=float)
        exploitation_id = request.args.get('exploitation_id', type=int)
        
        # Si exploitation_id est fourni, utiliser ses coordonnées
        if exploitation_id:
            exploitation = Exploitation.query.get(exploitation_id)
            if not exploitation:
                return jsonify({'error': 'Exploitation non trouvée'}), 404
            
            if exploitation.proprietaire_id != user_id:
                return jsonify({'error': 'Non autorisé'}), 403
            
            if not exploitation.latitude or not exploitation.longitude:
                return jsonify({'error': 'Coordonnées GPS non définies pour cette exploitation'}), 400
            
            latitude = exploitation.latitude
            longitude = exploitation.longitude
        
        # Vérifier qu'on a des coordonnées
        if latitude is None or longitude is None:
            return jsonify({'error': 'Coordonnées GPS requises (latitude, longitude) ou exploitation_id'}), 400
        
        previsions = get_weather_forecast(latitude, longitude)
        
        return jsonify({
            'previsions': previsions,
            'exploitation_id': exploitation_id if exploitation_id else None
        }), 200
        
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@meteo_bp.route('/ville', methods=['GET'])
@jwt_required()
def get_meteo_par_ville():
    """
    Récupère la météo actuelle par nom de ville
    Query params: ville (requis), pays (optionnel)
    """
    try:
        ville = request.args.get('ville')
        pays = request.args.get('pays')
        
        if not ville:
            return jsonify({'error': 'Paramètre "ville" requis'}), 400
        
        meteo = get_weather_by_city(ville, pays)
        
        return jsonify({'meteo': meteo}), 200
        
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@meteo_bp.route('/complete/<int:exploitation_id>', methods=['GET'])
@jwt_required()
def get_meteo_complete(exploitation_id):
    """
    Récupère la météo actuelle et les prévisions pour une exploitation
    """
    try:
        user_id = get_jwt_identity()
        
        exploitation = Exploitation.query.get(exploitation_id)
        if not exploitation:
            return jsonify({'error': 'Exploitation non trouvée'}), 404
        
        if exploitation.proprietaire_id != user_id:
            return jsonify({'error': 'Non autorisé'}), 403
        
        if not exploitation.latitude or not exploitation.longitude:
            return jsonify({'error': 'Coordonnées GPS non définies pour cette exploitation'}), 400
        
        # Récupérer météo actuelle et prévisions
        meteo_actuelle = get_current_weather(exploitation.latitude, exploitation.longitude)
        previsions = get_weather_forecast(exploitation.latitude, exploitation.longitude)
        
        return jsonify({
            'meteo_actuelle': meteo_actuelle,
            'previsions': previsions,
            'exploitation_id': exploitation_id
        }), 200
        
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500




