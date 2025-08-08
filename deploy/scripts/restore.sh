#!/usr/bin/env bash
set -euo pipefail

# 简易恢复：Postgres + MinIO 数据
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ROOT_DIR="${SCRIPT_DIR}/.."
BACKUP_DIR=${1:?"用法: restore.sh <backup_dir>"}

cd "${ROOT_DIR}"

if [[ ! -f "${BACKUP_DIR}/db.dump" ]]; then
  echo "[ERR] 未找到 ${BACKUP_DIR}/db.dump" >&2
  exit 1
fi

echo "[INFO] 恢复 Postgres..."
docker compose cp "${BACKUP_DIR}/db.dump" db:/tmp/db.dump
docker compose exec -T db pg_restore -U user -d application_ctx --clean --if-exists /tmp/db.dump

if [[ -f "${BACKUP_DIR}/minio_data.tgz" ]]; then
  echo "[INFO] 恢复 MinIO 数据卷..."
  docker run --rm -v minio_data:/data -v "${BACKUP_DIR}":/backup alpine:3.20 \
    sh -lc 'rm -rf /data/* && tar xzf /backup/minio_data.tgz -C /'
fi

echo "[OK] 恢复完成。"
