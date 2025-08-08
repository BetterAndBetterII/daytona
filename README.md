<div align="center">

[![Documentation](https://img.shields.io/github/v/release/daytonaio/docs?label=Docs&color=23cc71)](https://www.daytona.io/docs)
![License](https://img.shields.io/badge/License-AGPL--3-blue)
[![Go Report Card](https://goreportcard.com/badge/github.com/daytonaio/daytona)](https://goreportcard.com/report/github.com/daytonaio/daytona)
[![Issues - daytona](https://img.shields.io/github/issues/daytonaio/daytona)](https://github.com/daytonaio/daytona/issues)
![GitHub Release](https://img.shields.io/github/v/release/daytonaio/daytona)

</div>

&nbsp;

<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/daytonaio/daytona/raw/main/assets/images/Daytona-logotype-white.png">
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/daytonaio/daytona/raw/main/assets/images/Daytona-logotype-black.png">
    <img alt="Daytona logo" src="https://github.com/daytonaio/daytona/raw/main/assets/images/Daytona-logotype-black.png" width="50%">
  </picture>
</div>

<h3 align="center">
  Run AI Code.
  <br/>
  Secure and Elastic Infrastructure for
  Running Your AI-Generated Code.
</h3>

<p align="center">
    <a href="https://www.daytona.io/docs"> Documentation </a>·
    <a href="https://github.com/daytonaio/daytona/issues/new?assignees=&labels=bug&projects=&template=bug_report.md&title=%F0%9F%90%9B+Bug+Report%3A+"> Report Bug </a>·
    <a href="https://github.com/daytonaio/daytona/issues/new?assignees=&labels=enhancement&projects=&template=feature_request.md&title=%F0%9F%9A%80+Feature%3A+"> Request Feature </a>·
    <a href="https://go.daytona.io/slack"> Join our Slack </a>·
    <a href="https://x.com/daytonaio"> Connect on X </a>
</p>

<p align="center">
    <a href="https://www.producthunt.com/posts/daytona-2?embed=true&utm_source=badge-top-post-badge&utm_medium=badge&utm_souce=badge-daytona&#0045;2" target="_blank"><img src="https://api.producthunt.com/widgets/embed-image/v1/top-post-badge.svg?post_id=957617&theme=neutral&period=daily&t=1746176740150" alt="Daytona&#0032; - Secure&#0032;and&#0032;elastic&#0032;infra&#0032;for&#0032;running&#0032;your&#0032;AI&#0045;generated&#0032;code&#0046; | Product Hunt" style="width: 250px; height: 54px;" width="250" height="54" /></a>
    <a href="https://www.producthunt.com/posts/daytona-2?embed=true&utm_source=badge-top-post-topic-badge&utm_medium=badge&utm_souce=badge-daytona&#0045;2" target="_blank"><img src="https://api.producthunt.com/widgets/embed-image/v1/top-post-topic-badge.svg?post_id=957617&theme=neutral&period=monthly&topic_id=237&t=1746176740150" alt="Daytona&#0032; - Secure&#0032;and&#0032;elastic&#0032;infra&#0032;for&#0032;running&#0032;your&#0032;AI&#0045;generated&#0032;code&#0046; | Product Hunt" style="width: 250px; height: 54px;" width="250" height="54" /></a>
</p>

---

## Installation

### Python SDK

```bash
pip install daytona
```

### TypeScript SDK

```bash
npm install @daytonaio/sdk
```

### Docker 容器化部署（一键安装）

快速部署完整的 Daytona 容器化环境，包含所有核心服务：

```bash
# 一键安装（推荐）
curl -L 'https://raw.githubusercontent.com/BetterAndBetterII/daytona/main/deploy/scripts/install.sh' -o /tmp/install.sh && sudo bash /tmp/install.sh
```

**支持系统：**
- **Linux**: Ubuntu 18.04+, CentOS 7+, Debian 9+
- **macOS**: macOS 10.14+

**安装要求：**
- Docker 20.10+
- Docker Compose 2.0+
- 4GB+ 内存
- 10GB+ 磁盘空间

**手动安装方式：**

```bash
# 1. 克隆项目
git clone https://github.com/BetterAndBetterII/daytona.git
cd daytona

# 2. 运行一键安装脚本
sudo ./deploy/scripts/install.sh
```

**安装完成后访问：**
- 🌐 **Dashboard**: http://localhost:8080
- 🔌 **API**: http://localhost:3001
- 🏃 **Runner**: http://localhost:3003
- 🔀 **Proxy**: http://localhost:4000
- 📊 **Registry UI**: http://localhost:8082
- 💾 **MinIO**: http://localhost:9001

**管理命令：**
```bash
# 查看服务状态
cd daytona/deploy && docker compose ps

# 查看服务日志
docker compose logs [service]

# 停止服务
docker compose down

# 重启服务
docker compose restart

# 更新服务（拉取最新镜像并重启）
docker compose --env-file ../.env pull && docker compose --env-file ../.env up -d --force-recreate

# 备份数据
./scripts/backup.sh

# 恢复数据
./scripts/restore.sh <backup_dir>

# 查看生成的凭据
./scripts/show-credentials.sh
```

**更新说明：**
- 一键安装脚本会自动拉取最新版本的镜像
- 如需手动更新服务，请使用上述更新命令
- 更新过程中会自动清理旧版本的悬空镜像
- 如需清理所有旧版本镜像，请手动执行：`docker image prune -f`

---

## Features

- **Lightning-Fast Infrastructure**: Sub-90ms Sandbox creation from code to execution.
- **Separated & Isolated Runtime**: Execute AI-generated code with zero risk to your infrastructure.
- **Massive Parallelization for Concurrent AI Workflows**: Fork Sandbox filesystem and memory state (Coming soon!)
- **Programmatic Control**: File, Git, LSP, and Execute API
- **Unlimited Persistence**: Your Sandboxes can live forever
- **OCI/Docker Compatibility**: Use any OCI/Docker image to create a Sandbox

---

## Quick Start

1. Create an account at https://app.daytona.io
1. Generate a [new API key](https://app.daytona.io/dashboard/keys)
1. Follow the [Getting Started docs](https://www.daytona.io/docs/getting-started/) to start using the Daytona SDK

## Creating your first Sandbox

### Python SDK

```py
from daytona import Daytona, DaytonaConfig, CreateSandboxParams

# Initialize the Daytona client
daytona = Daytona(DaytonaConfig(api_key="YOUR_API_KEY"))

# Create the Sandbox instance
sandbox = daytona.create(CreateSandboxParams(language="python"))

# Run code securely inside the Sandbox
response = sandbox.process.code_run('print("Sum of 3 and 4 is " + str(3 + 4))')
if response.exit_code != 0:
    print(f"Error running code: {response.exit_code} {response.result}")
else:
    print(response.result)

# Clean up the Sandbox
daytona.remove(sandbox)
```

### Typescript SDK

```jsx
import { Daytona } from '@daytonaio/sdk'

async function main() {
  // Initialize the Daytona client
  const daytona = new Daytona({
    apiKey: 'YOUR_API_KEY',
  })

  let sandbox
  try {
    // Create the Sandbox instance
    sandbox = await daytona.create({
      language: 'python',
    })
    // Run code securely inside the Sandbox
    const response = await sandbox.process.codeRun('print("Sum of 3 and 4 is " + str(3 + 4))')
    if (response.exitCode !== 0) {
      console.error('Error running code:', response.exitCode, response.result)
    } else {
      console.log(response.result)
    }
  } catch (error) {
    console.error('Sandbox flow error:', error)
  } finally {
    if (sandbox) await daytona.remove(sandbox)
  }
}

main().catch(console.error)
```

---

## Contributing

Daytona is Open Source under the [GNU AFFERO GENERAL PUBLIC LICENSE](LICENSE), and is the [copyright of its contributors](NOTICE). If you would like to contribute to the software, read the Developer Certificate of Origin Version 1.1 (https://developercertificate.org/). Afterwards, navigate to the [contributing guide](CONTRIBUTING.md) to get started.
