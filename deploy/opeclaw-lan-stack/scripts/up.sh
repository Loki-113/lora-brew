#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -f .env ]]; then
  echo "[info] .env no existe, creando desde .env.example"
  cp .env.example .env
fi

docker compose pull
docker compose up -d

echo "[ok] Stack arriba."
echo "- OpeClaw UI/API proxy: http://localhost:8080"
echo "- vLLM API proxy: http://localhost:7000/v1"
echo "- Nginx status: http://localhost:19090/nginx-health"
