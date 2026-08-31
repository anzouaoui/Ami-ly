#!/usr/bin/env bash
# =============================================================================
# codemagic/generate_env.sh
#
# Genere $CM_BUILD_DIR/codemagic.env avec les variables dart-define
# (Firebase, Stripe, RevenueCat, Agora) depuis les groupes Codemagic.
#
# Usage (etape Codemagic "Generate codemagic.env (dart defines)") :
#   bash "$CM_BUILD_DIR/codemagic/generate_env.sh"
#
# Verification syntaxique locale :
#   bash -n codemagic/generate_env.sh
#
# IMPORTANT : ce script DOIT etre execute avec bash (>=3.2), pas /bin/sh,
# car il utilise l expansion indirecte ${!VAR} (bashisme).
# Dans codemagic.yaml, appeler via : bash codemagic/generate_env.sh
# =============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# 1. Validation de l environnement Codemagic
# ---------------------------------------------------------------------------
: "${CM_BUILD_DIR:?CM_BUILD_DIR n est pas defini}"
cd "$CM_BUILD_DIR"

ENV_FILE="$CM_BUILD_DIR/codemagic.env"

# ---------------------------------------------------------------------------
# 2. Declaration des variables requises et optionnelles
# ---------------------------------------------------------------------------
REQUIRED_VARS=(
  FIREBASE_API_KEY_ANDROID
  FIREBASE_APP_ID_ANDROID
  FIREBASE_MESSAGING_SENDER_ID
  FIREBASE_PROJECT_ID
  FIREBASE_STORAGE_BUCKET
  FIREBASE_API_KEY_IOS
  FIREBASE_APP_ID_IOS
  FIREBASE_IOS_BUNDLE_ID
  REVENUECAT_API_KEY_ANDROID
  REVENUECAT_API_KEY_IOS
  STRIPE_PUBLISHABLE_KEY
  AGORA_APP_ID
)

# Variables soft : avertissement au lieu d echec si absentes
SOFT_VARS=(
  FIREBASE_IOS_BUNDLE_ID
)

# ---------------------------------------------------------------------------
# 3. Verification prealable
# ---------------------------------------------------------------------------
is_soft() {
  local var="$1"
  local sv
  for sv in "${SOFT_VARS[@]}"; do
    [[ "$var" == "$sv" ]] && return 0
  done
  return 1
}

MISSING=0
for VAR in "${REQUIRED_VARS[@]}"; do
  # ${!VAR} = expansion indirecte bash - corrige le bug "$(printenv "$VAR")" qui
  # provoquait "syntax error near unexpected token ( " avec /bin/sh
  if [[ -z "${!VAR:-}" ]]; then
    if is_soft "$VAR"; then
      echo "ATTENTION: $VAR absente - valeur par defaut utilisee (defaultValue dans app_env.dart)"
    else
      echo "ERREUR: $VAR absente de l environnement (verifier le champ groups ou le groupe Codemagic)"
      MISSING=1
    fi
  fi
done
[[ "$MISSING" -eq 0 ]] || exit 1

# ---------------------------------------------------------------------------
# 4. Generation de codemagic.env
# ---------------------------------------------------------------------------
rm -f "$ENV_FILE"
env | grep -E '^(FIREBASE_|STRIPE_PUBLISHABLE_KEY|REVENUECAT_|AGORA_)' \
    | tr -d '\r' \
    >> "$ENV_FILE" || true

# ---------------------------------------------------------------------------
# 5. Controles renforces post-generation
# ---------------------------------------------------------------------------
if [[ ! -s "$ENV_FILE" ]]; then
  echo "ERREUR: $ENV_FILE vide - aucune variable capturee depuis les groupes"
  exit 1
fi

for VAR in "${REQUIRED_VARS[@]}"; do
  if is_soft "$VAR"; then
    grep -q "^${VAR}=" "$ENV_FILE" \
      || echo "ATTENTION: $VAR absente de $ENV_FILE - valeur par defaut utilisee"
  else
    grep -q "^${VAR}=" "$ENV_FILE" \
      || { echo "ERREUR: $VAR manquante dans $ENV_FILE"; exit 1; }
  fi
done

# ---------------------------------------------------------------------------
# 6. Diagnostic - noms uniquement, jamais les valeurs (secrets)
# ---------------------------------------------------------------------------
ENTRY_COUNT=$(wc -l < "$ENV_FILE")
VAR_NAMES=$(cut -d= -f1 "$ENV_FILE" | tr '\n' ' ')
echo "codemagic.env genere (${ENTRY_COUNT} entrees) : ${VAR_NAMES}"
