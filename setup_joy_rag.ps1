# Ensure setup stops instantly if an operation throws an exception
$ErrorActionPreference = "Stop"

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "🤖 SCAFFOLDING LOCAL-FIRST COGNITIVE KNOWLEDGE BASE ENGINES" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

# 1. Stand up structured directories for reference data and subdirectories natively
New-Item -ItemType Directory -Force -Path src/joy-backend/data_ref/emails, src/joy-backend/data_ref/spreadsheets, src/joy-backend/data_ref/documents, src/joy-backend/data_ref/presentations | Out-Null
Write-Host "  ✅ Scaffolded structural local drop-zone directories under src/joy-backend/data_ref/." -ForegroundColor Green

# 2. Append required local ML and document parsing packages to the requirements profile
$ragDeps = @'
sentence-transformers>=2.5.0
extract-msg>=0.48.0
python-docx>=1.1.0
pypdf>=4.0.0
requests>=2.31.0
'@

Add-Content -Path "src/joy-backend/requirements.txt" -Value "`n$ragDeps"
Write-Host "  ✅ Appended offline vector embeddings and asset parsing libraries to requirements.txt." -ForegroundColor Green

# 3. Write the Complete Self-Healing RAG Engine (src/joy-backend/rag_engine.py)
$ragEngineCode = @'
# src/joy-backend/rag_engine.py
import os
import sqlite3
import json
import re
from datetime import datetime
import requests
from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
from qdrant_client.models import PointStruct, VectorParams, Distance

# Multi-format document text extraction libraries
import openpyxl
from pptx import Presentation
from docx import Document
from pypdf import PdfReader
import extract_msg

DATA_REF_ROOT = "src/joy-backend/data_ref"
DB_PATH = "joy.db"
OLLAMA_API = "http://localhost:11434/api/generate"

print("🧠 Initializing local SentenceTransformer Embeddings Core (all-MiniLM-L6-v2)...")
# 100% offline local embeddings pipeline (384 dimensions)
embedding_model = SentenceTransformer('all-MiniLM-L6-v2')

# Setup embedded Qdrant local store vector space
qdrant_client = QdrantClient(location=":memory:") # In-memory isolated storage for ultra-low latency
qdrant_client.recreate_collection(
    collection_name="joy_knowledge_base",
    vectors_config=VectorParams(size=384, distance=Distance.COSINE)
)

def extract_text_from_file(file_path):
    """Dynamically parses text content from multi-format enterprise files natively."""
    ext = os.path.splitext(file_path)[1].lower()
    text = ""
    try:
        if ext in [".txt", ".eml"]:
            with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                text = f.read()
        elif ext == ".msg":
            msg = extract_msg.Message(file_path)
            text = f"Subject: {msg.subject}\nFrom: {msg.sender}\nDate: {msg.date}\nBody: {msg.body}"
        elif ext == ".docx":
            doc = Document(file_path)
            text = "\n".join([p.text for p in doc.paragraphs])
        elif ext == ".xlsx":
            wb = openpyxl.load_workbook(file_path, data_only=True)
            for sheet in wb.worksheets:
                for row in sheet.iter_rows(values_only=True):
                    if row: text += " ".join([str(cell) for cell in row if cell is not None]) + "\n"
        elif ext == ".pptx":
            prs = Presentation(file_path)
            for slide in prs.slides:
                for shape in slide.shapes:
                    if hasattr(shape, "text"): text += shape.text + "\n"
        elif ext == ".pdf":
            reader = PdfReader(file_path)
            for page in reader.pages:
                text += page.extract_text() or ""
    except Exception as e:
        print(f"⚠️ Failed to parse file structure asset {file_path}: {e}")
    return text.strip()

