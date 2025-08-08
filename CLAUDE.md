# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 开发命令

### 构建和测试
- `yarn build` - 以开发模式构建所有应用程序和库
- `yarn build:production` - 以生产模式构建所有应用程序和库
- `yarn lint` - 运行所有代码检查工具（TypeScript、Python、Jupyter）
- `yarn format` - 格式化所有代码（TypeScript、Python、Markdown、Jupyter）
- `yarn test` - 运行所有测试

### 开发服务器
- `yarn serve` - 启动所有开发服务器（排除daemon）
- `yarn serve:skip-runner` - 启动开发服务器（排除runner和daemon）
- `yarn serve:skip-proxy` - 启动开发服务器（排除proxy和daemon）
- `yarn serve:production` - 启动所有生产服务器

### 代码生成
- `yarn generate:openapi` - 生成OpenAPI规范
- `yarn generate:api-client` - 为所有语言生成API客户端

### 数据库迁移
- `yarn migration:generate` - 生成新的数据库迁移
- `yarn migration:run` - 运行待处理的迁移
- `yarn migration:revert` - 回滚最后的迁移

### 特定语言命令
- `yarn lint:ts` - 检查TypeScript文件
- `yarn lint:py` - 检查Python文件
- `yarn lint:jupyter` - 检查Jupyter笔记本
- `yarn format:py` - 格式化Python代码
- `yarn format:jupyter` - 格式化Jupyter笔记本

## 目录结构

### 根目录结构
```
daytona/
├── apps/                 # 应用程序目录
├── libs/                 # 库文件目录
├── examples/            # 示例代码目录
├── assets/              # 静态资源文件
├── functions/           # 云函数
├── docs/                # 文档站点
├── ecosystem.config.js  # 生态系统配置
├── nx.json              # Nx构建系统配置
├── package.json         # Node.js依赖和脚本
├── go.work              # Go工作区配置
├── pyproject.toml       # Python项目配置
├── tsconfig.base.json   # TypeScript基础配置
└── yarn.lock            # Yarn依赖锁定文件
```

### 应用程序目录 (apps/)

#### 1. API服务器 (apps/api/)
NestJS后端API服务器，提供完整的RESTful API服务

```
apps/api/
├── src/
│   ├── analytics/              # 分析服务模块
│   │   └── services/
│   ├── api-key/                # API密钥管理
│   │   ├── api-key.controller.ts
│   │   ├── api-key.entity.ts
│   │   └── api-key.service.ts
│   ├── audit/                  # 审计日志系统
│   │   ├── controllers/
│   │   ├── entities/
│   │   ├── events/
│   │   ├── interceptors/
│   │   └── services/
│   ├── auth/                   # 身份验证
│   │   ├── api-key.strategy.ts
│   │   ├── jwt.strategy.ts
│   │   └── auth.module.ts
│   ├── common/                 # 通用功能和中间件
│   │   ├── decorators/
│   │   ├── interfaces/
│   │   ├── middleware/
│   │   └── utils/
│   ├── config/                 # 配置管理
│   │   ├── typed-config.module.ts
│   │   └── typed-config.service.ts
│   ├── docker-registry/        # Docker注册表管理
│   ├── email/                  # 邮件服务
│   ├── exceptions/             # 异常处理
│   ├── filters/                # 全局过滤器
│   ├── migrations/             # 数据库迁移文件
│   ├── notification/           # 通知系统
│   ├── object-storage/         # 对象存储服务
│   ├── organization/           # 组织管理
│   │   ├── controllers/
│   │   ├── entities/
│   │   ├── events/
│   │   ├── guards/
│   │   └── services/
│   ├── sandbox/                # 沙箱管理核心
│   │   ├── controllers/        # 沙箱控制器
│   │   ├── services/          # 沙箱服务
│   │   ├── entities/          # 数据实体
│   │   ├── enums/             # 枚举定义
│   │   ├── events/            # 事件系统
│   │   └── managers/          # 业务管理器
│   ├── tracing.ts             # OpenTelemetry追踪
│   ├── usage/                 # 使用情况统计
│   └── user/                  # 用户管理
├── main.ts                    # 应用入口文件
├── Dockerfile                 # Docker构建配置
└── package.json              # 项目依赖
```

**功能模块说明：**
- **Analytics**: 用户行为分析和数据统计
- **API Key**: API密钥的创建、管理和权限控制
- **Audit**: 完整的操作审计日志系统
- **Auth**: JWT + API密钥双重认证机制
- **Sandbox**: 沙箱的完整生命周期管理
- **Organization**: 多租户组织架构支持
- **User**: 用户账户管理和认证

#### 2. CLI工具 (apps/cli/)
Go语言编写的命令行工具，提供与Daytona交互的完整命令集

