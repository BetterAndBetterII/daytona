Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$RootDir = Join-Path $ScriptDir '..'
Set-Location $RootDir

Write-Host "[INFO] 正在停止并移除服务容器..."
docker compose down
Write-Host "[OK] 已停止。"
