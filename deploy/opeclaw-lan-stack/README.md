# OpeClaw + vLLM + Nginx (LAN production-like)

Stack orientado a LAN para Ubuntu 24.04 + NVIDIA RTX 5090.

## Qué despliega
- `vllm`: backend OpenAI-compatible para modelo local.
- `opeclaw`: app principal conectada a `vllm`.
- `proxy` (nginx): entrada única con puertos LAN, rate-limit y auth Bearer opcional.

## Puertos
- `8080`: UI/API de OpeClaw vía proxy.
- `7000`: API de vLLM vía proxy.
- `19090`: endpoint de estado de nginx (`/nginx-health`).

> Se publican sobre `HOST_BIND_IP` para que puedas limitar a una IP LAN concreta.

## Requisitos
- Docker Engine + plugin Compose.
- NVIDIA drivers + `nvidia-container-runtime` funcional.
- Modelos en `/mnt/modelos` (recomendado para evitar descargas recurrentes).

## Preparación de carpetas y permisos (host)
```bash
cd deploy/opeclaw-lan-stack
./scripts/bootstrap-storage.sh
```

Variables opcionales para personalizar:
- `MODELS_DIR` (default `/mnt/modelos`)
- `STACK_DATA_ROOT` (default `/var/lib/opeclaw-lan-stack`)
- `STACK_USER` / `STACK_GROUP` (default usuario actual)
- `MODELS_MODE` (default `775`) y `DIR_MODE` (default `750`)

## Arranque rápido
```bash
cd deploy/opeclaw-lan-stack
cp .env.example .env
# editar .env con tu modelo y tokens
./scripts/up.sh
```

## Salud del stack
```bash
cd deploy/opeclaw-lan-stack
set -a && source .env && set +a
./scripts/healthcheck.sh
```

## Configuración recomendada para tu caso (1–5 usuarios)
- `TENSOR_PARALLEL_SIZE=1` para 1 GPU.
- `MAX_MODEL_LEN=32768` si cabe en VRAM; bajar a `16384` si hay presión de memoria.
- `MAX_NUM_SEQS=8` para priorizar latencia interactiva.
- `REQUIRE_AUTH=1` cuando el segmento LAN lo use más gente.
- `HOST_BIND_IP=192.168.x.x` si quieres evitar exposición en todas las interfaces.

## Seguridad aplicada
- vLLM exige `--api-key` (`INTERNAL_OPENAI_KEY`) para evitar acceso directo sin clave.
- El proxy valida `BEARER_TOKEN` (si `REQUIRE_AUTH=1`) y reinyecta `Authorization` interna hacia vLLM.

## Cambio de modelo
Ajusta en `.env`:
- `VLLM_MODEL=/models/<ruta-modelo>`
- `SERVED_MODEL_NAME=<alias>`

y reinicia:
```bash
docker compose up -d --force-recreate vllm
```

## Notas
- Si el contenedor de `vllm` no detecta CUDA, valida runtime NVIDIA y variable `NVIDIA_VISIBLE_DEVICES`.
- Si ya tienes pesos descargados no necesitas `HF_TOKEN`.
