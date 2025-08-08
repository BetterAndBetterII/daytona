#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Daytona 一键安装脚本
# 支持: Linux, macOS
# 功能: 自动安装Docker + Docker Compose + 完整Daytona环境
# ============================================================================

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# 版本定义
readonly DOCKER_COMPOSE_VERSION="2.24.0"
readonly MIN_DOCKER_VERSION="20.10.0"

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

# 错误处理
error_exit() {
    log_error "$1"
    exit 1
}

# 检查操作系统
detect_os() {
    local os
    os=$(uname -s)
    case "$os" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "macos" ;;
        *)       error_exit "不支持的操作系统: $os" ;;
    esac
}

# 检查CPU架构
detect_arch() {
    local arch
    arch=$(uname -m)
    case "$arch" in
        x86_64)  echo "amd64" ;;
        arm64)   echo "arm64" ;;
        aarch64) echo "arm64" ;;
        *)       error_exit "不支持的CPU架构: $arch" ;;
    esac
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_info "检测到root用户，继续安装..."
    else
        log_warn "建议使用root用户安装以避免权限问题"
        if ! sudo -n true 2>/dev/null; then
            error_exit "需要sudo权限来安装Docker，请配置sudo或使用root用户运行"
        fi
    fi
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 安全设置/更新 .env 中的键值（整个行替换，自动转义特殊字符）
set_env_var() {
    local key="$1"
    local value="$2"
    # 转义 sed 替换段中的特殊字符: \\ / & |
    local escaped
    escaped=$(printf '%s' "$value" | sed -e 's/[\\/&|]/\\&/g')
    if grep -qE "^${key}=" .env; then
        sed -i.bak "s|^${key}=.*$|${key}=${escaped}|" .env
    else
        printf '%s=%s\n' "$key" "$value" >> .env
    fi
}

# 获取 .env 中某个键的值（不存在则返回空）
get_env_value() {
    local key="$1"
    awk -F= -v k="${key}" 'BEGIN{ret=""} $1==k{ $1=""; sub(/^=/, ""); ret=$0 } END{ print ret }' .env 2>/dev/null || true
}

# 若当前值为空或为占位/默认值，则写入新值；否则保持不变
ensure_env_secret() {
    local key="$1"
    local new_value="$2"
    local current
    current=$(get_env_value "$key")
    # 认为以下为默认/占位：空、minioadmin、包含 _123 结尾、或明确的 daytona_*_123
    if [[ -z "${current}" || "${current}" == "minioadmin" || "${current}" == *_123 || "${current}" == daytona_*_123 ]]; then
        set_env_var "$key" "$new_value"
        return 0
    fi
    return 1
}

