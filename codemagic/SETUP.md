# Configuration des variables d'environnement Codemagic (Ami-ly)

Ce document détaille les variables d'environnement et groupes nécessaires dans l'interface Codemagic pour que l'étape **"Generate codemagic.env (dart defines)"** et la compilation iOS / Android s'exécutent avec succès.

---

## 1. Structure des groupes de variables dans Codemagic

Dans l'interface Codemagic :
**Projet > Settings > Environment variables** (ou **Application > Environment variables**)

Créez les **3 groupes** suivants (ou un groupe unique si vous préférez, mais assurez-vous d'aligner la section `environment.groups` dans `codemagic.yaml`) :

### Groupe 1 : `firebase_credentials`
| Variable | Description / Source | Requis ? |
|---|---|:---:|
| `FIREBASE_API_KEY_ANDROID` | Console Firebase > Paramètres projet > Apps > Android > `current_key` | Oui |
| `FIREBASE_APP_ID_ANDROID` | Console Firebase > Paramètres projet > Apps > Android > `mobilesdk_app_id` | Oui |
| `FIREBASE_MESSAGING_SENDER_ID` | Console Firebase > Paramètres projet > ID expéditeur Cloud Messaging | Oui |
| `FIREBASE_PROJECT_ID` | Console Firebase > Paramètres projet > ID du projet (ex: `amily-prod`) | Oui |
| `FIREBASE_STORAGE_BUCKET` | Console Firebase > Storage > URL du bucket (ex: `amily-prod.appspot.com`) | Oui |
| `FIREBASE_API_KEY_IOS` | Console Firebase > Paramètres projet > Apps > iOS > `API_KEY` | Oui |
| `FIREBASE_APP_ID_IOS` | Console Firebase > Paramètres projet > Apps > iOS > `GOOGLE_APP_ID` | Oui |
| `FIREBASE_IOS_BUNDLE_ID` | Bundle ID iOS (défaut : `com.app.amily`) | Optionnel (défaut `com.app.amily`) |

### Groupe 2 : `payments_credentials`
| Variable | Description / Source | Requis ? |
|---|---|:---:|
| `STRIPE_PUBLISHABLE_KEY` | Dashboard Stripe > Développeurs > Clés API > Clé publique (`pk_live_...` ou `pk_test_...`) | Oui |
| `REVENUECAT_API_KEY_ANDROID` | Dashboard RevenueCat > Projet > API Keys > Android (Google Play) | Oui |
| `REVENUECAT_API_KEY_IOS` | Dashboard RevenueCat > Projet > API Keys > iOS (App Store) | Oui |

### Groupe 3 : `agora_credentials`
| Variable | Description / Source | Requis ? |
|---|---|:---:|
| `AGORA_APP_ID` | Console Agora.io > Project Management > App ID | Oui |

---

## 2. Déclaration dans `codemagic.yaml`

Dans `codemagic.yaml`, la section `environment.groups` doit inclure ces groupes :

```yaml
workflows:
  ios-workflow:
    environment:
      groups:
        - firebase_credentials
        - payments_credentials
        - agora_credentials
```

---

## 3. Mode Local / Fallback (`.env.local`)

Pour tester la génération de `codemagic.env` en local ou sur une machine de dev sans passer par Codemagic :

1. Copiez `.env.example` vers `.env.local` :
   ```bash
   cp .env.example .env.local
   ```
2. Renseignez les vraies clés dans `.env.local`.
3. Testez le script :
   ```bash
   CM_BUILD_DIR=$(pwd) bash codemagic/generate_env.sh
   ```
4. `.env.local` est ignoré par Git via `.gitignore` (`.env.*`).