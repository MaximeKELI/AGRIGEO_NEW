"""
Routes pour les statistiques et tableaux de bord nationaux
"""
from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required
from database import db
from models.exploitation import Exploitation
from models.region import Region, Prefecture, Commune
from models.analyse_sol import AnalyseSol
from models.intrant import Intrant
from models.recolte import Recolte
from sqlalchemy import func, and_
from datetime import datetime, timedelta

statistiques_bp = Blueprint('statistiques', __name__)

# ========== STATISTIQUES NATIONALES ==========

@statistiques_bp.route('/nationales', methods=['GET'])
@jwt_required()
def get_statistiques_nationales():
    """Statistiques agrégées au niveau national"""
    try:
        # Nombre total d'exploitations
        total_exploitations = Exploitation.query.count()
        
        # Superficie totale cultivée
        superficie_totale = db.session.query(func.sum(Exploitation.superficie_totale)).scalar() or 0
        
        # Répartition par type de culture
        cultures = db.session.query(
            Exploitation.type_culture_principal,
            func.count(Exploitation.id).label('count'),
            func.sum(Exploitation.superficie_totale).label('superficie')
        ).filter(Exploitation.type_culture_principal.isnot(None)).group_by(Exploitation.type_culture_principal).all()
        
        repartition_cultures = [
            {
                'culture': c[0],
                'nombre_exploitations': c[1],
                'superficie_totale': float(c[2]) if c[2] else 0
            }
            for c in cultures
        ]
        
        # Répartition par région
        regions_stats = db.session.query(
            Region.nom,
            func.count(Exploitation.id).label('count'),
            func.sum(Exploitation.superficie_totale).label('superficie')
        ).outerjoin(Exploitation, Region.id == Exploitation.region_id).group_by(Region.id, Region.nom).all()
        
        repartition_regions = [
            {
                'region': r[0],
                'nombre_exploitations': r[1],
                'superficie_totale': float(r[2]) if r[2] else 0
            }
            for r in regions_stats
        ]
        
        # Nombre total d'analyses de sol
        total_analyses = AnalyseSol.query.count()
        
        # Nombre total d'intrants
        total_intrants = Intrant.query.count()
        
        # Nombre total de récoltes
        total_recoltes = Recolte.query.count()
        
        return jsonify({
            'total_exploitations': total_exploitations,
            'superficie_totale_cultivee': float(superficie_totale),
            'repartition_par_culture': repartition_cultures,
            'repartition_par_region': repartition_regions,
            'total_analyses_sol': total_analyses,
            'total_intrants': total_intrants,
            'total_recoltes': total_recoltes,
            'date_calcul': datetime.utcnow().isoformat()
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ========== STATISTIQUES RÉGIONALES ==========

@statistiques_bp.route('/regionales/<int:region_id>', methods=['GET'])
@jwt_required()
def get_statistiques_regionales(region_id):
    """Statistiques pour une région spécifique"""
    try:
        region = Region.query.get(region_id)
        if not region:
            return jsonify({'error': 'Région non trouvée'}), 404
        
        # Exploitations de la région
        exploitations = Exploitation.query.filter_by(region_id=region_id).all()
        total_exploitations = len(exploitations)
        superficie_totale = sum(e.superficie_totale for e in exploitations)
        
        # Répartition par préfecture
        prefectures_stats = []
        for prefecture in region.prefectures:
            prefecture_exploitations = Exploitation.query.filter_by(prefecture_id=prefecture.id).all()
            prefectures_stats.append({
                'prefecture_id': prefecture.id,
                'prefecture_nom': prefecture.nom,
                'nombre_exploitations': len(prefecture_exploitations),
                'superficie_totale': sum(e.superficie_totale for e in prefecture_exploitations)
            })
        
        # Répartition par culture
        cultures = {}
        for exploitation in exploitations:
            if exploitation.type_culture_principal:
                if exploitation.type_culture_principal not in cultures:
                    cultures[exploitation.type_culture_principal] = {
                        'nombre': 0,
                        'superficie': 0
                    }
                cultures[exploitation.type_culture_principal]['nombre'] += 1
                cultures[exploitation.type_culture_principal]['superficie'] += exploitation.superficie_totale
        
        repartition_cultures = [
            {'culture': k, **v} for k, v in cultures.items()
        ]
        
        # Analyses de sol dans la région
        exploitation_ids = [e.id for e in exploitations]
        total_analyses = AnalyseSol.query.filter(AnalyseSol.exploitation_id.in_(exploitation_ids)).count()
        
        return jsonify({
            'region': region.to_dict(),
            'total_exploitations': total_exploitations,
            'superficie_totale_cultivee': superficie_totale,
            'repartition_par_prefecture': prefectures_stats,
            'repartition_par_culture': repartition_cultures,
            'total_analyses_sol': total_analyses,
            'date_calcul': datetime.utcnow().isoformat()
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ========== COMPARAISON INTER-RÉGIONS ==========

@statistiques_bp.route('/comparaison-regions', methods=['GET'])
@jwt_required()
def comparer_regions():
    """Compare les statistiques entre toutes les régions"""
    try:
        regions = Region.query.all()
        comparaison = []
        
        for region in regions:
            exploitations = Exploitation.query.filter_by(region_id=region.id).all()
            superficie_totale = sum(e.superficie_totale for e in exploitations)
            
            # Moyenne de superficie par exploitation
            superficie_moyenne = superficie_totale / len(exploitations) if exploitations else 0
            
            # Types de cultures les plus fréquents
            cultures = {}
            for e in exploitations:
                if e.type_culture_principal:
                    cultures[e.type_culture_principal] = cultures.get(e.type_culture_principal, 0) + 1
            
            culture_principale = max(cultures.items(), key=lambda x: x[1])[0] if cultures else None
            
            comparaison.append({
                'region_id': region.id,
                'region_nom': region.nom,
                'region_code': region.code,
                'nombre_exploitations': len(exploitations),
                'superficie_totale': superficie_totale,
                'superficie_moyenne_par_exploitation': superficie_moyenne,
                'culture_principale': culture_principale,
                'pourcentage_superficie_nationale': 0  # Sera calculé côté client
            })
        
        # Calculer les pourcentages
        superficie_nationale = sum(c['superficie_totale'] for c in comparaison)
        for item in comparaison:
            if superficie_nationale > 0:
                item['pourcentage_superficie_nationale'] = (item['superficie_totale'] / superficie_nationale) * 100
        
        return jsonify({
            'comparaison': comparaison,
            'superficie_nationale_totale': superficie_nationale,
            'date_calcul': datetime.utcnow().isoformat()
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ========== STATISTIQUES PAR PRÉFECTURE ==========

@statistiques_bp.route('/prefectures/<int:prefecture_id>', methods=['GET'])
@jwt_required()
def get_statistiques_prefecture(prefecture_id):
    """Statistiques pour une préfecture spécifique"""
    try:
        prefecture = Prefecture.query.get(prefecture_id)
        if not prefecture:
            return jsonify({'error': 'Préfecture non trouvée'}), 404
        
        exploitations = Exploitation.query.filter_by(prefecture_id=prefecture_id).all()
        superficie_totale = sum(e.superficie_totale for e in exploitations)
        
        # Répartition par commune
        communes_stats = []
        for commune in prefecture.communes:
            commune_exploitations = Exploitation.query.filter_by(commune_id=commune.id).all()
            communes_stats.append({
                'commune_id': commune.id,
                'commune_nom': commune.nom,
                'nombre_exploitations': len(commune_exploitations),
                'superficie_totale': sum(e.superficie_totale for e in commune_exploitations)
            })
        
        return jsonify({
            'prefecture': prefecture.to_dict(),
            'total_exploitations': len(exploitations),
            'superficie_totale_cultivee': superficie_totale,
            'repartition_par_commune': communes_stats,
            'date_calcul': datetime.utcnow().isoformat()
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ========== ÉVOLUTION TEMPORELLE ==========

@statistiques_bp.route('/evolution', methods=['GET'])
@jwt_required()
def get_evolution_temporelle():
    """Évolution des statistiques dans le temps"""
    try:
        # Paramètres de période
        periode = request.args.get('periode', 'annee')  # annee, mois, semaine
        region_id = request.args.get('region_id', type=int)
        
        # Calculer la période
        if periode == 'annee':
            # 5 dernières années
            dates = [datetime.now() - timedelta(days=365*i) for i in range(5, 0, -1)]
        elif periode == 'mois':
            # 12 derniers mois
            dates = [datetime.now() - timedelta(days=30*i) for i in range(12, 0, -1)]
        else:
            # 4 dernières semaines
            dates = [datetime.now() - timedelta(weeks=i) for i in range(4, 0, -1)]
        
        evolution = []
        query = Exploitation.query
        
        if region_id:
            query = query.filter_by(region_id=region_id)
        
        for date in dates:
            exploitations_avant = query.filter(Exploitation.created_at <= date).count()
            evolution.append({
                'date': date.isoformat(),
                'nombre_exploitations': exploitations_avant
            })
        
        return jsonify({
            'periode': periode,
            'evolution': evolution,
            'region_id': region_id
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

