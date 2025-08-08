#!/bin/sh
# Runner 服务启动脚本 - 确保目录权限正确

set -e

echo "Setting up runner environment..."

# 确保日志目录存在且有正确权限
mkdir -p /app/logs
chown -R app:app /app/logs
chmod -R 755 /app/logs

# 确保临时目录存在且有正确权限
mkdir -p /app/.tmp
mkdir -p /app/.tmp/binaries
chown -R app:app /app/.tmp
chmod -R 755 /app/.tmp

echo "Runner environment setup complete."

# 切换到app用户并启动runner
exec su-exec app:app /app/runner "$@"