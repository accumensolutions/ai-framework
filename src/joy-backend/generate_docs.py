# src/joy-backend/generate_docs.py
import os
import sqlite3
from datetime import datetime

DB_PATH = "joy.db"
DOCS_PATH = "docs/schema_documentation.md"

def fetch_live_schema_and_generate_md():
    """
    Queries the live SQLite catalog, extracts real-time table DDL structures,
    and dynamically compiles a token-optimized markdown data dictionary in /docs.
    """
    if not os.path.exists(DB_PATH):
        print(f"⚠️ Database '{DB_PATH}' not found. Run your pipeline orchestrator first to seed tables.")
        return

    if not os.path.exists("docs"):
        os.makedirs("docs")

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # 1. Fetch all user-defined tables from the SQLite system metadata
    cursor.execute("SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
    tables = cursor.fetchall()
    
    # Base Markdown Header tailored explicitly for the Spec-Kit Context Token layout
    md_output = f"""# [@Spec-Context: Joy-Database-Architecture]
# [Database-Engine: Local-first SQLite3 Serverless Matrix]
# [Auto-Generated: {datetime.utcnow().isoformat()}Z]

This document serves as the absolute structural specification anchor for Project Joy's data layers. It is dynamically extracted directly from the live database DDL metadata catalog.

---
"""

    for table_name, ddl_sql in tables:
        md_output += f"\n## 📋 Table: {table_name}\n"
        md_output += f"**Live DDL Structural Core Definition:**\n```sql\n{ddl_sql}\n```\n\n"
        md_output += "### Data Dictionary & Properties Mapping Matrix:\n"
        md_output += "| Column Name | Data Type | Key Constraints | Default Value | Nullable |\n"
        md_output += "| :--- | :--- | :--- | :--- | :--- |\n"
        
        # 2. Extract column metadata parameters using PRAGMA table_info loops
        cursor.execute(f"PRAGMA table_info({table_name})")
        columns = cursor.fetchall()
        
        for cid, col_name, data_type, notnull, dflt_value, pk in columns:
            # Map constraint flags into readable strings
            constraints = "PRIMARY KEY" if pk else ""
            nullable = "NO" if notnull else "YES"
            default_val = str(dflt_value) if dflt_value is not null else "NULL"
            
            # Format rows matching Semantic Token Optimization grids
            md_output += f"| `{col_name}` | {data_type or 'TEXT'} | {constraints} | {default_val} | {nullable} |\n"
            
        md_output += "\n---\n"
        
    conn.close()
    
    # 3. Commit the live generated layout to disk
    with open(DOCS_PATH, "w", encoding="utf-8") as f:
        f.write(md_output)
        
    print(f"🎉 SUCCESS: Dynamic schema documentation compiled seamlessly at: {DOCS_PATH}")

if __name__ == '__main__':
    fetch_live_schema_and_generate_md()
