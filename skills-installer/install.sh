#!/usr/bin/env bash
# نصب دسته‌جمعی Agent Skills — نسخه خودکفا (مستقیم از GitHub)
#
# استفاده مستقیم بدون کلون کردن ریپو:
#   curl -fsSL https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer/install.sh | bash -s frontend
#   curl -fsSL https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer/install.sh | bash -s backend
#   curl -fsSL https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer/install.sh | bash -s all
#
# یا به صورت لوکال (اگر ریپو را کلون کرده‌اید):
#   ./install.sh frontend

set -uo pipefail

RAW_BASE="https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer"
MANIFEST_URL="$RAW_BASE/skills-manifest.json"

if ! command -v jq &> /dev/null; then
  echo "❌ ابزار jq نصب نیست. لطفاً اول آن را نصب کنید (مثلاً: sudo apt install jq یا brew install jq)"
  exit 1
fi

if ! command -v curl &> /dev/null; then
  echo "❌ ابزار curl نصب نیست."
  exit 1
fi

# اگر فایل manifest به صورت محلی کنار اسکریپت وجود داشت، از همان استفاده کن
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
LOCAL_MANIFEST="$SCRIPT_DIR/skills-manifest.json"

TMP_MANIFEST=""
if [ -n "$SCRIPT_DIR" ] && [ -f "$LOCAL_MANIFEST" ]; then
  MANIFEST_PATH="$LOCAL_MANIFEST"
  echo "📄 استفاده از manifest محلی: $MANIFEST_PATH"
else
  TMP_MANIFEST="$(mktemp)"
  echo "🌐 دانلود manifest از GitHub..."
  if ! curl -fsSL "$MANIFEST_URL" -o "$TMP_MANIFEST"; then
    echo "❌ دانلود manifest ناموفق بود: $MANIFEST_URL"
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
    echo "❌ حالت نامعتبر: $MODE (باید یکی از: all, frontend, backend باشد)"
    exit 1
    ;;
esac

SUCCESS_LIST=()
FAILED_LIST=()
SKIPPED_LIST=()

echo "🚀 شروع نصب Skill ها (حالت: $MODE)"
echo ""

for category in "${CATEGORIES[@]}"; do
  count=$(jq ".\"$category\" | length" "$MANIFEST_PATH")
  for ((i = 0; i < count; i++)); do
    name=$(jq -r ".\"$category\"[$i].name" "$MANIFEST_PATH")
    source=$(jq -r ".\"$category\"[$i].source" "$MANIFEST_PATH")
    skill=$(jq -r ".\"$category\"[$i].skill" "$MANIFEST_PATH")

    if [ "$source" == "null" ] || [ -z "$source" ]; then
      echo "⏭  رد شد (source مشخص نیست): $name"
      SKIPPED_LIST+=("$name")
      continue
    fi

    echo "📦 در حال نصب: $name  (از $source)"

    if [ "$skill" == "null" ] || [ -z "$skill" ]; then
      CMD=(npx skills add "$source" -g -a claude-code -a cursor -a kiro-cli -y)
    else
      CMD=(npx skills add "$source" --skill "$skill" -g -a claude-code -a cursor -a kiro-cli -y)
    fi

    if "${CMD[@]}"; then
      echo "✅ موفق: $name"
      SUCCESS_LIST+=("$name")
    else
      echo "⚠️  ناموفق: $name (ادامه به مورد بعدی)"
      FAILED_LIST+=("$name")
    fi
    echo ""
  done
done

echo "----------------------------------------"
echo "🎉 پایان نصب"
echo "✅ موفق (${#SUCCESS_LIST[@]}): ${SUCCESS_LIST[*]:-هیچ}"
echo "⚠️  ناموفق (${#FAILED_LIST[@]}): ${FAILED_LIST[*]:-هیچ}"
echo "⏭  رد شده/بدون source (${#SKIPPED_LIST[@]}): ${SKIPPED_LIST[*]:-هیچ}"
