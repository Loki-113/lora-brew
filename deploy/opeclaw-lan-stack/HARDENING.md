# Hardening ligero (LAN)

## 1) Red y superficie de exposición
- Mantén publicación solo en IP interna del host (UFW/ACL del switch/VLAN).
- No publiques `vllm` ni `opeclaw` directamente; usa solo `proxy`.

## 2) Auth mínima
- Usa `REQUIRE_AUTH=1` y un `BEARER_TOKEN` largo (>=32 chars).
- Rota token si se comparte fuera del equipo.

## 3) Rate limiting
- `RATE_LIMIT_RPM=60` por IP para uso humano.
- Sube a `120` si integras orquestadores internos con burst alto.

## 4) Operación
- `restart: unless-stopped` ya aplicado.
- Usa healthchecks y alerta simple con `docker ps --format` + cron/systemd timer.

## 5) Backups
- Prioriza backup de:
  - `.env` y config nginx.
  - volúmenes con índices/cachés útiles.
  - `/mnt/modelos` sólo si no tienes otra copia local.

## 6) TLS opcional en LAN
- Puedes poner Caddy/Traefik delante de `proxy` para HTTPS interno con CA privada.
- Mantén Nginx como policy layer (auth/rate-limit) o migra esas reglas al reverse proxy principal.
