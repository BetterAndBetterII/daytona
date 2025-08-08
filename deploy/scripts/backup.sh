#!/usr/bin/env bash
set -euo pipefail

# 简易备份：Postgres + MinIO 数据
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ROOT_DIR="${SCRIPT_DIR}/.."
TARGET_DIR=${1:-"${ROOT_DIR}/backups/$(date +%Y%m%d-%H%M%S)"}

mkdir -p "${TARGET_DIR}"
cd "${ROOT_DIR}"

echo "[INFO] 备份 Postgres..."
docker compose exec -T db pg_dump -U user -d application_ctx -F c -f /tmp/db.dump
docker compose cp db:/tmp/db.dump "${TARGET_DIR}/db.dump"

echo "[INFO] 备份 MinIO 数据卷..."
docker run --rm -v minio_data:/data -v "${TARGET_DIR}":/backup alpine:3.20 \
  tar czf /backup/minio_data.tgz -C / data

echo "[OK] 备份完成 -> ${TARGET_DIR}"
