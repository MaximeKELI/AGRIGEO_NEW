"""
Routes pour la gestion des récoltes
"""
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime
from database import db
from models.recolte import Recolte
from models.exploitation import Exploitation
from utils.historique import log_action
from routes.utils import get_pagination_params, paginate_query
import json

recoltes_bp = Blueprint('recoltes', __name__)

@recoltes_bp.route('', methods=['GET'])
@jwt_required()
def get_recoltes():
    """Liste toutes les récoltes avec filtres"""
    try:
        exploitation_id = request.args.get('exploitation_id', type=int)
        parcelle_id = request.args.get('parcelle_id', type=int)
        type_culture = request.args.get('type_culture')
        annee = request.args.get('annee', type=int)
        mois = request.args.get('mois', type=int)
        page, per_page = get_pagination_params()
        
        query = Recolte.query
        
        if exploitation_id:
            query = query.filter_by(exploitation_id=exploitation_id)
        if parcelle_id:
            query = query.filter_by(parcelle_id=parcelle_id)
        if type_culture:
            query = query.filter_by(type_culture=type_culture)
        if annee:
            query = query.filter_by(annee=annee)
        if mois:
            query = query.filter_by(mois=mois)
        
        query = query.order_by(Recolte.annee.desc(), Recolte.mois.desc())
        
        result = paginate_query(query, page, per_page)
        return jsonify(result), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@recoltes_bp.route('', methods=['POST'])
