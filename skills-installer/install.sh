#!/usr/bin/env bash
# Interactive Skills Installer (bash)
#
# Flow:
#   1. Ask which area to install (Frontend / Backend / Both)
#   2. Show a numbered list of skills for that area (+ shared skills),
#      grouped visually with section headers
#   3. User types comma-separated numbers to select (or "all")
#   4. Confirm selection
#   5. Install only the selected skills
#
# Usage (self-contained, run directly from GitHub):
#   curl -fsSL https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer/install.sh | bash
#
# Or locally (if you cloned the repo):
#   ./install.sh

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

# ---- Load manifest (local copy if present, otherwise download) ----

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

# stdin might be a pipe (curl | bash); reconnect it to the terminal so `read` works interactively
if [ ! -t 0 ]; then
  exec < /dev/tty
fi

# ---- Step 1: choose area ----

echo ""
echo "Which area do you want to install skills for?"
echo "  1) Frontend"
echo "  2) Backend"
echo "  3) Both (Frontend + Backend)"
read -rp "Enter choice [1-3]: " AREA_CHOICE

case "$AREA_CHOICE" in
  1) CATEGORIES=("frontend") ; AREA_LABEL="Frontend" ;;
  2) CATEGORIES=("backend") ; AREA_LABEL="Backend" ;;
  3) CATEGORIES=("frontend" "backend") ; AREA_LABEL="Both (Frontend + Backend)" ;;
  *) echo "Invalid choice."; exit 1 ;;
esac
CATEGORIES+=("shared")

# ---- Step 2: build numbered list grouped by section ----

NAMES=()
SOURCES=()
SKILLS=()
GROUPS=()

for category in "${CATEGORIES[@]}"; do
  case "$category" in
    frontend) GROUP_LABEL="Frontend" ;;
    backend)  GROUP_LABEL="Backend" ;;
    shared)   GROUP_LABEL="Shared" ;;
  esac

  count=$(jq ".\"$category\" | length" "$MANIFEST_PATH")
  for ((i = 0; i < count; i++)); do
    NAMES+=("$(jq -r ".\"$category\"[$i].name" "$MANIFEST_PATH")")
    SOURCES+=("$(jq -r ".\"$category\"[$i].source" "$MANIFEST_PATH")")
    SKILLS+=("$(jq -r ".\"$category\"[$i].skill" "$MANIFEST_PATH")")
    GROUPS+=("$GROUP_LABEL")
  done
done

echo ""
echo "Area: $AREA_LABEL"
echo "Available skills:"
CURRENT_GROUP=""
for ((i = 0; i < ${#NAMES[@]}; i++)); do
  if [ "${GROUPS[$i]}" != "$CURRENT_GROUP" ]; then
    CURRENT_GROUP="${GROUPS[$i]}"
    echo ""
    echo "-- $CURRENT_GROUP --"
  fi
  tag=""
  if [ "${SOURCES[$i]}" == "null" ] || [ -z "${SOURCES[$i]}" ]; then
    tag=" (no source yet)"
  fi
  printf "  %2d) %s%s\n" "$((i + 1))" "${NAMES[$i]}" "$tag"
done

echo ""
echo "Enter the numbers of the skills you want to install, comma-separated (e.g. 1,3,5)."
echo "Type 'all' to select everything shown above."
read -rp "Selection: " SELECTION

SELECTED_IDX=()
if [ "$SELECTION" == "all" ]; then
  for ((i = 0; i < ${#NAMES[@]}; i++)); do SELECTED_IDX+=("$i"); done
else
  IFS=',' read -ra RAW_PARTS <<< "$SELECTION"
  for part in "${RAW_PARTS[@]}"; do
    part="$(echo "$part" | tr -d '[:space:]')"
    if [[ "$part" =~ ^[0-9]+$ ]] && [ "$part" -ge 1 ] && [ "$part" -le "${#NAMES[@]}" ]; then
      SELECTED_IDX+=("$((part - 1))")
    fi
  done
fi

if [ ${#SELECTED_IDX[@]} -eq 0 ]; then
  echo "No valid skills selected. Nothing to install."
  exit 0
fi

# ---- Step 3: confirm ----

echo ""
echo "You selected the following skills:"
for idx in "${SELECTED_IDX[@]}"; do
  echo "  - ${NAMES[$idx]}  [${GROUPS[$idx]}]"
done

read -rp $'\nProceed with installation? (Y/n): ' CONFIRM
if [ -n "$CONFIRM" ] && [ "${CONFIRM^^}" != "Y" ]; then
  echo "Cancelled."
  exit 0
fi

# ---- Step 4: install ----

SUCCESS_LIST=()
FAILED_LIST=()
SKIPPED_LIST=()

echo ""
echo "Starting installation..."
echo ""

for idx in "${SELECTED_IDX[@]}"; do
  name="${NAMES[$idx]}"
  source="${SOURCES[$idx]}"
  skill="${SKILLS[$idx]}"

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

echo "----------------------------------------"
echo "Installation finished"
echo "Success (${#SUCCESS_LIST[@]}): ${SUCCESS_LIST[*]:-none}"
echo "Failed (${#FAILED_LIST[@]}): ${FAILED_LIST[*]:-none}"
echo "Skipped/no source (${#SKIPPED_LIST[@]}): ${SKIPPED_LIST[*]:-none}"