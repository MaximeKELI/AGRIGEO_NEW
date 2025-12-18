"""
Service pour récupérer les données météo depuis OpenWeatherMap API
"""
import os
import requests
from typing import Dict, List, Optional
from datetime import datetime, date
from collections import defaultdict


def get_api_key() -> str:
    """Récupère la clé API OpenWeatherMap depuis les variables d'environnement"""
    api_key = os.getenv('OPENWEATHER_API_KEY')
    if not api_key:
        raise ValueError('OPENWEATHER_API_KEY non configurée dans les variables d\'environnement')
    return api_key


def get_current_weather(latitude: float, longitude: float, lang: str = 'fr') -> Dict:
    """
    Récupère les conditions météo actuelles pour des coordonnées données
    
    Args:
        latitude: Latitude en degrés décimaux
        longitude: Longitude en degrés décimaux
        lang: Langue pour la description (fr, en, etc.)
    
    Returns:
        Dictionnaire avec les données météo formatées
    """
    api_key = get_api_key()
    base_url = 'https://api.openweathermap.org/data/2.5/weather'
    
    params = {
        'lat': latitude,
        'lon': longitude,
        'appid': api_key,
        'units': 'metric',  # Température en Celsius
        'lang': lang
    }
    
    try:
        response = requests.get(base_url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        # Vérifier si l'API retourne une erreur
        if response.status_code != 200:
            error_msg = data.get('message', 'Erreur inconnue de l\'API OpenWeather')
            raise Exception(f'Erreur API OpenWeather: {error_msg}')
        
        # Formater les données au format attendu par l'application
        main = data.get('main', {})
        weather = data.get('weather', [{}])[0]
        wind = data.get('wind', {})
        rain = data.get('rain', {})
        clouds = data.get('clouds', {})
        
        return {
            'temperature': main.get('temp'),
            'temperature_min': main.get('temp_min'),
            'temperature_max': main.get('temp_max'),
            'humidite': main.get('humidity'),  # En %
            'pression': main.get('pressure'),  # En hPa
            'vitesse_vent': wind.get('speed'),  # En m/s
            'direction_vent': wind.get('deg'),  # En degrés
            'description': weather.get('description'),
            'icon': weather.get('icon'),
            'pluviometrie': rain.get('1h') or rain.get('3h') or 0,  # En mm
            'nuages': clouds.get('all'),  # En %
            'date': datetime.utcnow().isoformat(),
            'latitude': latitude,
            'longitude': longitude,
            'ville': data.get('name'),
            'pays': data.get('sys', {}).get('country')
        }
    except requests.exceptions.Timeout:
        raise Exception('Timeout lors de la connexion à l\'API OpenWeather. Veuillez réessayer.')
    except requests.exceptions.ConnectionError:
        raise Exception('Erreur de connexion à l\'API OpenWeather. Vérifiez votre connexion internet.')
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 401:
            raise ValueError('Clé API OpenWeather invalide. Vérifiez votre clé API.')
        elif e.response.status_code == 404:
            raise ValueError('Localisation non trouvée. Vérifiez les coordonnées.')
        else:
            error_data = e.response.json() if e.response.text else {}
            error_msg = error_data.get('message', f'Erreur HTTP {e.response.status_code}')
            raise Exception(f'Erreur API OpenWeather: {error_msg}')
    except requests.exceptions.RequestException as e:
        raise Exception(f'Erreur lors de la récupération de la météo: {str(e)}')
    except (KeyError, ValueError) as e:
        raise Exception(f'Format de réponse inattendu de l\'API: {str(e)}')


def get_weather_forecast(latitude: float, longitude: float, lang: str = 'fr') -> List[Dict]:
    """
    Récupère les prévisions météo pour les 5 prochains jours (3h par 3h)
    
    Args:
        latitude: Latitude en degrés décimaux
        longitude: Longitude en degrés décimaux
        lang: Langue pour la description (fr, en, etc.)
    
    Returns:
        Liste de dictionnaires avec les prévisions formatées
    """
    api_key = get_api_key()
    base_url = 'https://api.openweathermap.org/data/2.5/forecast'
    
    params = {
        'lat': latitude,
        'lon': longitude,
        'appid': api_key,
        'units': 'metric',  # Température en Celsius
        'lang': lang
    }
    
    try:
        response = requests.get(base_url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        previsions = []
        for item in data.get('list', []):
            main = item.get('main', {})
            weather = item.get('weather', [{}])[0]
            wind = item.get('wind', {})
            rain = item.get('rain', {})
            clouds = item.get('clouds', {})
            
            # Convertir le timestamp en datetime
            dt_timestamp = item.get('dt')
            date = datetime.fromtimestamp(dt_timestamp) if dt_timestamp else None
            
            previsions.append({
                'temperature': main.get('temp'),
                'temperature_min': main.get('temp_min'),
                'temperature_max': main.get('temp_max'),
                'humidite': main.get('humidity'),
                'pression': main.get('pressure'),
                'vitesse_vent': wind.get('speed'),
                'direction_vent': wind.get('deg'),
                'description': weather.get('description'),
                'icon': weather.get('icon'),
                'pluviometrie': rain.get('3h') or 0,  # Prévisions en 3h
                'nuages': clouds.get('all'),
                'date': date.isoformat() if date else None,
                'latitude': latitude,
                'longitude': longitude
            })
        
        return previsions
    except requests.exceptions.Timeout:
        raise Exception('Timeout lors de la connexion à l\'API OpenWeather. Veuillez réessayer.')
    except requests.exceptions.ConnectionError:
        raise Exception('Erreur de connexion à l\'API OpenWeather. Vérifiez votre connexion internet.')
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 401:
            raise ValueError('Clé API OpenWeather invalide. Vérifiez votre clé API.')
        elif e.response.status_code == 404:
            raise ValueError('Localisation non trouvée. Vérifiez les coordonnées.')
        else:
            error_data = e.response.json() if e.response.text else {}
            error_msg = error_data.get('message', f'Erreur HTTP {e.response.status_code}')
            raise Exception(f'Erreur API OpenWeather: {error_msg}')
    except requests.exceptions.RequestException as e:
        raise Exception(f'Erreur lors de la récupération des prévisions: {str(e)}')
    except (KeyError, ValueError) as e:
        raise Exception(f'Format de réponse inattendu de l\'API: {str(e)}')


def get_weather_by_city(city_name: str, country_code: Optional[str] = None, lang: str = 'fr') -> Dict:
    """
    Récupère les conditions météo actuelles par nom de ville
    
    Args:
        city_name: Nom de la ville
        country_code: Code pays (optionnel, ex: 'FR', 'US')
        lang: Langue pour la description
    
    Returns:
        Dictionnaire avec les données météo formatées
    """
    api_key = get_api_key()
    base_url = 'https://api.openweathermap.org/data/2.5/weather'
    
    # Construire le paramètre q (query)
    query = city_name
    if country_code:
        query = f'{city_name},{country_code}'
    
    params = {
        'q': query,
        'appid': api_key,
        'units': 'metric',
        'lang': lang
    }
    
    try:
        response = requests.get(base_url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        main = data.get('main', {})
        weather = data.get('weather', [{}])[0]
        wind = data.get('wind', {})
        rain = data.get('rain', {})
        clouds = data.get('clouds', {})
        coord = data.get('coord', {})
        
        return {
            'temperature': main.get('temp'),
            'temperature_min': main.get('temp_min'),
            'temperature_max': main.get('temp_max'),
            'humidite': main.get('humidity'),
            'pression': main.get('pressure'),
            'vitesse_vent': wind.get('speed'),
            'direction_vent': wind.get('deg'),
            'description': weather.get('description'),
            'icon': weather.get('icon'),
            'pluviometrie': rain.get('1h') or rain.get('3h') or 0,
            'nuages': clouds.get('all'),
            'date': datetime.utcnow().isoformat(),
            'latitude': coord.get('lat'),
            'longitude': coord.get('lon'),
            'ville': data.get('name'),
            'pays': data.get('sys', {}).get('country')
        }
    except requests.exceptions.Timeout:
        raise Exception('Timeout lors de la connexion à l\'API OpenWeather. Veuillez réessayer.')
    except requests.exceptions.ConnectionError:
        raise Exception('Erreur de connexion à l\'API OpenWeather. Vérifiez votre connexion internet.')
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 401:
            raise ValueError('Clé API OpenWeather invalide. Vérifiez votre clé API.')
        elif e.response.status_code == 404:
            raise ValueError(f'Ville "{city_name}" non trouvée. Vérifiez le nom de la ville.')
        else:
            error_data = e.response.json() if e.response.text else {}
            error_msg = error_data.get('message', f'Erreur HTTP {e.response.status_code}')
            raise Exception(f'Erreur API OpenWeather: {error_msg}')
    except requests.exceptions.RequestException as e:
        raise Exception(f'Erreur lors de la récupération de la météo: {str(e)}')
    except (KeyError, ValueError) as e:
        raise Exception(f'Format de réponse inattendu de l\'API: {str(e)}')


def group_forecasts_by_day(previsions: List[Dict]) -> List[Dict]:
    """
    Groupe les prévisions météo par jour (une prévision par jour avec min/max)
    
    Args:
        previsions: Liste des prévisions horaires (3h par 3h)
    
    Returns:
        Liste de prévisions groupées par jour avec températures min/max
    """
    if not previsions:
        return []
    
    # Grouper par jour
    forecasts_by_day = defaultdict(list)
    
    for prev in previsions:
        if prev.get('date'):
            try:
                prev_date = datetime.fromisoformat(prev['date'].replace('Z', '+00:00'))
                day_key = prev_date.date()
                forecasts_by_day[day_key].append(prev)
            except (ValueError, AttributeError):
                continue
    
    # Créer une prévision par jour avec min/max
    daily_forecasts = []
    for day, day_forecasts in sorted(forecasts_by_day.items()):
        if not day_forecasts:
            continue
        
        # Calculer les températures min/max du jour
        temps = [f.get('temperature') for f in day_forecasts if f.get('temperature') is not None]
        temp_mins = [f.get('temperature_min') for f in day_forecasts if f.get('temperature_min') is not None]
        temp_maxs = [f.get('temperature_max') for f in day_forecasts if f.get('temperature_max') is not None]
        
        # Prendre la prévision de la mi-journée (12h) comme référence
        midday_forecast = None
        for f in day_forecasts:
            try:
                f_date = datetime.fromisoformat(f['date'].replace('Z', '+00:00'))
                if 10 <= f_date.hour <= 14:
                    midday_forecast = f
                    break
            except (ValueError, AttributeError):
                continue
        
        if not midday_forecast:
            midday_forecast = day_forecasts[len(day_forecasts) // 2]
        
        # Somme des précipitations du jour
        total_rain = sum(f.get('pluviometrie', 0) or 0 for f in day_forecasts)
        
        daily_forecasts.append({
            'date': day.isoformat(),
            'temperature': max(temps) if temps else midday_forecast.get('temperature'),
            'temperature_min': min(temp_mins) if temp_mins else min(temps) if temps else midday_forecast.get('temperature_min'),
            'temperature_max': max(temp_maxs) if temp_maxs else max(temps) if temps else midday_forecast.get('temperature_max'),
            'humidite': midday_forecast.get('humidite'),
            'pression': midday_forecast.get('pression'),
            'vitesse_vent': midday_forecast.get('vitesse_vent'),
            'direction_vent': midday_forecast.get('direction_vent'),
            'description': midday_forecast.get('description'),
            'icon': midday_forecast.get('icon'),
            'pluviometrie': total_rain,
            'nuages': midday_forecast.get('nuages'),
            'latitude': midday_forecast.get('latitude'),
            'longitude': midday_forecast.get('longitude'),
        })
    
    return daily_forecasts
