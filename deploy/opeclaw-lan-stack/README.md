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

## Requisitos
- Docker Engine + plugin Compose.
- NVIDIA drivers + `nvidia-container-runtime` funcional.
- Modelos en `/mnt/modelos` (recomendado para evitar descargas recurrentes).

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
