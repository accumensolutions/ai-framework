# Ensure setup halts instantly if an operation throws an exception
$ErrorActionPreference = "Stop"

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "🚀 INITIALIZING COMPLETE PROJECT JOY MASTER WORKSPACE..." -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

# 1. Structure the complete folder tree under enterprise rules (Clean data_ref at root)
New-Item -ItemType Directory -Force -Path `
  "data_ref", `
  "src/joy-backend/chroma_storage", `
  "src/joy-frontend/src/components", `
  "tests/backend", `
  "prompts", `
  "docs/validation_reports/chatbot" | Out-Null

Write-Host "  ✅ Scaffolded unified local directory trees successfully (Flexible data_ref at root)." -ForegroundColor Green

# 2. Append required local vector and data processing packages to requirements
$depsContent = @'
chromadb>=0.5.0
openpyxl>=3.1.0
python-pptx>=0.6.23
python-docx>=1.1.0
pypdf>=4.0.0
extract-msg>=0.48.0
pytest>=8.0.0
requests>=2.31.0
'@
Set-Content -Path "src/joy-backend/requirements.txt" -Value $depsContent
Write-Host "  ✅ Generated requirements.txt." -ForegroundColor Green

# 3. Generate the Complete Production Backend API Layer (src/joy-backend/app.py)
$appCode = @'
import os
import sqlite3
from datetime import datetime
from fastapi import FastAPI, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from rag_engine import execute_offline_rag_query, run_auto_scanning_context_refresh

