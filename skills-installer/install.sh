#!/usr/bin/env bash

set -uo pipefail

RAW_BASE="https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer"
MANIFEST_URL="$RAW_BASE/skills-manifest.json"

if ! command -v jq &> /dev/null; then
  echo "ERROR: jq is not installed. Install it first (e.g. sudo apt install jq or brew install jq)"
  exit 1
fi

if ! command -v curl &> /dev/null; then
  echo "ERROR: curl is not installed."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
LOCAL_MANIFEST="$SCRIPT_DIR/skills-manifest.json"

TMP_MANIFEST=""
if [ -n "$SCRIPT_DIR" ] && [ -f "$LOCAL_MANIFEST" ]; then
  MANIFEST_PATH="$LOCAL_MANIFEST"
  echo "Using local manifest: $MANIFEST_PATH"
else
  TMP_MANIFEST="$(mktemp)"
  echo "Downloading manifest from GitHub..."
  if ! curl -fsSL "$MANIFEST_URL" -o "$TMP_MANIFEST"; then
    echo "ERROR: Failed to download manifest: $MANIFEST_URL"
    rm -f "$TMP_MANIFEST"
    exit 1
  fi
  MANIFEST_PATH="$TMP_MANIFEST"
fi

cleanup() {
  [ -n "$TMP_MANIFEST" ] && rm -f "$TMP_MANIFEST"
}
trap cleanup EXIT

MODE="${1:-all}"

case "$MODE" in
  frontend) CATEGORIES=("frontend" "shared") ;;
  backend)  CATEGORIES=("backend" "shared") ;;
  all)      CATEGORIES=("frontend" "backend" "shared") ;;
  *)
    echo "ERROR: invalid mode: $MODE (must be one of: all, frontend, backend)"
    exit 1
    ;;
esac

SUCCESS_LIST=()
FAILED_LIST=()
SKIPPED_LIST=()

echo "Starting Skill installation (mode: $MODE)"
echo ""

for category in "${CATEGORIES[@]}"; do
  count=$(jq ".\"$category\" | length" "$MANIFEST_PATH")
  for ((i = 0; i < count; i++)); do
    name=$(jq -r ".\"$category\"[$i].name" "$MANIFEST_PATH")
    source=$(jq -r ".\"$category\"[$i].source" "$MANIFEST_PATH")
    skill=$(jq -r ".\"$category\"[$i].skill" "$MANIFEST_PATH")

    if [ "$source" == "null" ] || [ -z "$source" ]; then
      echo "SKIP (no source defined): $name"
      SKIPPED_LIST+=("$name")
      continue
    fi

    echo "Installing: $name  (from $source)"

    if [ "$skill" == "null" ] || [ -z "$skill" ]; then
      CMD=(npx skills add "$source" -g -a claude-code -a cursor -a kiro-cli -y)
    else
      CMD=(npx skills add "$source" --skill "$skill" -g -a claude-code -a cursor -a kiro-cli -y)
    fi

    if "${CMD[@]}"; then
      echo "OK: $name"
      SUCCESS_LIST+=("$name")
    else
      echo "FAILED: $name (continuing to next item)"
      FAILED_LIST+=("$name")
    fi
    echo ""
  done
done

echo "----------------------------------------"
echo "Installation finished"
echo "Success (${#SUCCESS_LIST[@]}): ${SUCCESS_LIST[*]:-none}"
echo "Failed (${#FAILED_LIST[@]}): ${FAILED_LIST[*]:-none}"
echo "Skipped/no source (${#SKIPPED_LIST[@]}): ${SKIPPED_LIST[*]:-none}"
