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

