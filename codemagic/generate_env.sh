#!/usr/bin/env bash
# =============================================================================
# codemagic/generate_env.sh
#
# Genere $CM_BUILD_DIR/codemagic.env avec les variables dart-define
# (Firebase, Stripe, RevenueCat, Agora) depuis les groupes Codemagic
# ou depuis un fichier .env.local (fallback pour builds locaux/hors-prod).
#
# Usage (etape Codemagic "Generate codemagic.env (dart defines)") :
#   bash "$CM_BUILD_DIR/codemagic/generate_env.sh"
#
# Usage local (hors Codemagic, pour tester le script) :
#   CM_BUILD_DIR=$(pwd) bash codemagic/generate_env.sh
#   # Les variables sont lues depuis .env.local si presentes
#
# Verification syntaxique :
#   bash -n codemagic/generate_env.sh
#
# IMPORTANT : necessite bash >=3.2 (${!VAR} = expansion indirecte bash).
# Dans codemagic.yaml, appeler via : bash codemagic/generate_env.sh
# =============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# 1. Validation de l environnement + resolution du repertoire de travail
# ---------------------------------------------------------------------------
: "${CM_BUILD_DIR:?CM_BUILD_DIR n est pas defini}"
cd "$CM_BUILD_DIR"

ENV_FILE="$CM_BUILD_DIR/codemagic.env"
LOCAL_ENV_FILE="$CM_BUILD_DIR/.env.local"

# ---------------------------------------------------------------------------
# 2. Fallback .env.local (builds locaux ou hors-prod sans groupes Codemagic)
# ---------------------------------------------------------------------------
# Si .env.local existe, on source ses variables dans l environnement courant
# avant toute verification. Cela permet de tester le pipeline localement sans
# avoir besoin des groupes Codemagic (ex: CM_BUILD_DIR=$(pwd) bash ...).
# .env.local est exclu du git par .gitignore (*.env.*) - ne jamais le committer.
if [[ -f "$LOCAL_ENV_FILE" ]]; then
  echo "INFO: Fichier $LOCAL_ENV_FILE detecte - sourcing (mode local/fallback)"
  # shellcheck source=/dev/null
  set +u
  # Lecture ligne a ligne : ignore commentaires et lignes vides
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue
    # Exporte uniquement si la variable n est pas deja definie dans l env
    varname="${line%%=*}"
    if [[ -z "${!varname:-}" ]]; then
      export "$line" 2>/dev/null || true
    fi
  done < "$LOCAL_ENV_FILE"
  set -u
fi

# ---------------------------------------------------------------------------
# 3. Declaration des variables requises et optionnelles
# ---------------------------------------------------------------------------
# Groupe Codemagic "firebase_credentials" :
#   FIREBASE_API_KEY_ANDROID, FIREBASE_APP_ID_ANDROID, FIREBASE_MESSAGING_SENDER_ID,
#   FIREBASE_PROJECT_ID, FIREBASE_STORAGE_BUCKET, FIREBASE_API_KEY_IOS,
#   FIREBASE_APP_ID_IOS, FIREBASE_IOS_BUNDLE_ID
# Groupe Codemagic "payments_credentials" :
#   STRIPE_PUBLISHABLE_KEY, REVENUECAT_API_KEY_ANDROID, REVENUECAT_API_KEY_IOS
# Groupe Codemagic "agora_credentials" :
#   AGORA_APP_ID
REQUIRED_VARS=(
  FIREBASE_API_KEY_ANDROID
  FIREBASE_APP_ID_ANDROID
  FIREBASE_MESSAGING_SENDER_ID
  FIREBASE_PROJECT_ID
  FIREBASE_STORAGE_BUCKET
  FIREBASE_API_KEY_IOS
  FIREBASE_APP_ID_IOS
  REVENUECAT_API_KEY_ANDROID
  REVENUECAT_API_KEY_IOS
  STRIPE_PUBLISHABLE_KEY
  AGORA_APP_ID
)

