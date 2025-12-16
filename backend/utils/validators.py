"""
Validateurs pour les données utilisateur
"""
def validate_user_data(data):
    """Valide les données d'un utilisateur"""
    errors = []
    
    if not data.get('username'):
        errors.append('Le username est requis')
    elif len(data['username']) < 3:
        errors.append('Le username doit contenir au moins 3 caractères')
    
    if not data.get('email'):
        errors.append('L\'email est requis')
    elif '@' not in data['email']:
        errors.append('Email invalide')
    
    if not data.get('password'):
        errors.append('Le mot de passe est requis')
    elif len(data['password']) < 6:
        errors.append('Le mot de passe doit contenir au moins 6 caractères')
    
    if not data.get('role_id'):
        errors.append('Le rôle est requis')
    
    return errors

def validate_exploitation_data(data):
    """Valide les données d'une exploitation"""
    errors = []
    
    if not data.get('nom'):
        errors.append('Le nom de l\'exploitation est requis')
    elif len(data['nom']) < 2:
        errors.append('Le nom doit contenir au moins 2 caractères')
    
    if not data.get('superficie_totale'):
        errors.append('La superficie totale est requise')
    else:
        try:
            superficie = float(data['superficie_totale'])
            if superficie <= 0:
                errors.append('La superficie doit être supérieure à 0')
            if superficie > 100000:  # 100 000 ha = limite raisonnable
                errors.append('La superficie semble invalide')
        except (ValueError, TypeError):
            errors.append('La superficie doit être un nombre valide')
    
    if data.get('latitude') is not None:
        try:
            lat = float(data['latitude'])
            if lat < -90 or lat > 90:
                errors.append('La latitude doit être entre -90 et 90')
        except (ValueError, TypeError):
            errors.append('La latitude doit être un nombre valide')
    
    if data.get('longitude') is not None:
        try:
            lon = float(data['longitude'])
            if lon < -180 or lon > 180:
                errors.append('La longitude doit être entre -180 et 180')
        except (ValueError, TypeError):
            errors.append('La longitude doit être un nombre valide')
    
    return errors

def validate_analyse_sol_data(data):
    """Valide les données d'une analyse de sol"""
    errors = []
    
    if not data.get('date_prelevement'):
        errors.append('La date de prélèvement est requise')
    
    if not data.get('exploitation_id'):
        errors.append('L\'exploitation est requise')
    
    # Validation pH
    if data.get('ph') is not None:
        try:
            ph = float(data['ph'])
            if ph < 0 or ph > 14:
                errors.append('Le pH doit être entre 0 et 14')
        except (ValueError, TypeError):
            errors.append('Le pH doit être un nombre valide')
    
    # Validation humidité
    if data.get('humidite') is not None:
        try:
            hum = float(data['humidite'])
            if hum < 0 or hum > 100:
                errors.append('L\'humidité doit être entre 0 et 100%')
        except (ValueError, TypeError):
            errors.append('L\'humidité doit être un nombre valide')
    
    # Validation nutriments (doivent être positifs)
    for nutrient in ['azote_n', 'phosphore_p', 'potassium_k']:
        if data.get(nutrient) is not None:
            try:
                value = float(data[nutrient])
                if value < 0:
                    errors.append(f'Le {nutrient} doit être positif')
            except (ValueError, TypeError):
                errors.append(f'Le {nutrient} doit être un nombre valide')
    
    return errors

def validate_intrant_data(data):
    """Valide les données d'un intrant"""
    errors = []
    
    if not data.get('type_intrant'):
        errors.append('Le type d\'intrant est requis')
    
    if not data.get('quantite'):
        errors.append('La quantité est requise')
    else:
        try:
            quantite = float(data['quantite'])
            if quantite <= 0:
                errors.append('La quantité doit être supérieure à 0')
        except (ValueError, TypeError):
            errors.append('La quantité doit être un nombre valide')
    
    if not data.get('date_application'):
        errors.append('La date d\'application est requise')
    
    if not data.get('exploitation_id'):
        errors.append('L\'exploitation est requise')
    
    return errors
