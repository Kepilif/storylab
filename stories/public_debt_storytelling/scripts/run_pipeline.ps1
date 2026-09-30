$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$projectRoot = Split-Path -Parent (Split-Path -Parent $root)
$python = Join-Path $projectRoot '.venv\Scripts\python.exe'

& $python "$root\scripts\01_build_debt_story_data.py"
if ($LASTEXITCODE -ne 0) { throw 'Debt pipeline failed' }

Write-Host "Pipeline finished."