# Variables soft : valeur par defaut dans app_env.dart, avertissement seulement
SOFT_VARS=(
  FIREBASE_IOS_BUNDLE_ID
)

# ---------------------------------------------------------------------------
# 4. Verification prealable : toutes les variables sont-elles presentes ?
# ---------------------------------------------------------------------------
is_soft() {
  local var="$1"
  local sv
  for sv in "${SOFT_VARS[@]}"; do
    [[ "$var" == "$sv" ]] && return 0
  done
  return 1
}

MISSING_VARS=()
for VAR in "${REQUIRED_VARS[@]}"; do
  # ${!VAR} = expansion indirecte bash : pas de sous-shell, pas de guillemet imbrique
  if [[ -z "${!VAR:-}" ]]; then
    if is_soft "$VAR"; then
      echo "ATTENTION: $VAR absente - valeur par defaut app_env.dart utilisee"
    else
      MISSING_VARS+=("$VAR")
    fi
  fi
done

if [[ "${#MISSING_VARS[@]}" -gt 0 ]]; then
  echo ""
  echo "================================================================="
  echo "ERREUR : ${#MISSING_VARS[@]} variable(s) manquante(s) :"
  for MV in "${MISSING_VARS[@]}"; do
    echo "  - $MV"
  done
  echo ""
  echo "Causes possibles et solutions :"
  echo "  1. Codemagic UI : verifier que les groupes de variables existent"
  echo "     Settings > Environment variables, avec les noms EXACTS :"
  echo "       - firebase_credentials  (FIREBASE_* keys)"
  echo "       - payments_credentials  (STRIPE_*, REVENUECAT_*)"
  echo "       - agora_credentials     (AGORA_APP_ID)"
  echo "     Puis dans codemagic.yaml > environment > groups, les 3 groupes"
  echo "     doivent etre listes avec ces noms exacts."
  echo "  2. Build local : creer .env.local (copie de .env.example) avec"
  echo "     les vraies valeurs. Ne jamais committer .env.local."
  echo "     Exemple : cp .env.example .env.local && nano .env.local"
  echo "  3. Voir codemagic/SETUP.md pour le guide complet de configuration."
  echo "================================================================="
  exit 1
fi

# ---------------------------------------------------------------------------
# 5. Generation de codemagic.env
# ---------------------------------------------------------------------------
rm -f "$ENV_FILE"
env | grep -E '^(FIREBASE_|STRIPE_PUBLISHABLE_KEY|REVENUECAT_|AGORA_)' \
    | tr -d '\r' \
    >> "$ENV_FILE" || true

# ---------------------------------------------------------------------------
# 6. Controles renforces post-generation
# ---------------------------------------------------------------------------
if [[ ! -s "$ENV_FILE" ]]; then
  echo "ERREUR: $ENV_FILE vide apres generation"
  echo "       Verifier que les groupes Codemagic sont correctement associes."
  exit 1
fi

for VAR in "${REQUIRED_VARS[@]}"; do
  if is_soft "$VAR"; then
    if ! grep -q "^${VAR}=" "$ENV_FILE"; then
      echo "ATTENTION: $VAR absente de $ENV_FILE - valeur par defaut utilisee"
    fi
  else
    if ! grep -q "^${VAR}=" "$ENV_FILE"; then
      echo "ERREUR: $VAR manquante dans $ENV_FILE"
      exit 1
    fi
  fi
done

# ---------------------------------------------------------------------------
# 7. Diagnostic - noms uniquement, jamais les valeurs (secrets)
# ---------------------------------------------------------------------------
ENTRY_COUNT=$(wc -l < "$ENV_FILE")
VAR_NAMES=$(cut -d= -f1 "$ENV_FILE" | tr '\n' ' ')
echo ""
echo "codemagic.env genere avec succes (${ENTRY_COUNT} entrees) :"
echo "  ${VAR_NAMES}"
