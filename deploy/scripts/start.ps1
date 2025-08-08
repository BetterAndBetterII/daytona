Param(
  [string]$EnvFile = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$RootDir = Join-Path $ScriptDir '..'
Set-Location $RootDir

if ([string]::IsNullOrWhiteSpace($EnvFile)) {
  if (Test-Path (Join-Path $RootDir '..' '.env')) {
    $EnvFile = (Join-Path $RootDir '..' '.env')
  } elseif (Test-Path (Join-Path $RootDir '.env')) {
    $EnvFile = (Join-Path $RootDir '.env')
  }
}

if ($EnvFile -and (Test-Path $EnvFile)) {
  Write-Host "[INFO] 使用 .env 文件: $EnvFile"
  docker compose --env-file $EnvFile up -d
} else {
  Write-Host "[INFO] 未检测到 .env，将使用默认值启动。"
  docker compose up -d
}

Write-Host "[OK] 服务已启动。可访问: Dashboard http://localhost:8080, API http://localhost:3001/api"