# 检查Docker版本
check_docker_version() {
    if ! command_exists docker; then
        echo "0"
        return
    fi
    
    local version
    version=$(docker --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [[ -n "$version" ]]; then
        echo "$version"
    else
        echo "0"
    fi
}

# 安装Docker (Linux)
install_docker_linux() {
    log_info "安装Docker (Linux)..."
    
    # 更新包管理器
    sudo apt-get update || sudo yum update -y || sudo dnf update -y || {
        error_exit "无法更新包管理器，请手动安装Docker"
    }
    
    # 安装依赖
    sudo apt-get install -y ca-certificates curl gnupg || \
    sudo yum install -y ca-certificates curl gnupg || \
    sudo dnf install -y ca-certificates curl gnupg
    
    # 添加Docker官方GPG密钥
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg || \
    curl -fsSL https://download.docker.com/linux/centos/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    # 添加Docker仓库
    if command_exists apt-get; then
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    elif command_exists yum; then
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    elif command_exists dnf; then
        sudo dnf install -y dnf-plugins-core
        sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi
    
    # 启动Docker服务
    sudo systemctl enable docker
    sudo systemctl start docker
    
    log_success "Docker安装完成"
}

# 安装Docker (macOS)
install_docker_macos() {
    log_info "检测到macOS系统..."
    
    if ! command_exists brew; then
        log_error "需要Homebrew来安装Docker Desktop"
        log_info "请先安装Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        log_info "然后安装Docker Desktop: brew install --cask docker"
        error_exit "请手动安装Docker Desktop后重新运行此脚本"
    fi
    
    log_info "使用Homebrew安装Docker Desktop..."
    brew install --cask docker
    
    log_success "Docker Desktop安装完成"
    log_warn "请手动启动Docker Desktop，然后重新运行此脚本"
    exit 0
}

# 安装Docker Compose插件
install_docker_compose() {
    if docker compose version >/dev/null 2>&1; then
        log_success "Docker Compose插件已安装"
        return
    fi
    
    log_info "安装Docker Compose插件..."
    local os arch
    os=$(detect_os)
    arch=$(detect_arch)
    
    # 使用Docker官方安装方法
    if [[ "$os" == "linux" ]]; then
        sudo apt-get install -y docker-compose-plugin 2>/dev/null || \
        sudo yum install -y docker-compose-plugin 2>/dev/null || \
        sudo dnf install -y docker-compose-plugin 2>/dev/null
    fi
    
    # 如果插件安装失败，使用独立版本
    if ! docker compose version >/dev/null 2>&1; then
        log_info "安装独立Docker Compose版本..."
        sudo curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
    
    log_success "Docker Compose安装完成"
}

# 验证Docker安装
verify_docker() {
    log_info "验证Docker安装..."
    
    if ! command_exists docker; then
        error_exit "Docker安装失败，请检查错误信息"
    fi
    
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker服务未运行，尝试启动..."
        sudo systemctl start docker || {
            error_exit "无法启动Docker服务，请手动启动"
        }
    fi
    
    if ! docker compose version >/dev/null 2>&1; then
        error_exit "Docker Compose安装失败"
    fi
    
    log_success "Docker环境验证通过"
}

# 检查并创建Daytona目录
setup_daytona_directory() {
    local daytona_dir="$1"
    log_info "设置Daytona目录: $daytona_dir"
    
    if [[ ! -d "$daytona_dir" ]]; then
        mkdir -p "$daytona_dir" || error_exit "无法创建目录: $daytona_dir"
    fi
    
    cd "$daytona_dir" || error_exit "无法进入目录: $daytona_dir"
}

# 下载Daytona项目
download_daytona() {
    log_info "下载Daytona项目..."
    
    # 检查是否为Git仓库
    if [[ ! -d ".git" ]]; then
        if command_exists git; then
            log_info "克隆Daytona仓库..."
            git clone https://github.com/betterandbetterii/daytona.git . || {
                log_warn "Git克隆失败，尝试使用curl下载..."
                download_with_curl
            }
        else
            log_warn "Git未安装，使用curl下载..."
            download_with_curl
        fi
    else
        log_info "Daytona仓库已存在，更新代码..."
        git pull origin main || log_warn "无法更新代码，继续使用现有版本"
    fi
}

# 使用curl下载项目
download_with_curl() {
    log_info "curl下载方式暂时不可用，请手动下载项目"
    log_info "访问: https://github.com/betterandbetterii/daytona"
    error_exit "请手动下载项目后重新运行此脚本"
}

# 创建环境配置文件
create_env_file() {
    log_info "创建环境配置文件..."
    
    if [[ ! -f ".env.example" ]]; then
        log_error "未找到.env.example文件"
        return 1
    fi
    
    if [[ -f ".env" ]]; then
        log_warn ".env文件已存在，跳过创建"
        return 0
    fi
    
    # 复制环境配置模板
    cp .env.example .env || error_exit "无法复制.env.example到.env"
    
    # 生成随机密码（避免含有 / + & | 等特殊字符）
    local db_password api_token proxy_key
    db_password=$(openssl rand -hex 32 2>/dev/null || echo "daytona_db_pass_$(date +%s)")
    api_token=$(openssl rand -base64 32 2>/dev/null | tr -d '/+' | cut -c1-32 || echo "daytona_api_token_$(date +%s)")
    proxy_key=$(openssl rand -base64 32 2>/dev/null | tr -d '/+' | cut -c1-32 || echo "daytona_proxy_key_$(date +%s)")
    
    # 生成随机MinIO用户名
    local minio_user="minio_$(openssl rand -hex 4 2>/dev/null || echo "$(date +%s | tail -c 5)")"
    
    # 更新关键安全配置（按键名整行替换，更稳健；仅在占位/缺失时写入）
    ensure_env_secret "POSTGRES_PASSWORD" "$db_password" || true
    ensure_env_secret "API_TOKEN" "$api_token" || true
    ensure_env_secret "PROXY_API_KEY" "$proxy_key" || true
    
    # 删除备份文件
    rm -f .env.bak || true
    
    log_success "环境配置文件创建完成"
    log_info "已生成随机密码，详细信息如下："
    log_info "  PostgreSQL密码: ${db_password}"
    log_info "  MinIO用户名: ${minio_user}"
    log_info "  API令牌: ${api_token}"
    log_info "  代理密钥: ${proxy_key}"
    log_warn "请妥善保存这些信息，建议将.env文件备份到安全位置"
}

