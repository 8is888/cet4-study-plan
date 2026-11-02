param([string]$Root = 'D:\deep seek\workspace\进行中\四级计划', [string]$Message = '每日自动更新')
$ErrorActionPreference = 'Continue'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }
Push-Location $Root
try {
    if (-not (Test-Path (Join-Path $Root '.git'))) {
        & git init -q 2>&1 | Out-Null
        Write-Output '已初始化本地仓库'
    }
    & git add plan.md 2>&1 | Out-Null
    $status = & git status --porcelain 2>&1
    if (-not $status) { Write-Output '没有变更，无需提交'; return }
    & git -c user.name='DSH' -c user.email='dsh@local' commit -q -m $Message 2>&1 | Out-Null
    $log = (& git log -1 --pretty='%h %s' 2>&1)
    Write-Output ("已提交: " + $log)
    $remote = & git remote 2>&1
    if ($remote) {
        & git push -q 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-Output '已推送到远端' } else { Write-Output '推送失败（检查远端地址/凭据）' }
    } else {
        Write-Output '未配置远端，仅本地提交'
    }
} finally { Pop-Location }