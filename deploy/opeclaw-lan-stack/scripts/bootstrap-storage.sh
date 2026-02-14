#!/usr/bin/env bash
set -euo pipefail

# Create required host directories and apply ownership/permissions
# for the OpeClaw + vLLM LAN stack.

MODELS_DIR="${MODELS_DIR:-/mnt/modelos}"
STACK_DATA_ROOT="${STACK_DATA_ROOT:-/var/lib/opeclaw-lan-stack}"
STACK_USER="${STACK_USER:-$USER}"
STACK_GROUP="${STACK_GROUP:-$USER}"
DIR_MODE="${DIR_MODE:-750}"
MODELS_MODE="${MODELS_MODE:-775}"

run_cmd() {
  if [[ "${EUID}" -eq 0 ]]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    "$@"
  fi
}

require_write_or_sudo() {
  local target="$1"
  if [[ -d "$target" && -w "$target" ]]; then
    return 0
  fi

  if [[ "${EUID}" -eq 0 ]] || command -v sudo >/dev/null 2>&1; then
    return 0
  fi

  echo "[error] Sin permisos para escribir en '$target' y sudo no está disponible." >&2
  echo "        Ejecuta este script como root o instala/configura sudo." >&2
  exit 1
}

echo "[info] Preparando estructura de carpetas..."
require_write_or_sudo /mnt
require_write_or_sudo /var/lib

DIRS=(
  "$MODELS_DIR"
  "$STACK_DATA_ROOT/config"
  "$STACK_DATA_ROOT/logs"
  "$STACK_DATA_ROOT/backups"
)

for dir in "${DIRS[@]}"; do
  run_cmd mkdir -p "$dir"
  echo "[ok] Carpeta lista: $dir"
done

echo "[info] Aplicando ownership ${STACK_USER}:${STACK_GROUP}..."
run_cmd chown -R "${STACK_USER}:${STACK_GROUP}" "$MODELS_DIR" "$STACK_DATA_ROOT"

echo "[info] Aplicando permisos..."
run_cmd chmod "$MODELS_MODE" "$MODELS_DIR"
run_cmd chmod -R "$DIR_MODE" "$STACK_DATA_ROOT"

echo "[done] Estructura y permisos aplicados."
echo "       MODELS_DIR=$MODELS_DIR ($MODELS_MODE)"
echo "       STACK_DATA_ROOT=$STACK_DATA_ROOT ($DIR_MODE)"