```
apps/cli/
├── cmd/
│   ├── auth/                  # 认证相关命令
│   │   ├── login.go          # 登录命令
│   │   └── logout.go         # 登出命令
│   ├── sandbox/              # 沙箱管理命令
│   │   ├── create.go         # 创建沙箱
│   │   ├── delete.go         # 删除沙箱
│   │   ├── start.go          # 启动沙箱
│   │   └── stop.go           # 停止沙箱
│   ├── snapshot/             # 快照管理命令
│   │   ├── create.go         # 创建快照
│   │   ├── delete.go         # 删除快照
│   │   └── list.go           # 列出快照
│   ├── volume/               # 卷管理命令
│   ├── organization/         # 组织管理命令
│   ├── mcp/                  # MCP (Model Context Protocol) 命令
│   │   ├── agents/           # AI代理配置
│   │   │   ├── claude.go     # Claude代理
│   │   │   ├── cursor.go     # Cursor代理
│   │   │   └── windsurf.go   # Windsurf代理
│   │   ├── config.go         # MCP配置
│   │   ├── init.go           # MCP初始化
│   │   └── start.go          # MCP服务器启动
│   ├── docs.go               # 文档生成
│   └── version.go            # 版本信息
├── mcp/                      # MCP服务器实现
│   ├── server.go             # MCP服务器主文件
│   └── tools/                # MCP工具集合
│       ├── create_sandbox.go # 创建沙箱工具
│       ├── execute_command.go # 命令执行工具
│       ├── file_operations.go # 文件操作工具
│       └── git_clone.go      # Git克隆工具
├── config/                   # 配置管理
├── pkg/minio/               # MinIO客户端
├── views/                   # CLI用户界面
│   ├── common/              # 通用视图组件
│   ├── sandbox/             # 沙箱相关视图
│   └── organization/        # 组织相关视图
├── main.go                  # CLI入口文件
└── go.mod                   # Go模块依赖
```

**核心功能：**
- 用户认证和会话管理
- 沙箱的完整生命周期操作
- 快照的创建和管理
- 持久化卷管理
- 多组织支持
- MCP协议集成，支持与各种AI编辑器交互

#### 3. 仪表板 (apps/dashboard/)
React + TypeScript构建的Web管理界面

```
apps/dashboard/
├── src/
│   ├── api/                 # API客户端
│   │   ├── apiClient.ts     # API客户端封装
│   │   └── errors.ts        # 错误处理
│   ├── assets/              # 静态资源
│   ├── components/          # React组件
│   │   ├── ApiKeyTable.tsx          # API密钥表格
│   │   ├── SandboxTable.tsx         # 沙箱管理表格
│   │   ├── OrganizationMembers/     # 组织成员管理
│   │   ├── OrganizationRoles/       # 组织角色管理
│   │   ├── VolumeTable.tsx          # 卷管理表格
│   │   └── UsageChart.tsx           # 使用量图表
│   ├── contexts/            # React Context
│   │   ├── ApiContext.tsx           # API上下文
│   │   ├── OrganizationsContext.tsx # 组织上下文
│   │   └── BillingContext.tsx       # 计费上下文
│   ├── hooks/               # 自定义React Hooks
│   ├── pages/               # 页面组件
│   │   ├── Dashboard.tsx            # 主仪表板
│   │   ├── Sandboxes.tsx            # 沙箱管理页面
│   │   ├── OrganizationSettings.tsx # 组织设置
│   │   ├── Keys.tsx                 # API密钥管理
│   │   ├── Volumes.tsx              # 卷管理
│   │   └── Wallet.tsx               # 钱包和计费
│   ├── providers/           # Context提供者
│   └── types/               # TypeScript类型定义
├── index.html               # HTML入口
├── tailwind.config.js       # Tailwind CSS配置
└── vite.config.mts         # Vite构建配置
```

**功能特色：**
- 现代化的响应式设计
- 实时沙箱状态监控
- 组织和成员管理
- API密钥管理
- 使用量统计和计费
- 实时通知系统

#### 4. 守护进程 (apps/daemon/)
Go语言编写的后台守护进程，处理工作空间的长期运行任务

```
apps/daemon/
├── cmd/daemon/
│   ├── main.go              # 守护进程入口
│   └── config/              # 配置管理
├── pkg/
│   ├── common/              # 通用功能
│   │   ├── errors.go        # 错误处理
│   │   └── spawn_tty.go     # TTY终端生成
│   ├── git/                 # Git操作封装
│   │   ├── clone.go         # Git克隆
│   │   ├── commit.go        # Git提交
│   │   └── status.go        # Git状态
│   ├── ssh/                 # SSH服务
│   │   ├── server.go        # SSH服务器
│   │   └── unix_forward.go  # Unix套接字转发
│   ├── terminal/            # 终端处理
│   │   ├── server.go        # 终端服务器
│   │   └── static/          # 静态终端资源
│   └── toolbox/             # 工具箱
│       ├── fs/              # 文件系统操作
│       ├── git/             # Git操作
│       ├── lsp/             # 语言服务器协议
│       └── process/         # 进程管理
└── go.mod                  # Go模块依赖
```

