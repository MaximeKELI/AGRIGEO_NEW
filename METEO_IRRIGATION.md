# 🌤️ Fonctionnalité Météo et Conseils d'Irrigation

## 📋 Vue d'ensemble

Cette fonctionnalité ajoute :
1. **Intégration OpenWeather API** pour récupérer les données météo
2. **Conseils d'irrigation intelligents** basés sur la météo réelle
3. **Prévisions météo** pour planifier l'irrigation

## 🔧 Configuration

### 1. Clé API OpenWeather

Vous devez obtenir une clé API gratuite depuis : https://openweathermap.org/api

Une fois obtenue, configurez-la dans l'application :

```dart
// Dans votre code d'initialisation
final meteoProvider = Provider.of<MeteoProvider>(context, listen: false);
meteoProvider.setApiKey('VOTRE_CLE_API');
```

Ou stockez-la dans les préférences partagées pour la réutiliser.

### 2. Coordonnées GPS

Les exploitations doivent avoir des coordonnées GPS (latitude/longitude) pour utiliser la météo.

## 📱 Fonctionnalités

### 1. Écran Météo (`MeteoScreen`)

- **Météo actuelle** :
  - Température actuelle, min/max
  - Humidité relative
  - Vitesse du vent
  - Pluviométrie actuelle
  - Description et icône météo

- **Prévisions** :
  - Prévisions sur 24h (8 périodes de 3h)
  - Température prévue
  - Pluviométrie prévue
  - Conditions météo

### 2. Conseils d'Irrigation (`ConseilsIrrigationScreen`)

Les conseils sont générés par l'IA backend basée sur :

- **Données météo actuelles** : température, humidité, pluviométrie
- **Prévisions météo** : pluviométrie prévue sur 24h et 48h
- **Type de culture** : besoins en eau spécifiques
- **Déficit hydrique calculé** : différence entre besoins et pluviométrie

### 3. Types de Conseils

1. **Irrigation urgente** (priorité élevée)
   - Déficit hydrique > 5 mm
   - Irrigation immédiate recommandée

2. **Irrigation recommandée** (priorité moyenne)
   - Déficit hydrique modéré (2-5 mm)
   - Irrigation complémentaire

3. **Irrigation non nécessaire** (priorité faible)
   - Pluviométrie suffisante
   - Aucune irrigation supplémentaire

4. **Irrigation de rafraîchissement**
   - Température > 35°C
   - Réduction du stress thermique

5. **Irrigation pour humidité**
   - Humidité relative < 40%
   - Compensation de l'évapotranspiration

6. **Planification irrigation**
   - Analyse sur 48h
   - Planification à moyen terme

## 🧠 Logique d'IA

### Calcul du Déficit Hydrique

```
Besoin eau 24h = Besoin journalier culture × 1 jour
Pluviométrie totale = Pluviométrie actuelle + Pluviométrie prévue 24h
Déficit hydrique = Besoin eau 24h - Pluviométrie totale
```

### Besoins en Eau par Culture

- Maïs : 5.0 mm/jour
- Riz : 8.0 mm/jour
- Coton : 6.0 mm/jour
- Manioc : 3.0 mm/jour
- Igname : 4.0 mm/jour
- Tomate : 4.5 mm/jour
- Haricot : 3.5 mm/jour
- Par défaut : 4.0 mm/jour

## 📊 Paramètres Utilisés

Chaque conseil indique les paramètres utilisés pour sa génération :
- Température actuelle
- Humidité relative
- Pluviométrie actuelle et prévue
- Type de culture
- Besoin en eau calculé
- Déficit hydrique calculé

## 🔄 Flux de Données

1. **Frontend** :
   - Récupère météo depuis OpenWeather API
   - Affiche météo actuelle et prévisions
   - Envoie données météo au backend pour conseils

2. **Backend** :
   - Reçoit données météo + type de culture
   - Calcule déficit hydrique
   - Génère conseils d'irrigation personnalisés
   - Retourne conseils avec paramètres utilisés

## 🎯 Utilisation

1. **Voir la météo** :
   - Accéder à l'onglet "Météo" dans la navigation
   - Sélectionner une exploitation avec coordonnées GPS
   - La météo se charge automatiquement

2. **Obtenir des conseils d'irrigation** :
   - Depuis l'écran météo, cliquer sur "Conseils d'irrigation"
   - Les conseils sont générés automatiquement
   - Consulter les détails de chaque conseil

3. **Actualiser les données** :
   - Utiliser le bouton refresh dans l'écran météo
   - Les données sont mises à jour depuis OpenWeather

## ⚠️ Notes Importantes

- **Aucune donnée par défaut** : Tous les conseils sont basés sur les données météo réelles
- **Traçabilité** : Chaque conseil indique les paramètres utilisés
- **Transparence** : La logique de calcul est explicite et déterministe
- **Coordonnées requises** : L'exploitation doit avoir des coordonnées GPS valides

## 🔐 Sécurité

- La clé API OpenWeather est stockée côté client
- Les données météo ne sont pas sauvegardées en base (optionnel)
- Les conseils sont générés à la demande, pas stockés

## 📈 Améliorations Futures

- Cache des données météo
- Historique des conseils d'irrigation
- Notifications pour irrigation urgente
- Intégration avec système d'irrigation automatique
- Statistiques d'irrigation




