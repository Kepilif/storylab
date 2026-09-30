param([switch]$RefreshDebt)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    $env:QUARTO_PYTHON = Join-Path $projectRoot '.venv\Scripts\python.exe'
    $env:JUPYTER_PATH = Join-Path $projectRoot '.venv\share\jupyter'
    & $env:QUARTO_PYTHON scripts/check_climate.py
    if ($LASTEXITCODE -ne 0) { throw 'Climate integrity check failed' }
    if ($RefreshDebt -or -not (Test-Path 'stories/public_debt_storytelling/data/processed/debt_quarterly.csv')) {
        & $env:QUARTO_PYTHON stories/public_debt_storytelling/scripts/01_build_debt_story_data.py
        if ($LASTEXITCODE -ne 0) { throw 'Debt pipeline failed' }
    }
    foreach ($directory in @('_site', 'public')) {
        $target = [IO.Path]::GetFullPath((Join-Path $projectRoot $directory))
        if ($target -ne (Join-Path $projectRoot $directory)) { throw 'Unexpected output path' }
        if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }
    }
    quarto render
    if ($LASTEXITCODE -ne 0) { throw 'Quarto render failed' }
    & $env:QUARTO_PYTHON scripts/check_climate.py
    if ($LASTEXITCODE -ne 0) { throw 'Climate changed during render' }
    & $env:QUARTO_PYTHON scripts/verify_site.py
    if ($LASTEXITCODE -ne 0) { throw 'Site validation failed' }
    Copy-Item -LiteralPath '_site' -Destination 'public' -Recurse
    New-Item -ItemType File -Path 'public/.nojekyll' -Force | Out-Null
} finally { Pop-Location }
