# src/joy-backend/pipeline_orchestrator.py
import os
import csv
import sqlite3
import json
from datetime import datetime

# Path Mappings aligning with your src/ layout
DATA_DROP_ZONE = "src/joy-backend/data_ref"
DB_PATH = "joy.db"
DIAGRAM_PATH = "docs/schema_diagram.html"

def reflect_and_migrate_schema(table_name, sample_csv_path):
    """
    Dynamically scans incoming CSV headers, identifies structural drift, 
    runs un-cached ALTER TABLE commands on SQLite, and returns true fields.
    """
    if not os.path.exists(sample_csv_path): return []
    
    with open(sample_csv_path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        headers = [h.strip().lower() for h in next(reader)]
        
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Create the entity track if it is a brand new source registry
    cursor.execute(f"""
        CREATE TABLE IF NOT EXISTS {table_name} (
            joy_id INTEGER PRIMARY KEY AUTOINCREMENT,
            joy_ingest_time TEXT DEFAULT (STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'NOW'))
        )
    """)
    
    # Primes PRAGMA table information loops to track existing columns
    cursor.execute(f"PRAGMA table_info({table_name})")
    existing_columns = [row[1] for row in cursor.fetchall()]
    
    # Auto-propagate dynamic schema drift safely without breaking old records
    for header in headers:
        if header not in existing_columns and header != "joy_id" and header != "joy_ingest_time":
            print(f"🧬 [Schema Evolution] Found new parameter column: '{header}' in table '{table_name}'. Altering schema...")
            cursor.execute(f"ALTER TABLE {table_name} ADD COLUMN {header} TEXT")
            
    conn.commit()
    conn.close()
    return headers

def generate_html_schema_diagram():
    """
    Reads the real-time SQLite schema database and outputs a beautiful,
    fully responsive interactive HTML documentation diagram in /docs.
    """
    if not os.path.exists("docs"): os.makedirs("docs")
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
    tables = [t[0] for t in cursor.fetchall()]
    
    schema_data = {}
    for table in tables:
        cursor.execute(f"PRAGMA table_info({table})")
        schema_data[table] = [{"name": r[1], "type": r[2]} for r in cursor.fetchall()]
    conn.close()
    
    # High-fidelity single-file interactive documentation grid layout
    html_template = f"""<!DOCTYPE html>
<html>
<head>
    <title>Project Joy: Database Map</title>
    <style>
        body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #0f172a; color: #f8fafc; padding: 2rem; }}
        h1 {{ border-bottom: 2px solid #334155; padding-bottom: 0.5rem; color: #38bdf8; font-size: 1.5rem; }}
        .grid {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 1.5rem; margin-top: 1rem; }}
        .card {{ background: #1e293b; border: 1px solid #334155; rounded-radius: 8px; border-radius: 8px; padding: 1rem; box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1); }}
        .title {{ font-weight: bold; color: #fbbf24; border-bottom: 1px solid #475569; padding-bottom: 0.25rem; margin-bottom: 0.5rem; display:flex; justify-content:space-between; }}
        .row {{ display: flex; justify-content: space-between; font-size: 0.85rem; padding: 0.2rem 0; font-family: monospace; }}
        .type {{ color: #94a3b8; }}
        .footer {{ font-size: 0.75rem; text-align: center; color: #64748b; margin-top: 3rem; }}
    </style>
</head>
<body>
    <h1>⚓ Project Joy Live Database Schema Mapping Model</h1>
    <p style="font-size:0.85rem; color:#94a3b8;">Generated: {datetime.now().isoformat()}Z (Auto-updated upon source pipeline schema drift events)</p>
    <div class="grid">
    """
    
    for table_name, columns in schema_data.items():
        html_template += f'<div class="card"><div class="title"><span>📋 {table_name}</span></div>'
        for col in columns:
            html_template += f'<div class="row"><span>• {col["name"]}</span><span class="type">[{col["type"] or "TEXT"}]</span></div>'
        html_template += '</div>'
        
    html_template += """
    </div>
    <div class="footer">Evolving Meta-Schema Architecture Driven securely under Spec-Kit Protocols.</div>
</body>
</html>
    """
    
    with open(DIAGRAM_PATH, "w", encoding="utf-8") as f:
        f.write(html_template)
    print(f"📊 [Docs Update] Living interactive HTML schema diagram successfully compiled at: {DIAGRAM_PATH}")

def process_active_drops():
    """
    Monitors your file outputs, routes data into SQLite via the schema evaluation
    pipeline layers, and forces a documentation update.
    """
    if not os.path.exists(DATA_DROP_ZONE): os.makedirs(DATA_DROP_ZONE)
    drift_detected = False
    
    for filename in os.listdir(DATA_DROP_ZONE):
        if filename.endswith(".csv"):
            table_name = f"source_{filename.split('_')[0].lower()}" # e.g. source_jira
            file_path = os.path.join(DATA_DROP_ZONE, filename)
            
            # 1. Inspect file and update database model dynamically
            headers = reflect_and_migrate_schema(table_name, file_path)
            drift_detected = True
            
            # 2. Parse values and feed SQLite database rows
            conn = sqlite3.connect(DB_PATH)
            cursor = conn.cursor()
            with open(file_path, "r", encoding="utf-8") as f:
                reader = csv.reader(f)
                next(reader) # Skip header
                for row in reader:
                    if len(row) == len(headers):
                        columns_str = ", ".join(headers)
                        placeholders = ", ".join(["?"] * len(row))
                        cursor.execute(f"INSERT INTO {table_name} ({columns_str}) VALUES ({placeholders})", row)
            conn.commit()
            conn.close()
            
            # 3. Clean up staging folder files to protect context memory
            os.remove(file_path)
            
    if drift_detected:
        generate_html_schema_diagram()

if __name__ == "__main__":
    process_active_drops()
