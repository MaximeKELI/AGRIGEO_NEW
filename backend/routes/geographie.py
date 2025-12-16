"""
Routes pour la gestion de la structure géographique hiérarchique
"""
from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import db
from models.region import Region, Prefecture, Commune
from models.exploitation import Exploitation
from routes.utils import log_action

geographie_bp = Blueprint('geographie', __name__)

# ========== RÉGIONS ==========

@geographie_bp.route('/regions', methods=['GET'])
@jwt_required()
def get_regions():
    """Liste toutes les régions"""
    try:
        regions = Region.query.all()
        return jsonify([r.to_dict() for r in regions]), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@geographie_bp.route('/regions/<int:region_id>', methods=['GET'])
@jwt_required()
def get_region(region_id):
    """Récupère une région par son ID"""
    try:
        region = Region.query.get(region_id)
        if not region:
            return jsonify({'error': 'Région non trouvée'}), 404
        return jsonify(region.to_dict()), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@geographie_bp.route('/regions', methods=['POST'])
@jwt_required()
def create_region():
    """Crée une nouvelle région"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data or not data.get('nom'):
            return jsonify({'error': 'Le nom est requis'}), 400
        
        region = Region(
            nom=data['nom'],
            code=data.get('code'),
            superficie=data.get('superficie'),
            chef_lieu=data.get('chef_lieu'),
            latitude=data.get('latitude'),
            longitude=data.get('longitude'),
            description=data.get('description')
        )
        
        db.session.add(region)
        db.session.commit()
        
        log_action(user_id, 'create', 'region', region.id, {'nom': region.nom})
        
        return jsonify(region.to_dict()), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

# ========== PRÉFECTURES ==========

@geographie_bp.route('/prefectures', methods=['GET'])
@jwt_required()
def get_prefectures():
    """Liste toutes les préfectures, optionnellement filtrées par région"""
    try:
        region_id = request.args.get('region_id', type=int)
        
        if region_id:
            prefectures = Prefecture.query.filter_by(region_id=region_id).all()
        else:
            prefectures = Prefecture.query.all()
        
        return jsonify([p.to_dict() for p in prefectures]), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@geographie_bp.route('/prefectures/<int:prefecture_id>', methods=['GET'])
@jwt_required()
def get_prefecture(prefecture_id):
    """Récupère une préfecture par son ID"""
    try:
        prefecture = Prefecture.query.get(prefecture_id)
        if not prefecture:
            return jsonify({'error': 'Préfecture non trouvée'}), 404
        return jsonify(prefecture.to_dict()), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@geographie_bp.route('/prefectures', methods=['POST'])
@jwt_required()
def create_prefecture():
    """Crée une nouvelle préfecture"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data or not data.get('nom') or not data.get('region_id'):
            return jsonify({'error': 'Le nom et la région sont requis'}), 400
        
        prefecture = Prefecture(
            nom=data['nom'],
            code=data.get('code'),
            region_id=data['region_id'],
            superficie=data.get('superficie'),
            chef_lieu=data.get('chef_lieu'),
            latitude=data.get('latitude'),
            longitude=data.get('longitude'),
            description=data.get('description')
        )
        
        db.session.add(prefecture)
        db.session.commit()
        
        log_action(user_id, 'create', 'prefecture', prefecture.id, {'nom': prefecture.nom})
        
        return jsonify(prefecture.to_dict()), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

# ========== COMMUNES ==========

@geographie_bp.route('/communes', methods=['GET'])
@jwt_required()
def get_communes():
    """Liste toutes les communes, optionnellement filtrées par préfecture ou région"""
    try:
        prefecture_id = request.args.get('prefecture_id', type=int)
        region_id = request.args.get('region_id', type=int)
        
        query = Commune.query
        
        if prefecture_id:
            query = query.filter_by(prefecture_id=prefecture_id)
        elif region_id:
            # Filtrer par région via la préfecture
            query = query.join(Prefecture).filter(Prefecture.region_id == region_id)
        
        communes = query.all()
        return jsonify([c.to_dict() for c in communes]), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@geographie_bp.route('/communes/<int:commune_id>', methods=['GET'])
@jwt_required()
def get_commune(commune_id):
    """Récupère une commune par son ID"""
    try:
        commune = Commune.query.get(commune_id)
        if not commune:
            return jsonify({'error': 'Commune non trouvée'}), 404
        return jsonify(commune.to_dict()), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@geographie_bp.route('/communes', methods=['POST'])
@jwt_required()
def create_commune():
    """Crée une nouvelle commune"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data or not data.get('nom') or not data.get('prefecture_id'):
            return jsonify({'error': 'Le nom et la préfecture sont requis'}), 400
        
        commune = Commune(
            nom=data['nom'],
            code=data.get('code'),
            prefecture_id=data['prefecture_id'],
            superficie=data.get('superficie'),
            latitude=data.get('latitude'),
            longitude=data.get('longitude'),
            description=data.get('description')
        )
        
        db.session.add(commune)
        db.session.commit()
        
        log_action(user_id, 'create', 'commune', commune.id, {'nom': commune.nom})
        
        return jsonify(commune.to_dict()), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

# ========== HIÉRARCHIE COMPLÈTE ==========

@geographie_bp.route('/hierarchie', methods=['GET'])
@jwt_required()
def get_hierarchie_complete():
    """Récupère la hiérarchie complète (régions avec préfectures et communes)"""
    try:
        regions = Region.query.all()
        result = []
        
        for region in regions:
            region_dict = region.to_dict()
            prefectures_list = []
            
            for prefecture in region.prefectures:
                prefecture_dict = prefecture.to_dict()
                communes_list = [c.to_dict() for c in prefecture.communes]
                prefecture_dict['communes'] = communes_list
                prefectures_list.append(prefecture_dict)
            
            region_dict['prefectures'] = prefectures_list
            result.append(region_dict)
        
        return jsonify(result), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

