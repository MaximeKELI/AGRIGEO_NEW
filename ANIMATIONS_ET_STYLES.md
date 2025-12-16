# Animations et Styles - Documentation

## Vue d'ensemble

L'application AGRIGEO a été enrichie avec de nombreuses animations et effets visuels pour améliorer l'expérience utilisateur. Tous les widgets d'animation sont disponibles dans le dossier `lib/presentation/widgets/animations/`.

## Widgets d'animation disponibles

### 1. FadeInWidget
Animation de fondu entrant (fade in).

```dart
FadeInWidget(
  delay: Duration(milliseconds: 200),
  duration: Duration(milliseconds: 600),
  child: Text('Texte animé'),
)
```

**Paramètres :**
- `child` : Widget à animer (requis)
- `duration` : Durée de l'animation (défaut: 600ms)
- `delay` : Délai avant le début de l'animation (défaut: 0ms)
- `curve` : Courbe d'animation (défaut: Curves.easeOut)

### 2. SlideInWidget
Animation de glissement entrant depuis une direction.

```dart
SlideInWidget(
  delay: Duration(milliseconds: 300),
  direction: AxisDirection.left,
  child: Card(...),
)
```

**Paramètres :**
- `child` : Widget à animer (requis)
- `duration` : Durée de l'animation (défaut: 600ms)
- `delay` : Délai avant le début (défaut: 0ms)
- `direction` : Direction du glissement (up, down, left, right)
- `curve` : Courbe d'animation (défaut: Curves.easeOutCubic)

### 3. ScaleInWidget
Animation d'agrandissement entrant.

```dart
ScaleInWidget(
  delay: Duration(milliseconds: 200),
  beginScale: 0.5,
  child: Icon(Icons.star),
)
```

**Paramètres :**
- `child` : Widget à animer (requis)
- `duration` : Durée de l'animation (défaut: 500ms)
- `delay` : Délai avant le début (défaut: 0ms)
- `beginScale` : Échelle de départ (défaut: 0.5)
- `curve` : Courbe d'animation (défaut: Curves.elasticOut)

### 4. TypewriterTextWidget
Effet d'écriture progressive (machine à écrire).

```dart
TypewriterTextWidget(
  text: 'Bienvenue sur AGRIGEO',
  duration: Duration(milliseconds: 50),
  style: TextStyle(fontSize: 24),
)
```

**Paramètres :**
- `text` : Texte à afficher progressivement (requis)
- `duration` : Durée entre chaque caractère (défaut: 50ms)
- `style` : Style du texte
- `textAlign` : Alignement du texte
- `maxLines` : Nombre maximum de lignes

### 5. StaggeredListWidget
Liste avec animations décalées pour chaque élément.

```dart
StaggeredListWidget(
  staggerDuration: Duration(milliseconds: 100),
  children: [
    Card(...),
    Card(...),
    Card(...),
  ],
)
```

**Paramètres :**
- `children` : Liste des widgets à animer (requis)
- `staggerDuration` : Délai entre chaque élément (défaut: 100ms)
- `animationDuration` : Durée de chaque animation (défaut: 400ms)
- `direction` : Direction du glissement (défaut: down)

### 6. PulseWidget
Animation de pulsation continue.

```dart
PulseWidget(
  minScale: 0.95,
  maxScale: 1.05,
  child: Icon(Icons.notifications),
)
```

**Paramètres :**
- `child` : Widget à animer (requis)
- `duration` : Durée d'un cycle (défaut: 1000ms)
- `minScale` : Échelle minimale (défaut: 0.95)
- `maxScale` : Échelle maximale (défaut: 1.05)

### 7. ShimmerWidget
Effet de brillance (shimmer).

```dart
ShimmerWidget(
  baseColor: Colors.grey[300]!,
  highlightColor: Colors.white,
  child: Container(...),
)
```

**Paramètres :**
- `child` : Widget à animer (requis)
- `baseColor` : Couleur de base (défaut: gris clair)
- `highlightColor` : Couleur de surbrillance (défaut: blanc)
- `duration` : Durée de l'animation (défaut: 1500ms)