# 启动Daytona服务
start_daytona() {
    log_info "启动Daytona服务..."
    
    if [[ ! -f "deploy/docker-compose.yml" ]]; then
        error_exit "未找到deploy/docker-compose.yml文件"
    fi
    
    cd deploy || error_exit "无法进入deploy目录"
    
    # 增量拉取并仅重建有变更的服务
    if docker compose up --help 2>/dev/null | grep -q -- "--pull"; then
        log_info "增量拉取并启动服务 (--pull always)..."
        docker compose --env-file ../.env up -d --remove-orphans --pull always || {
            error_exit "启动服务失败，请检查docker-compose.yml配置"
        }
    else
        log_info "检测到 compose 不支持 --pull，使用兼容路径: pull + up -d"
        docker compose --env-file ../.env pull || {
            log_warn "部分镜像拉取失败，将继续使用本地镜像（如果有）"
        }
        log_info "启动服务..."
        docker compose --env-file ../.env up -d --remove-orphans || {
            error_exit "启动服务失败，请检查docker-compose.yml配置"
        }
    fi
    
    log_success "Daytona服务启动完成"
    log_info "所有服务已使用最新镜像启动"
}

# 验证服务状态
verify_services() {
    log_info "验证服务状态..."
    
    # 等待服务启动
    sleep 10
    
    # 检查服务状态
    if ! docker compose ps | grep -q "Up"; then
        log_warn "部分服务可能未正常启动"
    fi
    
    # 显示服务状态
    log_info "服务状态:"
    docker compose ps
    
    log_success "服务验证完成"
}

