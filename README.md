# Ami-ly

Application mobile de mise en relation Parents / Assistantes Maternelles (Flutter).

## Configuration de l'environnement

Les clés d'API et configurations sensibles (Firebase, Stripe, RevenueCat, Agora)
ne sont **jamais** codées en dur : elles sont injectées au build via un fichier
`.env` (non committé).

```bash
# 1. Créer son .env local à partir du modèle
cp .env.example .env
# puis renseigner les valeurs

# 2. Lancer l'application
flutter run --dart-define-from-file=.env

# 3. Builder
flutter build apk --release --dart-define-from-file=.env
```

Au démarrage, l'application échoue avec une erreur explicite si une variable
obligatoire est absente (voir `lib/core/config/app_env.dart`).

### Cloud Functions (`functions/`)

Les secrets serveur (DocuSign, Stripe secret, Agora certificate) vivent dans
`functions/.env` — voir `functions/.env.example`. Ce fichier est chargé
automatiquement par Firebase lors du déploiement :

```bash
firebase deploy --only functions
```

## Getting Started

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
