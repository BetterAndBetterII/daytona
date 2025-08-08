#!/bin/bash

# Daytona 数据库迁移脚本
# 用于手动执行 TypeORM 迁移

set -e

echo "🚀 开始执行 Daytona 数据库迁移..."

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未运行，请先启动 Docker"
    exit 1
fi

# 检查 docker-compose.yml 是否存在
if [ ! -f "deploy/docker-compose.yml" ]; then
    echo "❌ 找不到 deploy/docker-compose.yml 文件"
    exit 1
fi

# 进入部署目录
cd deploy

echo "📋 检查服务状态..."
docker compose ps

echo "🔄 等待数据库服务就绪..."
# 等待数据库服务启动
until docker compose exec -T db pg_isready -U user -d application_ctx; do
    echo "⏳ 等待数据库启动..."
    sleep 5
done

echo "✅ 数据库已就绪"

echo "🔧 执行数据库迁移..."
# 在 API 容器中执行迁移
docker compose exec -T api npm run migration:run

if [ $? -eq 0 ]; then
    echo "✅ 数据库迁移执行成功"
else
    echo "❌ 数据库迁移执行失败"
    exit 1
fi

echo "🎉 数据库迁移完成！"
echo "📊 迁移状态："
docker compose exec -T db psql -U user -d application_ctx -c "\dt" 2>/dev/null | head -20

echo "🔄 重启 API 服务..."
docker compose restart api

echo "✅ 所有操作完成！"