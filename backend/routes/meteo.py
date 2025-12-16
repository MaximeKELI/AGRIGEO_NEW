"""
Routes pour la gestion de la météo et conseils d'irrigation
"""
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from services.irrigation_service import generate_conseils_irrigation
from models.exploitation import Exploitation

meteo_bp = Blueprint('meteo', __name__)

@meteo_bp.route('/conseils-irrigation/<int:exploitation_id>', methods=['POST'])
@jwt_required()
def get_conseils_irrigation(exploitation_id):
    """Génère des conseils d'irrigation basés sur la météo"""
    try:
        user_id = get_jwt_identity()
        
        # Vérifier que l'exploitation existe
        exploitation = Exploitation.query.get(exploitation_id)
        if not exploitation:
            return jsonify({'error': 'Exploitation non trouvée'}), 404
        
        if exploitation.proprietaire_id != user_id:
            return jsonify({'error': 'Non autorisé'}), 403
        
        # Récupérer les données météo depuis le frontend
        data = request.get_json()
        meteo_actuelle = data.get('meteo_actuelle', {})
        previsions = data.get('previsions', [])
        derniere_pluviometrie = data.get('derniere_pluviometrie')
        
        if not meteo_actuelle:
            return jsonify({'error': 'Données météo requises'}), 400
        
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
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

