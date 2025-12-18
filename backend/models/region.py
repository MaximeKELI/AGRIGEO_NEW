"""
Modèles pour la structure géographique hiérarchique
"""
from database import db
from datetime import datetime

class Region(db.Model):
    """Région administrative (ex: Maritime, Plateaux, Centrale, etc.)"""
    __tablename__ = 'regions'
    
    id = db.Column(db.Integer, primary_key=True)
    nom = db.Column(db.String(100), nullable=False)
    code = db.Column(db.String(10), unique=True)  # Code ISO ou national
    superficie = db.Column(db.Float)  # en km²
    chef_lieu = db.Column(db.String(100))
    latitude = db.Column(db.Float)  # Coordonnées du chef-lieu
    longitude = db.Column(db.Float)
    description = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relations
    prefectures = db.relationship('Prefecture', backref='region', lazy=True, cascade='all, delete-orphan')
    exploitations = db.relationship('Exploitation', backref='region', lazy=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'nom': self.nom,
            'code': self.code,
            'superficie': self.superficie,
            'chef_lieu': self.chef_lieu,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'description': self.description,
            'prefectures_count': len(self.prefectures) if self.prefectures else 0,
            'exploitations_count': len(self.exploitations) if self.exploitations else 0,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }

class Prefecture(db.Model):
    """Préfecture (sous-division de région)"""
    __tablename__ = 'prefectures'
    
    id = db.Column(db.Integer, primary_key=True)
    nom = db.Column(db.String(100), nullable=False)
    code = db.Column(db.String(10), unique=True)
    region_id = db.Column(db.Integer, db.ForeignKey('regions.id'), nullable=False)
    superficie = db.Column(db.Float)  # en km²
    chef_lieu = db.Column(db.String(100))
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    description = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relations
    communes = db.relationship('Commune', backref='prefecture', lazy=True, cascade='all, delete-orphan')
    exploitations = db.relationship('Exploitation', backref='prefecture', lazy=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'nom': self.nom,
            'code': self.code,
            'region_id': self.region_id,
            'region_nom': self.region.nom if self.region else None,
            'superficie': self.superficie,
            'chef_lieu': self.chef_lieu,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'description': self.description,
            'communes_count': len(self.communes) if self.communes else 0,
            'exploitations_count': len(self.exploitations) if self.exploitations else 0,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }

class Commune(db.Model):
    """Commune (sous-division de préfecture)"""
    __tablename__ = 'communes'
    
    id = db.Column(db.Integer, primary_key=True)
    nom = db.Column(db.String(100), nullable=False)
    code = db.Column(db.String(10), unique=True)
    prefecture_id = db.Column(db.Integer, db.ForeignKey('prefectures.id'), nullable=False)
    superficie = db.Column(db.Float)  # en km²
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    description = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relations
    exploitations = db.relationship('Exploitation', backref='commune', lazy=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'nom': self.nom,
            'code': self.code,
            'prefecture_id': self.prefecture_id,
            'prefecture_nom': self.prefecture.nom if self.prefecture else None,
            'region_id': self.prefecture.region_id if self.prefecture else None,
            'region_nom': self.prefecture.region.nom if self.prefecture and self.prefecture.region else None,
            'superficie': self.superficie,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'description': self.description,
            'exploitations_count': len(self.exploitations) if self.exploitations else 0,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }




