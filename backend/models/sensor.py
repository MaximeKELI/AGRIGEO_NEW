"""
Modèle pour les capteurs IoT
"""
from database import db
from datetime import datetime
import json

class Sensor(db.Model):
    """Capteur IoT pour l'agriculture"""
    __tablename__ = 'sensors'
    
    id = db.Column(db.Integer, primary_key=True)
    sensor_id = db.Column(db.String(100), unique=True, nullable=False)  # ID unique du capteur
    sensor_name = db.Column(db.String(200), nullable=False)
    sensor_type = db.Column(db.String(50), nullable=False)  # soil_moisture, ph, temperature, nutrients, etc.
    description = db.Column(db.Text)
    parcelle_id = db.Column(db.Integer, db.ForeignKey('parcelles.id'))
    exploitation_id = db.Column(db.Integer, db.ForeignKey('exploitations.id'))
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    is_active = db.Column(db.Boolean, default=True)
    last_reading = db.Column(db.DateTime)
    battery_level = db.Column(db.Integer)  # Pourcentage
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'sensor_id': self.sensor_id,
            'sensor_name': self.sensor_name,
            'sensor_type': self.sensor_type,
            'description': self.description,
            'parcelle_id': self.parcelle_id,
            'exploitation_id': self.exploitation_id,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'is_active': self.is_active,
            'last_reading': self.last_reading.isoformat() if self.last_reading else None,
            'battery_level': self.battery_level,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class SensorData(db.Model):
    """Données brutes des capteurs"""
    __tablename__ = 'sensor_data'
    
    id = db.Column(db.Integer, primary_key=True)
    sensor_id = db.Column(db.String(100), db.ForeignKey('sensors.sensor_id'), nullable=False)
    sensor_type = db.Column(db.String(50), nullable=False)
    value = db.Column(db.Float, nullable=False)
    unit = db.Column(db.String(20), nullable=False)
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    parcelle_id = db.Column(db.Integer, db.ForeignKey('parcelles.id'))
    exploitation_id = db.Column(db.Integer, db.ForeignKey('exploitations.id'))
    timestamp = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    battery_level = db.Column(db.Integer)
    signal_strength = db.Column(db.Integer)  # dBm
    sensor_metadata = db.Column(db.Text)  # JSON (renommé car 'metadata' est réservé dans SQLAlchemy)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        metadata_dict = None
        if self.sensor_metadata:
            try:
                metadata_dict = json.loads(self.sensor_metadata)
            except:
                metadata_dict = None
        
        return {
            'id': self.id,
            'sensor_id': self.sensor_id,
            'sensor_type': self.sensor_type,
            'value': self.value,
            'unit': self.unit,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'parcelle_id': self.parcelle_id,
            'exploitation_id': self.exploitation_id,
            'timestamp': self.timestamp.isoformat() if self.timestamp else None,
            'battery_level': self.battery_level,
            'signal_strength': self.signal_strength,
            'metadata': metadata_dict,  # On garde 'metadata' dans le JSON de sortie
            'created_at': self.created_at.isoformat() if self.created_at else None
        }

