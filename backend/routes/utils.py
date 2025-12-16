"""
Utilitaires pour les routes API
"""
from flask import request

def get_pagination_params():
    """Récupère les paramètres de pagination depuis la requête"""
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 50, type=int)
    
    # Limiter per_page à 100 maximum
    if per_page > 100:
        per_page = 100
    if per_page < 1:
        per_page = 1
    
    return page, per_page

def paginate_query(query, page, per_page):
    """Pagine une requête SQLAlchemy"""
    pagination = query.paginate(
        page=page,
        per_page=per_page,
        error_out=False
    )
    
    return {
        'items': [item.to_dict() for item in pagination.items],
        'total': pagination.total,
        'page': page,
        'per_page': per_page,
        'pages': pagination.pages,
        'has_next': pagination.has_next,
        'has_prev': pagination.has_prev,
    }

