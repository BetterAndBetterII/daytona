#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ROOT_DIR="${SCRIPT_DIR}/.."

cd "${ROOT_DIR}"

if [[ ! -f "../.env" && ! -f ".env" ]]; then
  echo "[INFO] 未检测到 .env，将使用镜像和 compose 内的默认值。" >&2
else
  echo "[INFO] 使用 .env 环境变量文件。"
fi

echo "[INFO] 正在启动服务栈..."
if [[ -f "../.env" ]]; then
  docker compose --env-file ../.env up -d
else
  docker compose up -d
fi

echo "[OK] 服务已启动。可访问: Dashboard http://localhost:8080, API http://localhost:3001/api"
