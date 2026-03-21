#!/usr/bin/env bash
set -euo pipefail

AUTH_HEADER=()
if [[ "${REQUIRE_AUTH:-1}" == "1" ]]; then
  if [[ -z "${BEARER_TOKEN:-}" ]]; then
    echo "[error] REQUIRE_AUTH=1 pero falta BEARER_TOKEN en entorno."
    exit 1
  fi
  AUTH_HEADER=(-H "Authorization: Bearer ${BEARER_TOKEN}")
fi

echo "[check] nginx"
curl -fsS http://localhost:19090/nginx-health >/dev/null

echo "[check] vllm"
curl -fsS "${AUTH_HEADER[@]}" http://localhost:7000/health >/dev/null

echo "[check] opeclaw"
curl -fsS "${AUTH_HEADER[@]}" http://localhost:8080/ >/dev/null

echo "[ok] Healthchecks básicos en verde."