**核心职责：**
- 提供SSH访问沙箱的能力
- Git操作的完整封装
- LSP语言服务器支持
- 终端会话管理
- 文件系统操作接口

#### 5. 运行器 (apps/runner/)
Go语言编写的沙箱运行器，负责容器的创建和管理

```
apps/runner/
├── cmd/runner/main.go       # 运行器入口
├── pkg/
│   ├── api/                 # 内部API服务器
│   ├── cache/               # 缓存管理
│   ├── common/              # 通用功能
│   ├── daemon/              # 守护进程相关
│   ├── docker/              # Docker操作封装
│   │   ├── client.go        # Docker客户端
│   │   ├── create.go        # 容器创建
│   │   ├── start.go         # 容器启动
│   │   ├── stop.go          # 容器停止
│   │   ├── image_build.go   # 镜像构建
│   │   └── image_pull.go    # 镜像拉取
│   ├── models/              # 数据模型
│   ├── runner/              # 运行器核心逻辑
│   ├── services/            # 服务层
│   │   ├── sandbox.go       # 沙箱服务
│   │   └── metrics.go       # 指标收集
│   └── storage/             # 存储服务
└── go.mod                  # Go模块依赖
```

**关键功能：**
- Docker容器的生命周期管理
- 沙箱资源的分配和监控
- 镜像构建和缓存
- 存储管理（本地和云存储）
- 性能指标收集

#### 6. 代理服务 (apps/proxy/)
Go语言编写的反向代理服务，处理请求路由和负载均衡

```
apps/proxy/
├── cmd/proxy/main.go        # 代理入口
├── pkg/
│   ├── cache/               # 缓存实现
│   │   ├── map_cache.go     # 内存缓存
│   │   └── redis_cache.go   # Redis缓存
│   └── proxy/               # 代理核心
│       ├── auth.go          # 身份验证
│       ├── proxy.go         # 代理逻辑
│       └── get_target.go    # 目标获取
└── go.mod                  # Go模块依赖
```

**核心功能：**
- 请求路由和负载均衡
- 认证中间件
- 缓存策略
- 请求转发

### 库文件目录 (libs/)

#### 1. API客户端库

**TypeScript API客户端 (libs/api-client/)**
- 从OpenAPI规范自动生成
- 提供完整的TypeScript类型定义
- 包含所有API端点的客户端封装

**Python API客户端 (libs/api-client-python/)**
- 同步版本的Python API客户端
- 支持Python 3.8+
- 完整的类型提示支持

**Python异步API客户端 (libs/api-client-python-async/)**
- 异步版本的Python API客户端
- 基于asyncio实现
- 适合高并发场景

**Go API客户端 (libs/api-client-go/)**
- Go语言的API客户端
- 完整的结构体和方法定义
- 支持Go 1.23+

#### 2. SDK库

**TypeScript SDK (libs/sdk-typescript/)**
```
libs/sdk-typescript/src/
├── Daytona.ts              # 主要SDK入口类
├── Sandbox.ts              # 沙箱管理
├── FileSystem.ts           # 文件系统操作
├── Git.ts                  # Git操作
├── Process.ts              # 进程执行
├── LspServer.ts            # LSP服务器
├── Volume.ts               # 卷管理
├── Snapshot.ts             # 快照管理
├── ComputerUse.ts          # 计算机使用接口
├── Image.ts                # 镜像管理
├── ObjectStorage.ts        # 对象存储
├── code-toolbox/           # 代码工具箱
│   ├── SandboxPythonCodeToolbox.ts
│   └── SandboxTsCodeToolbox.ts
├── errors/                 # 错误处理
├── types/                  # 类型定义
└── utils/                  # 工具函数
```

**Python SDK (libs/sdk-python/)**
```
libs/sdk-python/src/daytona/
├── __init__.py             # SDK入口
├── common/                 # 通用模块
│   ├── daytona.py         # 主要客户端类
│   ├── filesystem.py      # 文件系统
│   ├── git.py            # Git操作
│   ├── lsp_server.py     # LSP服务器
│   ├── process.py        # 进程执行
│   └── sandbox.py        # 沙箱管理
└── code_toolbox/          # 代码工具箱
    ├── sandbox_python_code_toolbox.py
    └── sandbox_ts_code_toolbox.py
```