@jwt_required()
def create_recolte():
    """Créer une nouvelle récolte"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        # Validation
        if not data.get('exploitation_id') or not data.get('type_culture') or \
           not data.get('mois') or not data.get('annee') or not data.get('quantite_recoltee'):
            return jsonify({'error': 'Données incomplètes'}), 400
        
        # Vérifier que l'exploitation existe
        exploitation = Exploitation.query.get(data['exploitation_id'])
        if not exploitation:
            return jsonify({'error': 'Exploitation non trouvée'}), 404
        
        # Calculer le rendement si possible
        rendement = None
        if data.get('superficie_recoltee') and data['superficie_recoltee'] > 0:
            rendement = data['quantite_recoltee'] / data['superficie_recoltee']
        
        recolte = Recolte(
            exploitation_id=data['exploitation_id'],
            parcelle_id=data.get('parcelle_id'),
            type_culture=data['type_culture'],
            mois=data['mois'],
            annee=data['annee'],
            quantite_recoltee=data['quantite_recoltee'],
            unite_mesure=data.get('unite_mesure', 'kg'),
            superficie_recoltee=data.get('superficie_recoltee'),
            rendement=rendement or data.get('rendement'),
            prix_vente=data.get('prix_vente'),
            cout_production=data.get('cout_production'),
            qualite=data.get('qualite'),
            conditions_climatiques=data.get('conditions_climatiques'),
            observations=data.get('observations'),
        )
        
        db.session.add(recolte)
        db.session.commit()
        
        log_action(user_id, 'create', 'recolte', recolte.id, {'exploitation_id': data['exploitation_id']})
        
        return jsonify({
            'message': 'Récolte créée avec succès',
            'recolte': recolte.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@recoltes_bp.route('/import', methods=['POST'])
@jwt_required()
def import_recoltes():
    """Importer des récoltes depuis un fichier CSV/JSON"""
    try:
        user_id = get_jwt_identity()
        data = request.get_json()
        
        if not data.get('recoltes') or not isinstance(data['recoltes'], list):
            return jsonify({'error': 'Format invalide. Attendu: {"recoltes": [...]}'}), 400
        
        recoltes_importees = []
        erreurs = []
        
        for idx, rec_data in enumerate(data['recoltes']):
            try:
                # Validation des données minimales
                if not rec_data.get('exploitation_id') or not rec_data.get('type_culture') or \
                   not rec_data.get('mois') or not rec_data.get('annee') or not rec_data.get('quantite_recoltee'):
                    erreurs.append(f'Ligne {idx + 1}: Données incomplètes')
                    continue
                
                # Calculer le rendement si possible
                rendement = None
                if rec_data.get('superficie_recoltee') and rec_data['superficie_recoltee'] > 0:
                    rendement = rec_data['quantite_recoltee'] / rec_data['superficie_recoltee']
                
                recolte = Recolte(
                    exploitation_id=rec_data['exploitation_id'],
                    parcelle_id=rec_data.get('parcelle_id'),
                    type_culture=rec_data['type_culture'],
                    mois=rec_data['mois'],
                    annee=rec_data['annee'],
                    quantite_recoltee=rec_data['quantite_recoltee'],
                    unite_mesure=rec_data.get('unite_mesure', 'kg'),
                    superficie_recoltee=rec_data.get('superficie_recoltee'),
                    rendement=rendement or rec_data.get('rendement'),
                    prix_vente=rec_data.get('prix_vente'),
                    cout_production=rec_data.get('cout_production'),
                    qualite=rec_data.get('qualite'),
                    conditions_climatiques=rec_data.get('conditions_climatiques'),
                    observations=rec_data.get('observations'),
                )
                
                db.session.add(recolte)
                recoltes_importees.append(recolte)
                
            except Exception as e:
                erreurs.append(f'Ligne {idx + 1}: {str(e)}')
        
        db.session.commit()
        
        log_action(user_id, 'import', 'recolte', None, {'nombre': len(recoltes_importees)})
        
        return jsonify({
            'message': f'{len(recoltes_importees)} récoltes importées avec succès',
            'importees': len(recoltes_importees),
            'erreurs': erreurs,
            'recoltes': [r.to_dict() for r in recoltes_importees]
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@recoltes_bp.route('/statistics', methods=['GET'])
@jwt_required()
def get_statistics():
    """Récupérer les statistiques des récoltes"""
    try:
        exploitation_id = request.args.get('exploitation_id', type=int)
        type_culture = request.args.get('type_culture')
        annee = request.args.get('annee', type=int)
        
        query = Recolte.query
        
        if exploitation_id:
            query = query.filter_by(exploitation_id=exploitation_id)
        if type_culture:
            query = query.filter_by(type_culture=type_culture)
        if annee:
            query = query.filter_by(annee=annee)
        
        recoltes = query.all()
        
        if not recoltes:
            return jsonify({
                'min': 0,
                'max': 0,
                'moyenne': 0,
                'mediane': 0,
                'ecart_type': 0,
                'nombre': 0
            }), 200
        
        quantites = [r.quantite_recoltee for r in recoltes]
        quantites.sort()
        
        min_val = min(quantites)
        max_val = max(quantites)
        moyenne = sum(quantites) / len(quantites)
        
        # Médiane
        n = len(quantites)
        if n % 2 == 0:
            mediane = (quantites[n//2 - 1] + quantites[n//2]) / 2
        else:
            mediane = quantites[n//2]
        
        # Écart-type
        variance = sum((x - moyenne) ** 2 for x in quantites) / len(quantites)
        ecart_type = variance ** 0.5
        
        return jsonify({
            'min': min_val,
            'max': max_val,
            'moyenne': moyenne,
            'mediane': mediane,
            'ecart_type': ecart_type,
            'nombre': len(recoltes)
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@recoltes_bp.route('/prevision', methods=['GET'])
@jwt_required()
def get_prevision():
    """Calculer la prévision pour la prochaine récolte"""
    try:
        exploitation_id = request.args.get('exploitation_id', type=int)
        type_culture = request.args.get('type_culture')
        
        if not exploitation_id or not type_culture:
            return jsonify({'error': 'exploitation_id et type_culture requis'}), 400
        
        # Récupérer les récoltes historiques
        recoltes = Recolte.query.filter_by(
            exploitation_id=exploitation_id,
            type_culture=type_culture
        ).order_by(Recolte.annee.desc(), Recolte.mois.desc()).limit(12).all()
        
        if len(recoltes) < 3:
            return jsonify({
                'quantite_prevue': 0,
                'probabilite_bonne': 50,
                'probabilite_mauvaise': 50,
                'prediction': 'moyenne',
                'raison': 'Données insuffisantes pour une prévision fiable'
            }), 200
        
        quantites = [r.quantite_recoltee for r in recoltes]
        moyenne = sum(quantites) / len(quantites)
        tendance = (quantites[0] - quantites[-1]) / len(quantites) if len(quantites) > 1 else 0
        
        # Prévision basée sur la moyenne et la tendance
        quantite_prevue = moyenne + (tendance * 1.2)  # Ajustement avec facteur
        
        # Calculer les probabilités
        ecart_type = (sum((x - moyenne) ** 2 for x in quantites) / len(quantites)) ** 0.5
        
        # Si la prévision est supérieure à la moyenne + écart-type, bonne récolte probable
        if quantite_prevue > moyenne + ecart_type:
            probabilite_bonne = 70
            probabilite_mauvaise = 30
            prediction = 'bonne'
        elif quantite_prevue < moyenne - ecart_type:
            probabilite_bonne = 30
            probabilite_mauvaise = 70
            prediction = 'mauvaise'
        else:
            probabilite_bonne = 50
            probabilite_mauvaise = 50
            prediction = 'moyenne'
        
        facteurs = {
            'moyenne_historique': moyenne,
            'tendance': tendance,
            'ecart_type': ecart_type,
            'nombre_recoltes_analysees': len(recoltes)
        }
        
        return jsonify({
            'quantite_prevue': round(quantite_prevue, 2),
            'probabilite_bonne': round(probabilite_bonne, 1),
            'probabilite_mauvaise': round(probabilite_mauvaise, 1),
            'prediction': prediction,
            'raison': f'Basé sur {len(recoltes)} récoltes historiques',
            'facteurs': facteurs
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@recoltes_bp.route('/<int:recolte_id>', methods=['GET'])
@jwt_required()
def get_recolte(recolte_id):
    """Récupérer une récolte par ID"""
    try:
        recolte = Recolte.query.get(recolte_id)
        if not recolte:
            return jsonify({'error': 'Récolte non trouvée'}), 404
        return jsonify(recolte.to_dict()), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@recoltes_bp.route('/<int:recolte_id>', methods=['PUT'])
@jwt_required()
def update_recolte(recolte_id):
    """Mettre à jour une récolte"""
    try:
        user_id = get_jwt_identity()
        recolte = Recolte.query.get(recolte_id)
        
        if not recolte:
            return jsonify({'error': 'Récolte non trouvée'}), 404
        
        data = request.get_json()
        
        if 'type_culture' in data:
            recolte.type_culture = data['type_culture']
        if 'mois' in data:
            recolte.mois = data['mois']
        if 'annee' in data:
            recolte.annee = data['annee']
        if 'quantite_recoltee' in data:
            recolte.quantite_recoltee = data['quantite_recoltee']
        if 'superficie_recoltee' in data:
            recolte.superficie_recoltee = data['superficie_recoltee']
        if 'prix_vente' in data:
            recolte.prix_vente = data['prix_vente']
        if 'cout_production' in data:
            recolte.cout_production = data['cout_production']
        if 'qualite' in data:
            recolte.qualite = data['qualite']
        if 'observations' in data:
            recolte.observations = data['observations']
        
        # Recalculer le rendement
        if recolte.superficie_recoltee and recolte.superficie_recoltee > 0:
            recolte.rendement = recolte.quantite_recoltee / recolte.superficie_recoltee
        
        db.session.commit()
        
        log_action(user_id, 'update', 'recolte', recolte_id, data)
        
        return jsonify({
            'message': 'Récolte mise à jour avec succès',
            'recolte': recolte.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@recoltes_bp.route('/<int:recolte_id>', methods=['DELETE'])
@jwt_required()
def delete_recolte(recolte_id):
    """Supprimer une récolte"""
    try:
        user_id = get_jwt_identity()
        recolte = Recolte.query.get(recolte_id)
        
        if not recolte:
            return jsonify({'error': 'Récolte non trouvée'}), 404
        
        db.session.delete(recolte)
        db.session.commit()
        
        log_action(user_id, 'delete', 'recolte', recolte_id, {})
        
        return jsonify({'message': 'Récolte supprimée avec succès'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500