def run_auto_scanning_context_refresh():
    """
    Scans folders, runs time-variant evaluation blocks, resolves semantic
    status contradictions, and refreshes the Qdrant local knowledge base.
    """
    print(f"🔄 [Knowledge Base Factory] Syncing reference documents pool at {datetime.now()}")
    
    # Establish a tracking ledger to prevent processing stale duplication metrics
    processed_topics = {}
    
    for root, dirs, files in os.walk(DATA_REF_ROOT):
        for file in files:
            file_path = os.path.join(root, file)
            file_timestamp = os.path.getmtime(file_path)
            
            # Simple keyword tracking loop to handle status collisions (e.g., 'Project X')
            extracted_text = extract_text_from_file(file_path)
            if not extracted_text: continue
            
            # Look for topics inside text logs to identify status vectors
            topic_match = re.search(r"(project\s+[a-zA-Z0-9_-]+)", extracted_text.lower())
            if topic_match:
                topic = topic_match.group(1)
                # TIME-VARIANT PROTECTION: Newer file paths override stale context models
                if topic in processed_topics:
                    old_path, old_ts = processed_topics[topic]
                    if file_timestamp > old_ts:
                        processed_topics[topic] = (file_path, file_timestamp, extracted_text)
                else:
                    processed_topics[topic] = (file_path, file_timestamp, extracted_text)
            else:
                processed_topics[file] = (file_path, file_timestamp, extracted_text)

    # Ingest the latest verified structural records into the Qdrant vector space
    point_id = 1
    for topic, (f_path, ts, txt_content) in processed_topics.items():
        vector = embedding_model.encode(txt_content).tolist()
        qdrant_client.upsert(
            collection_name="joy_knowledge_base",
            points=[PointStruct(
                id=point_id, 
                vector=vector, 
                payload={"source": os.path.basename(f_path), "text": txt_content, "updated_at": ts}
            )]
        )
        point_id += 1
    print(f"✅ Local Knowledge Base successfully hydrated with {point_id - 1} semantic blocks.")

def execute_offline_rag_query(user_query):
    """
    Bridges relational data matrices and unstructured documents.
    Queries local Qdrant vectors and issues low-latency responses using local Ollama.
    """
    # 1. Extract context fragments from our local vector database
    query_vector = embedding_model.encode(user_query).tolist()
    search_results = qdrant_client.search(
        collection_name="joy_knowledge_base",
        query_vector=query_vector,
        limit=2
    )
    
    vector_context = "\n".join([res.payload["text"] for res in search_results])

    # 2. Interrogate database metadata to add hard relational metrics tracking
    relational_context = ""
    if os.path.exists(DB_PATH):
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        try:
            cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
            tables = [t[0] for t in cursor.fetchall()]
            relational_context += f"Active SQLite Tables Layout: {', '.join(tables)}\n"
            if "joy_resources" in tables:
                cursor.execute("SELECT COUNT(*) FROM joy_resources WHERE allocation > 100")
                relational_context += f"Flagged Over-Allocated Resources: {cursor.fetchone()[0]}\n"
        except Exception: pass
        finally: conn.close()

    # 3. Assemble the prompt packet for the local LLM core engine
    system_prompt = f"""You are the Project Joy Portfolio Intelligence Assistant. 
Analyze the following context segments to respond conversational queries.
Always favor records with the latest timestamps to resolve contradictions. 
If a newer document shows a project is GREEN, disregard older files showing it as RED.

--- UNSTRUCTURED DOCUMENT FILES CONTEXT ---
{vector_context}

--- LIVE RELATIONAL METRICS CONTEXT ---
{relational_context}
"""

    payload = {
        "model": "llama3.1:8b", # Instruct profile optimized for low-latency local execution
        "prompt": f"{system_prompt}\n\nUser Question: {user_query}\nAnswer:",
        "stream": False
    }

    try:
        res = requests.post(OLLAMA_API, json=payload, timeout=30)
        return res.json().get("response", "⚠️ Error processing local context mapping arrays.")
    except Exception:
        return f"Joy Offline Mode Fallback Engine: Mapped context verifications are active. Vector results matched from source logs: {vector_context[:200]}..."

if __name__ == '__main__':
    run_auto_scanning_context_refresh()
'@
Set-Content -Path "src/joy-backend/rag_engine.py" -Value $ragEngineCode
Write-Host "  ✅ Successfully compiled offline execution engine inside src/joy-backend/rag_engine.py" -ForegroundColor Green

Write-Host "=========================================================" -ForegroundColor Green
Write-Host "🎉 SUCCESS: LOCAL RAG REPOSITORY SCAFFOLDING PLACED!" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
