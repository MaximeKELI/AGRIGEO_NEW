# 🤖 Chatbot IA Agricole - AGRIGEO

## 📋 Vue d'ensemble

Un chatbot IA spécialisé exclusivement en agriculture, utilisant l'API Gemini de Google. Le chatbot est intégré dans l'application et peut accéder au contexte des exploitations pour donner des conseils personnalisés.

## 🔧 Configuration

### Clé API Gemini

La clé API est déjà configurée dans le code :
- Clé : `AIzaSyCwt5NygybBr9oasALOG7Ht-XhM2Dk-sIk`
- Configurée automatiquement au démarrage de l'application

## 🎯 Fonctionnalités

### 1. Spécialisation Agricole

Le chatbot est **strictement limité** à l'agriculture :
- ✅ Gestion des sols
- ✅ Recommandations d'irrigation
- ✅ Gestion des intrants
- ✅ Analyse des données de sol
- ✅ Planification des cultures
- ✅ Pratiques agricoles durables
- ✅ Agriculture au Togo et en Afrique
- ❌ Refuse de répondre aux questions non-agricoles

### 2. Contexte Intelligent

Le chatbot utilise automatiquement :
- **Données de l'exploitation** : nom, superficie, type de culture
- **Dernière analyse de sol** : pH, nutriments (N, P, K)
- **Données météo** : température, pluviométrie, humidité

### 3. Interface Utilisateur

- **Écran de chat** dédié avec bulles de messages
- **Historique de conversation** conservé pendant la session
- **Messages de chargement** pendant la génération
- **Bouton d'effacement** pour recommencer
- **Intégration** dans la navigation principale et l'écran d'exploitation

## 📱 Utilisation

### Depuis la Navigation Principale

1. Accéder à l'onglet "Assistant" dans la barre de navigation
2. Le chatbot affiche un message de bienvenue
3. Poser une question sur l'agriculture
4. Recevoir une réponse contextuelle

### Depuis une Exploitation

1. Ouvrir les détails d'une exploitation
2. Cliquer sur "Assistant Agricole IA"
3. Le chatbot a accès au contexte de l'exploitation
4. Poser des questions spécifiques à cette exploitation

## 💬 Exemples de Questions

- "Quel est le pH optimal pour le maïs ?"
- "Dois-je irriguer aujourd'hui ?"
- "Comment améliorer la teneur en azote de mon sol ?"
- "Quels intrants recommandez-vous pour le coton ?"
- "Quand dois-je planter mes cultures ?"
- "Comment gérer l'irrigation avec cette météo ?"

## 🧠 Logique du Chatbot

### Prompt Système

Le chatbot reçoit un prompt système qui :
1. Le limite strictement à l'agriculture
2. Lui donne accès au contexte de l'application
3. Lui demande de rediriger les questions non-agricoles

### Contexte Dynamique

Le contexte est construit dynamiquement avec :
- Informations de l'exploitation active
- Dernière analyse de sol disponible
- Données météo actuelles

### Historique de Conversation

- L'historique est conservé pendant la session
- Permet des conversations contextuelles
- Peut être effacé avec le bouton dédié

## 🔐 Sécurité

- La clé API est intégrée dans le code (peut être déplacée vers les préférences)
- Les données de contexte sont locales uniquement
- Aucune donnée personnelle n'est envoyée à Gemini

## 📊 Architecture

### Modèles
- `ChatMessageModel` : Modèle pour les messages
- `MessageRole` : Enum pour les rôles (user, assistant, system)

### Services
- `GeminiService` : Communication avec l'API Gemini
- Gestion du contexte et de l'historique

### Repositories
- `ChatRepository` : Abstraction de la couche service

### Providers
- `ChatProvider` : Gestion d'état du chat
- Intégration avec les autres providers pour le contexte

### Écrans
- `ChatScreen` : Interface de chat complète
- Intégration dans `HomeScreen` et `ExploitationDetailScreen`

## 🎨 Interface

- **Messages utilisateur** : Bulles vertes à droite
- **Messages assistant** : Bulles grises à gauche avec icône agriculture
- **Chargement** : Indicateur pendant la génération
- **Horodatage** : Heure d'envoi de chaque message
- **Scroll automatique** : Vers le dernier message

## ⚙️ Configuration Technique

### API Gemini

- **Modèle** : `gemini-pro`
- **Endpoint** : `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent`
- **Paramètres** :
  - Temperature: 0.7
  - TopK: 40
  - TopP: 0.95
  - MaxOutputTokens: 1024

### Gestion des Erreurs

- Messages d'erreur clairs pour l'utilisateur
- Retry automatique possible
- Gestion gracieuse des erreurs réseau

## 🚀 Améliorations Futures

- Sauvegarde de l'historique de conversation
- Suggestions de questions fréquentes
- Mode voix pour les agriculteurs
- Traduction en langues locales
- Intégration avec les recommandations existantes

---

**Le chatbot est maintenant opérationnel et prêt à aider les agriculteurs !** 🌾🤖