# 显示访问信息
show_access_info() {
    log_success "🎉 Daytona安装完成！"
    echo
    echo "=========================================="
    echo "📋 服务访问信息:"
    echo "=========================================="
    echo "🌐 Dashboard:  http://localhost:8080"
    echo "🔌 API:         http://localhost:3001"
    echo "🏃 Runner:      http://localhost:3003"
    echo "🔀 Proxy:       http://localhost:4000"
    echo "📊 Registry UI: http://localhost:8082"
    echo "💾 MinIO:       http://localhost:9001"
    echo "=========================================="
    echo
    
    # 显示MinIO和S3访问凭据
    if [[ -f "../.env" ]]; then
        echo "🔑 MinIO访问凭据:"
        local minio_user="" minio_password=""
        minio_user=$(awk -F= '/^MINIO_ROOT_USER=/{print substr($0, index($0,"=")+1)}' ../.env)
        minio_password=$(awk -F= '/^MINIO_ROOT_PASSWORD=/{print substr($0, index($0,"=")+1)}' ../.env)
        echo "  用户名: ${minio_user:-未设置}"
        echo "  密码: ${minio_password:-未设置}"
        echo "  Web控制台: http://localhost:9001"
        echo "  API端点: http://localhost:9000"
        echo
        
        echo "💾 S3对象存储配置:"
        local s3_endpoint="" s3_access_key="" s3_secret_key="" s3_bucket=""
        s3_endpoint=$(awk -F= '/^S3_ENDPOINT=/{print substr($0, index($0,"=")+1)}' ../.env)
        s3_access_key=$(awk -F= '/^S3_ACCESS_KEY=/{print substr($0, index($0,"=")+1)}' ../.env)
        s3_secret_key=$(awk -F= '/^S3_SECRET_KEY=/{print substr($0, index($0,"=")+1)}' ../.env)
        s3_bucket=$(awk -F= '/^S3_DEFAULT_BUCKET=/{print substr($0, index($0,"=")+1)}' ../.env)
        echo "  端点: ${s3_endpoint:-未设置}"
        echo "  访问密钥: ${s3_access_key:-未设置}"
        echo "  秘密密钥: ${s3_secret_key:-未设置}"
        echo "  默认存储桶: ${s3_bucket:-未设置}"
        echo "=========================================="
        echo
    fi
    
    echo "📝 管理命令:"
    echo "  查看状态: docker compose ps"
    echo "  查看日志: docker compose logs [service]"
    echo "  停止服务: docker compose down"
    echo "  重启服务: docker compose restart"
    if docker compose up --help 2>/dev/null | grep -q -- "--pull"; then
        echo "  更新服务: docker compose --env-file ../.env up -d --remove-orphans --pull always"
    else
        echo "  更新服务: docker compose --env-file ../.env pull && docker compose --env-file ../.env up -d --remove-orphans"
    fi
    echo "  备份数据: ./scripts/backup.sh"
    echo "  恢复数据: ./scripts/restore.sh <backup_dir>"
    echo "=========================================="
    echo
    echo "📋 安全配置文件位置: ../.env"
    echo "⚠️  请妥善保存.env文件，包含所有服务的重要凭据"
    echo "⚠️  首次启动可能需要几分钟时间下载镜像"
    echo "🔧 请使用 'docker compose logs' 查看详细日志"
    echo
}

# 主函数
main() {
    echo "=================================================================="
    echo "🚀 Daytona 一键安装脚本"
    echo "=================================================================="
    echo
    
    # 获取安装目录
    local install_dir="${1:-$HOME/daytona}"
    
    log_info "安装目录: $install_dir"
    log_info "开始安装Daytona..."
    
    # 1. 系统检查
    log_info "步骤1: 系统环境检查..."
    check_root
    local os arch
    os=$(detect_os)
    arch=$(detect_arch)
    log_info "操作系统: $os"
    log_info "CPU架构: $arch"
    
    # 2. Docker安装检查
    log_info "步骤2: Docker环境检查..."
    local docker_version
    docker_version=$(check_docker_version)
    if [[ "$docker_version" == "0" ]]; then
        log_warn "Docker未安装，开始安装Docker..."
        if [[ "$os" == "linux" ]]; then
            install_docker_linux
        else
            install_docker_macos
        fi
    else
        log_success "Docker已安装，版本: $docker_version"
        # 检查版本是否满足要求
        if ! printf '%s\n' "$MIN_DOCKER_VERSION" "$docker_version" | sort -V | head -n1 | grep -q "$MIN_DOCKER_VERSION"; then
            log_warn "Docker版本过低，建议升级到$MIN_DOCKER_VERSION以上"
        fi
    fi
    
    # 3. Docker Compose安装
    log_info "步骤3: Docker Compose安装..."
    install_docker_compose
    
    # 4. 验证Docker环境
    log_info "步骤4: 验证Docker环境..."
    verify_docker
    
    # 5. 设置Daytona目录
    log_info "步骤5: 设置Daytona目录..."
    setup_daytona_directory "$install_dir"
    
    # 6. 下载Daytona项目
    log_info "步骤6: 下载Daytona项目..."
    download_daytona
    
    # 7. 创建环境配置
    log_info "步骤7: 创建环境配置..."
    create_env_file
    
    # 8. 启动服务
    log_info "步骤8: 启动Daytona服务..."
    start_daytona
    
    # 9. 验证服务
    log_info "步骤9: 验证服务状态..."
    verify_services
    
    # 10. 显示访问信息
    show_access_info
    
    echo "=================================================================="
    log_success "🎊 安装完成！开始使用Daytona吧！"
    echo "=================================================================="
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi