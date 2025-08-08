#!/usr/bin/env bash
# Daytona 凭据查看脚本

set -euo pipefail

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查.env文件是否存在
check_env_file() {
    local env_file="$1"
    if [[ ! -f "$env_file" ]]; then
        log_error "未找到环境配置文件: $env_file"
        log_info "请先运行一键安装脚本: ./deploy/scripts/install.sh"
        exit 1
    fi
}

# 显示凭据信息
show_credentials() {
    local env_file="$1"
    
    echo "=================================================================="
    echo "🔑 Daytona 服务凭据信息"
    echo "=================================================================="
    echo
    
    log_info "环境配置文件: $env_file"
    echo
    
    echo "📊 数据库配置:"
    local db_host db_port db_username db_password db_database
    db_host=$(grep "^DB_HOST=" "$env_file" | cut -d'=' -f2-)
    db_port=$(grep "^DB_PORT=" "$env_file" | cut -d'=' -f2-)
    db_username=$(grep "^DB_USERNAME=" "$env_file" | cut -d'=' -f2-)
    db_password=$(grep "^DB_PASSWORD=" "$env_file" | cut -d'=' -f2-)
    db_database=$(grep "^DB_DATABASE=" "$env_file" | cut -d'=' -f2-)
    echo "  主机: ${db_host}"
    echo "  端口: ${db_port}"
    echo "  用户名: ${db_username}"
    echo "  密码: ${db_password}"
    echo "  数据库: ${db_database}"
    echo
    
    echo "💾 MinIO 对象存储配置:"
    local minio_user minio_password
    minio_user=$(grep "^MINIO_ROOT_USER=" "$env_file" | cut -d'=' -f2-)
    minio_password=$(grep "^MINIO_ROOT_PASSWORD=" "$env_file" | cut -d'=' -f2-)
    echo "  用户名: ${minio_user}"
    echo "  密码: ${minio_password}"
    echo "  Web控制台: http://localhost:9001"
    echo "  API端点: http://localhost:9000"
    echo
    
    echo "🔌 API 服务配置:"
    local api_token app_url port
    api_token=$(grep "^API_TOKEN=" "$env_file" | cut -d'=' -f2-)
    app_url=$(grep "^APP_URL=" "$env_file" | cut -d'=' -f2-)
    port=$(grep "^PORT=" "$env_file" | cut -d'=' -f2-)
    echo "  API令牌: ${api_token}"
    echo "  服务地址: ${app_url}"
    echo "  内部端口: ${port}"
    echo
    
    echo "🔀 代理服务配置:"
    local proxy_key proxy_port proxy_domain
    proxy_key=$(grep "^PROXY_API_KEY=" "$env_file" | cut -d'=' -f2-)
    proxy_port=$(grep "^PROXY_PORT=" "$env_file" | cut -d'=' -f2-)
    proxy_domain=$(grep "^PROXY_DOMAIN=" "$env_file" | cut -d'=' -f2-)
    echo "  代理密钥: ${proxy_key}"
    echo "  代理端口: ${proxy_port}"
    echo "  代理域名: ${proxy_domain}"
    echo
    
    echo "🌐 服务访问地址:"
    echo "  Dashboard:  http://localhost:8080"
    echo "  API:         ${app_url}"
    echo "  Runner:      http://localhost:3003"
    echo "  Proxy:       http://localhost:${proxy_port}"
    echo "  Registry UI: http://localhost:8082"
    echo "  MinIO:       http://localhost:9001"
    echo
    
    echo "=================================================================="
    log_success "凭据信息显示完成"
    echo
    log_warn "⚠️  安全提醒:"
    echo "  1. 请妥善保管.env文件，不要将其提交到版本控制系统"
    echo "  2. 定期更换重要的密码和令牌"
    echo "  3. 在生产环境中使用强密码"
    echo "  4. 限制.env文件的访问权限 (chmod 600 .env)"
    echo "=================================================================="
}

# 设置.env文件权限
set_env_permissions() {
    local env_file="$1"
    log_info "设置环境文件权限..."
    chmod 600 "$env_file" || log_warn "无法设置文件权限"
}

# 主函数
main() {
    local env_file="${1:-.env}"
    
    echo "=================================================================="
    echo "🔍 Daytona 凭据查看工具"
    echo "=================================================================="
    echo
    
    # 检查.env文件
    check_env_file "$env_file"
    
    # 显示凭据
    show_credentials "$env_file"
    
    # 设置文件权限
    set_env_permissions "$env_file"
    
    echo "📝 相关命令:"
    echo "  查看服务状态: docker compose -f deploy/docker-compose.yml ps"
    echo "  查看服务日志: docker compose -f deploy/docker-compose.yml logs [service]"
    echo "  重新生成凭据: 删除.env文件后重新运行安装脚本"
    echo
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi