param([string]$Root = 'D:\deep seek\workspace\进行中\四级计划')
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$planPath = Join-Path $Root 'plan.md'
$fbDir = Join-Path $Root '反馈'
if (-not (Test-Path $planPath)) { Write-Output "找不到 plan.md"; exit 1 }

$files = Get-ChildItem $fbDir -File -Filter '*.md' -ErrorAction SilentlyContinue | Sort-Object Name -Descending
if ($files.Count -eq 0) { Write-Output "没有反馈文件"; exit 1 }

$plan = Get-Content $planPath -Raw -Encoding UTF8
$blocks = ($files | ForEach-Object {
    $body = (Get-Content $_.FullName -Raw -Encoding UTF8).Trim()
    $body
}) -join "`n`n"

$updated = $blocks + "`n`n（共 " + $files.Count + " 条反馈，最新 " + $files[0].BaseName + "）"
$plan = [regex]::Replace($plan, '(?s)## 最近反馈（按日期倒序）.*?## 明日微调', "## 最近反馈（按日期倒序）`n`n$updated`n`n## 明日微调")
$plan = [regex]::Replace($plan, '最后更新：.*', ('最后更新：' + (Get-Date -Format 'yyyy-MM-dd HH:mm')))
Set-Content -LiteralPath $planPath -Value $plan -Encoding UTF8 -NoNewline

Write-Output ("已合并 {0} 条反馈到 plan.md，最后更新 {1}" -f $files.Count, (Get-Date -Format 'HH:mm:ss'))