app = FastAPI(title="Project Joy Core API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DB_PATH = "joy.db"

@app.on_event("startup")
def init_backend_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS portfolio_metrics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT, group_name TEXT, initiative_title TEXT,
            status TEXT, defect_count INTEGER, defect_priority TEXT,
            allocation_percentage INTEGER
        )
    """)
    conn.commit()
    conn.close()
    run_auto_scanning_context_refresh()

class ChatRequest(BaseModel):
    prompt: str

@app.post("/api/v1/chat")
def process_chatbot_query(request: ChatRequest):
    return {"response": execute_offline_rag_query(request.prompt)}

@app.post("/api/v1/pipeline/trigger")
def trigger_pipeline_sync(background_tasks: BackgroundTasks):
    background_tasks.add_task(run_auto_scanning_context_refresh)
    return {"status": "Vector database refresh executing asynchronously."}
'@
Set-Content -Path "src/joy-backend/app.py" -Value $appCode
Write-Host "  ✅ Auto-generated API layer: src/joy-backend/app.py" -ForegroundColor Green

# 4. Generate the On-Disk ChromaDB Enterprise RAG Engine (src/joy-backend/rag_engine.py)
$ragCode = @'
import os
import sqlite3
import hashlib
import re
from datetime import datetime
import chromadb
from chromadb.utils import embedding_functions
import openpyxl
from docx import Document
from pypdf import PdfReader
import extract_msg

DATA_REF_ROOT = "data_ref"
DB_PATH = "joy.db"
VECTOR_DB_DIR = "src/joy-backend/chroma_storage"

chroma_client = chromadb.PersistentClient(path=VECTOR_DB_DIR)
local_ef = embedding_functions.DefaultEmbeddingFunction()
collection = chroma_client.get_or_create_collection(
    name="joy_enterprise_knowledge_base",
    embedding_function=local_ef,
    metadata={"hnsw:space": "cosine"}
)

def chunk_text_sliding_window(text, chunk_size=150, overlap=25):
    words = text.split()
    if len(words) <= chunk_size: return [text]
    chunks = []
    start = 0
    while start < len(words):
        chunks.append(" ".join(words[start:start+chunk_size]))
        start += (chunk_size - overlap)
    return chunks

def extract_text_from_file(file_path):
    ext = os.path.splitext(file_path).lower()
    text = ""
    try:
        if ext in [".txt", ".eml"]:
            with open(file_path, "r", encoding="utf-8", errors="ignore") as f: text = f.read()
        elif ext == ".msg":
            msg = extract_msg.Message(file_path)
            text = f"Subject: {msg.subject}\nFrom: {msg.sender}\nBody: {msg.body}"
        elif ext == ".docx":
            text = "\n".join([p.text for p in Document(file_path).paragraphs])
        elif ext == ".xlsx":
            wb = openpyxl.load_workbook(file_path, data_only=True)
            for s in wb.worksheets:
                for r in s.iter_rows(values_only=True):
                    if r: text += " ".join([str(c) for c in r if c is not None]) + "\n"
        elif ext == ".pdf":
            for p in PdfReader(file_path).pages: text += p.extract_text() or ""
    except Exception as e:
        print(f"⚠️ Skip parsing for {file_path}: {e}")
    return text.strip()

def run_auto_scanning_context_refresh():
    if not os.path.exists(DATA_REF_ROOT): os.makedirs(DATA_REF_ROOT)
    active_manifest = {}
    
    # RECURSIVE DRILL DOWN: Walks through main folder and any dynamically created subfolders
    for root, dirs, files in os.walk(DATA_REF_ROOT):
        for file in files:
            fp = os.path.join(root, file)
            ts = os.path.getmtime(fp)
            txt = extract_text_from_file(fp)
            if not txt: continue
            
            # Semantic topic grouping (e.g., 'Project X')
            match = re.search(r"(project\s+[a-zA-Z0-9_-]+|initiative\s+[a-zA-Z0-9_-]+)", txt.lower())
            topic_key = match.group(1) if match else file.lower()
            
            # TIME-VARIANT RELEVANCE EVALUATION
            if topic_key in active_manifest:
                if ts > active_manifest[topic_key][1]: 
                    active_manifest[topic_key] = (fp, ts, txt)
            else: 
                active_manifest[topic_key] = (fp, ts, txt)
                
    if active_manifest:
        global collection
        try: chroma_client.delete_collection("joy_enterprise_knowledge_base")
        except Exception: pass
        collection = chroma_client.create_collection("joy_enterprise_knowledge_base", embedding_function=local_ef, metadata={"hnsw:space": "cosine"})
        for topic, (f_path, ts, txt) in active_manifest.items():
            filename = os.path.basename(f_path)
            chunks = chunk_text_sliding_window(txt)
            for idx, chunk in enumerate(chunks):
                collection.add(documents=[chunk], metadatas=[{"source": filename, "topic": topic, "updated_at": ts}], ids=[f"{filename}_{idx}"])

def execute_offline_rag_query(user_query):
    results = collection.query(query_texts=[user_query], n_results=1)
    if not results or not results["documents"] or not results["documents"][0]:
        return "Joy Assistant Vector Gateway: Knowledge base is currently empty. Drop telemetry logs into data_ref/ to initialize."
    doc = results["documents"][0][0]
    meta = results["metadatas"][0][0]
    last_mod = datetime.fromtimestamp(meta["updated_at"]).strftime('%Y-%m-%d %H:%M:%S')
    return f"### 🛡️ Enterprise Knowledge Hub Report\n- **Source Asset:** `{meta['source']}`\n- **Sync Timestamp:** `{last_mod}`\n\n**Vector Match Extraction:**\n> {doc}"
'@
Set-Content -Path "src/joy-backend/rag_engine.py" -Value $ragCode
Write-Host "  ✅ Auto-generated storage pipeline engine: src/joy-backend/rag_engine.py" -ForegroundColor Green

# 5. Generate the Real-Time Background Folder Watcher (src/joy-backend/watcher_worker.py)
$watcherCode = @'
import os
import time
import sys
sys.path.append(os.path.abspath(os.path.dirname(__file__)))
from rag_engine import run_auto_scanning_context_refresh

# DYNAMIC WATCHDOG: Monitors modifications across root folder and all sub-directories recursively
WATCH_DIR = "data_ref"
if __name__ == '__main__':
    print(f"🛰️  Surveillance active on project root zone: /{WATCH_DIR}/ and all subdirectories recursively.")
    last_state = {}
    while True:
        time.sleep(5)
        curr_state = {}
        for r, d, fs in os.walk(WATCH_DIR):
            for f in fs:
                fp = os.path.join(r, f)
                curr_state[fp] = os.path.getmtime(fp)
                
        if curr_state != last_state:
            print("🔔 [Watchdog Alert] Folder mutations or additions detected. Re-compiling indices...")
            run_auto_scanning_context_refresh()
            last_state = curr_state
'@
Set-Content -Path "src/joy-backend/watcher_worker.py" -Value $watcherCode
Write-Host "  ✅ Auto-generated real-time directory watcher: src/joy-backend/watcher_worker.py" -ForegroundColor Green

# 6. Generate the Complete Pytest Automated Suite (tests/backend/test_joy_chatbot.py)
$testCode = @'
import os
import pytest
from fastapi.testclient import TestClient
import sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../src/joy-backend')))
from app import app
import rag_engine

client = TestClient(app)
TEST_ZONE = "data_ref_test"

@pytest.fixture(autouse=True)
def run_sandbox():
    orig_zone = rag_engine.DATA_REF_ROOT
    rag_engine.DATA_REF_ROOT = TEST_ZONE
    if not os.path.exists(TEST_ZONE): os.makedirs(TEST_ZONE)
    yield
    if os.path.exists(TEST_ZONE):
        import shutil
        shutil.rmtree(TEST_ZONE)
    rag_engine.DATA_REF_ROOT = orig_zone

def test_01_time_variant_vector_invalidation_across_subfolders():
    # Test file placed directly in root test directory
    old_file = os.path.join(TEST_ZONE, "sprint_1.txt")
    with open(old_file, "w", encoding="utf-8") as f:
        f.write("Project X status is RED due to critical quality blocks.")
    rag_engine.run_auto_scanning_context_refresh()
    
    res1 = client.post("/api/v1/chat", json={"prompt": "What is the status of Project X?"})
    assert "RED" in res1.json()["response"]

    # Test file placed inside a dynamically created subfolder
    sub_dir = os.path.join(TEST_ZONE, "nested_emails_folder")