### 8. AnimatedButton
Bouton avec animations au survol et au clic.

```dart
AnimatedButton(
  text: 'Valider',
  icon: Icons.check,
  backgroundColor: Colors.green,
  onPressed: () => {},
  isLoading: false,
)
```

**Paramètres :**
- `text` : Texte du bouton (requis)
- `onPressed` : Callback au clic
- `icon` : Icône optionnelle
- `backgroundColor` : Couleur de fond
- `foregroundColor` : Couleur du texte/icône
- `padding` : Espacement interne
- `borderRadius` : Rayon des coins (défaut: 12.0)
- `isLoading` : Affiche un indicateur de chargement

### 9. AnimatedCard
Carte avec animations et effet de survol.

```dart
AnimatedCard(
  delay: Duration(milliseconds: 200),
  onTap: () => {},
  child: ListTile(...),
)
```

**Paramètres :**
- `child` : Contenu de la carte (requis)
- `margin` : Marge externe
- `padding` : Espacement interne
- `color` : Couleur de fond
- `elevation` : Élévation de la carte (défaut: 2.0)
- `borderRadius` : Rayon des coins
- `delay` : Délai avant l'animation
- `onTap` : Callback au clic

## Transitions entre écrans

Des transitions personnalisées ont été ajoutées pour les navigations :

### Transition Fade + Slide
```dart
Navigator.of(context).push(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => NextScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(1.0, 0.0), // Depuis la droite
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 300),
  ),
);
```

## Utilisation dans les écrans

### Écran de connexion (LoginScreen)
- Logo avec animation ScaleIn
- Titre avec effet Typewriter
- Champs de formulaire avec SlideIn alternés (gauche/droite)
- Bouton avec AnimatedButton
- Fond avec dégradé

### Écran d'inscription (RegisterScreen)
- Tous les champs avec animations SlideIn décalées
- Liste animée avec StaggeredListWidget
- Transitions fluides entre les sections
- Fond avec dégradé

### Écran d'accueil (HomeScreen)
- AppBar avec animations FadeIn
- Navigation avec AnimatedSwitcher pour les transitions entre onglets
- BottomNavigationBar avec animation FadeIn

## Importation simplifiée

Pour utiliser tous les widgets d'animation en une seule importation :

```dart
import '../widgets/animations/animations.dart';
```

Cela importe automatiquement tous les widgets d'animation disponibles.

## Bonnes pratiques

1. **Délais progressifs** : Utilisez des délais croissants pour créer un effet de cascade
   ```dart
   delay: Duration(milliseconds: 100 * index)
   ```

2. **Durées cohérentes** : Gardez des durées similaires pour une expérience fluide
   - Animations rapides : 200-400ms
   - Animations normales : 400-600ms
   - Animations lentes : 600-1000ms

3. **Courbes d'animation** : Utilisez des courbes appropriées
   - `Curves.easeOut` : Pour les entrées
   - `Curves.easeIn` : Pour les sorties
   - `Curves.easeInOut` : Pour les transitions
   - `Curves.elasticOut` : Pour des effets plus dynamiques

4. **Performance** : Évitez trop d'animations simultanées sur des widgets complexes

## Exemples d'utilisation

### Animation simple
```dart
FadeInWidget(
  child: Text('Hello World'),
)
```

### Animation avec délai
```dart
SlideInWidget(
  delay: Duration(milliseconds: 300),
  direction: AxisDirection.up,
  child: Card(...),
)
```

### Liste animée
```dart
StaggeredListWidget(
  staggerDuration: Duration(milliseconds: 100),
  children: items.map((item) => ItemWidget(item)).toList(),
)
```

### Bouton animé
```dart
AnimatedButton(
  text: 'Envoyer',
  icon: Icons.send,
  onPressed: () => sendData(),
  isLoading: isSending,
)
```

## Améliorations futures possibles

- [ ] Animation de chargement personnalisée
- [ ] Effets de parallaxe
- [ ] Animations de gestes (swipe, drag)
- [ ] Transitions de page personnalisées supplémentaires
- [ ] Animations basées sur les préférences utilisateur