#### 3. 其他库

**运行器API客户端 (libs/runner-api-client/)**
- 专门用于与运行器服务通信的客户端
- 提供内部API的TypeScript封装

**通用Go库 (libs/common-go/)**
- Go项目的通用功能库
- 错误处理、代理、定时器等

**计算机使用库 (libs/computer-use/)**
- 计算机操作接口
- 键盘、鼠标、截图等功能
- 适合自动化测试场景

### 示例代码目录 (examples/)

#### Python示例 (examples/python/)
```
examples/python/
├── charts/                # 图表生成示例
├── exec-command/          # 命令执行示例
├── file-operations/       # 文件操作示例
├── git-lsp/              # Git和LSP示例
├── lifecycle/            # 沙箱生命周期管理
├── volumes/              # 卷使用示例
├── auto-archive/         # 自动归档示例
├── auto-delete/          # 自动删除示例
└── declarative-image/    # 声明式镜像构建示例
```

每个模块都包含同步和异步两个版本（_async/目录）。

#### TypeScript示例 (examples/typescript/)
```
examples/typescript/
├── charts/               # TypeScript图表示例
├── exec-command/         # 命令执行示例
├── file-operations/      # 文件操作示例
├── git-lsp/             # Git和LSP示例
├── lifecycle/           # 生命周期管理
├── volumes/             # 卷使用示例
├── auto-archive/        # 自动归档
├── auto-delete/         # 自动删除
└── declarative-image/   # 声明式镜像
```

#### Jupyter示例 (examples/jupyter/)
- 提供Jupyter笔记本格式的示例
- 适合数据科学和机器学习场景

## 技术架构

### 核心技术栈
- **后端API**: NestJS (Node.js/TypeScript), PostgreSQL, TypeORM, Redis
- **前端仪表板**: React 19, TypeScript, Tailwind CSS, Vite
- **CLI/守护进程/运行器**: Go 1.23.4, Docker, gRPC
- **构建系统**: Nx monorepo + yarn workspaces
- **身份验证**: JWT tokens + API密钥 + OpenID Connect
- **容器化**: Docker 沙箱隔离
- **测试**: Jest (TS), Pytest (Python), Go Test

### 架构特点

#### 1. 微服务架构
- **API服务器**: 核心业务逻辑和RESTful API
- **CLI工具**: 命令行交互工具
- **守护进程**: 长期运行的后台服务
- **运行器**: 沙箱执行引擎
- **代理服务**: 请求路由和负载均衡

#### 2. 多语言支持
- TypeScript/JavaScript: 前端和SDK
- Python: 数据科学和机器学习SDK
- Go: 高性能系统服务

#### 3. 沙箱生命周期管理
```
创建 → 启动 → 运行 → 停止 → 归档 → 删除
```

#### 4. 多租户组织架构
- 支持多个组织的隔离
- 基于角色的访问控制
- 资源配额管理

#### 5. MCP协议集成
- 内置MCP服务器
- 支持与AI编程工具的集成
- 提供文件操作、命令执行等工具集

### 数据流架构

```
用户 → CLI/Dashboard → API服务器 → 运行器 → Docker容器
                          ↓
                        PostgreSQL (数据持久化)
                          ↓
                        Redis (缓存和会话)
```

## 开发工作流程

### 1. 环境设置
```bash
# 安装依赖
yarn install

# 启动开发服务器
yarn serve

# 运行测试
yarn test
```

### 2. 代码生成
```bash
# 生成OpenAPI规范
yarn generate:openapi

# 生成所有语言的API客户端
yarn generate:api-client
```

### 3. 数据库管理
```bash
# 生成新的迁移
yarn migration:generate

# 运行迁移
yarn migration:run

# 回滚迁移
yarn migration:revert
```

### 4. 构建和部署
```bash
# 开发构建
yarn build

# 生产构建
yarn build:production
```

### 5. 代码质量
- ESLint + Prettier (TypeScript/JavaScript)
- Pylint + Black + isort (Python)
- gofmt (Go)
- Husky pre-commit hooks

## 关键配置文件

### 构建系统
- `nx.json`: Nx构建系统配置
- `package.json`: 根项目依赖和脚本
- `go.work`: Go工作区配置

### 语言配置
- `tsconfig.base.json`: TypeScript基础配置
- `pyproject.toml`: Python项目配置

### 工具配置
- `jest.config.ts`: Jest测试配置
- `tailwind.config.js`: Tailwind CSS配置
- `vite.config.mts`: Vite构建配置

这个架构支持一个完整的AI代码执行平台，具有多语言支持、容器化隔离、多租户架构等企业级特性。