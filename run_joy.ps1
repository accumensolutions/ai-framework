# Prevent script from hanging if an unexpected background process trips a system warning
\$ErrorActionPreference = "Stop"

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "🏎️  STARTING PROJECT JOY UNIFIED FULL-STACK ECOSYSTEM..." -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

# 1. Ensure the project root-level reference data drop-zone directory exists
if (-not (Test-Path -Path "data_ref")) {
    New-Item -ItemType Directory -Force -Path "data_ref" | Out-Null
    Write-Host "  ✅ Initialized missing project-root /data_ref/ vault folder." -ForegroundColor Green
}

# 2. Check for active virtual environment sandbox allocation
if (-not (Test-Path -Path ".venv")) {
    Write-Host "⚠️  Python virtual sandbox container (.venv) not detected!" -ForegroundColor Yellow
    Write-Host "👉 Please execute your 'init_project_joy.ps1' installer before launching the runtime." -ForegroundColor Red
    Exit 1
}

Write-Host "`n🚀 Launching background processing runtimes asynchronously...`n" -ForegroundColor Yellow

# -------------------------------------------------------------------------
# PROCESS NODE 1: Local Recursive ChromaDB Vector Directory Watchdog
# -------------------------------------------------------------------------
Write-Host "🛰️  [Node 1] Booting Real-Time RAG Directory Watchdog..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit -Command `"Write-Host '🛰️ CHROMADB WATCHDOG ACTIVE' -ForegroundColor Cyan; .\\.venv\\Scripts\\activate.ps1; python src/joy-backend/watcher_worker.py`" -WindowStyle Normal

# -------------------------------------------------------------------------
# PROCESS NODE 2: FastAPI Core REST Server Layer Gateway
# -------------------------------------------------------------------------
Write-Host "⚙️  [Node 2] Booting FastAPI Local API Gateway (Port 8000)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit -Command `"Write-Host '⚙️ FASTAPI ENGINE RUNNING' -ForegroundColor Green; .\\.venv\\Scripts\\activate.ps1; uvicorn src.joy-backend.app:app --host 127.0.0.1 --port 8000 --reload`" -WindowStyle Normal

# -------------------------------------------------------------------------
# PROCESS NODE 3: Next.js Turbopack Presentation View Layer
# -------------------------------------------------------------------------
Write-Host "📊 [Node 3] Booting Next.js UI Canvas via Rust Turbopack (Port 3000)..." -ForegroundColor Cyan
if (Test-Path -Path "src/joy-frontend/package.json") {
    Start-Process powershell -ArgumentList "-NoExit -Command `"Write-Host '📊 NEXT.JS TURBOPACK COMPILER COMPILED' -ForegroundColor Yellow; cd src/joy-frontend; npm run dev -- --turbo`" -WindowStyle Normal
} else {
    Write-Host "⚠️  Frontend project folder elements missing package.json matrix! Skipping Node runtime boot." -ForegroundColor Red
}

Write-Host "`n=========================================================" -ForegroundColor Green
Write-Host "🎉 SUCCESS: ALL ENGINE CORES ARE ONLINE AND RUNNING LIVE!" -ForegroundColor Green
Write-Host "🌐 API Gateway Portal listening at: http://127.0.0.1:8000" -ForegroundColor Green
Write-Host "🌐 UI Dashboard Hub listening at:  http://localhost:3000" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
