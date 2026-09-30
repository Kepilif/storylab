$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    python -m venv .venv
    if ($LASTEXITCODE -ne 0) { throw 'venv creation failed' }
    & .\.venv\Scripts\python.exe -m pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) { throw 'Dependency installation failed' }
    & .\.venv\Scripts\python.exe -m ipykernel install --prefix .venv --name storylab --display-name StoryLab
    if ($LASTEXITCODE -ne 0) { throw 'Kernel setup failed' }
} finally { Pop-Location }
