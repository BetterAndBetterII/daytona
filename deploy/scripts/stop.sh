#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ROOT_DIR="${SCRIPT_DIR}/.."

cd "${ROOT_DIR}"
echo "[INFO] 正在停止并移除服务容器..."
docker compose down
echo "[OK] 已停止。"
