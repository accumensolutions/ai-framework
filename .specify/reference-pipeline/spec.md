Act as a Principal Data Engineer specializing in Python 3.14 automated ingestion architectures. I need to fully implement Phase 1 (The Data Pipeline Engine) inside my `joy-backend/` workspace folder based on my reference pipeline code graph.

Please generate a standalone Python module named `joy-backend/pipeline_worker.py` that implements the following production features:

1. Directory Surveillance: Continually scans the local directory `joy-backend/data_ref/` for files.
2. Multi-Format File Processing Logic:
   - CSV Engine: Read row attributes (`group_name`, `initiative_title`, `status`, `defect_count`, `defect_priority`, `allocation_percentage`).
   - Excel Engine: Use 'openpyxl' to open `.xlsx` files in data-only mode and parse row metrics starting at index 2.
   - Email Ingestion: Use 'unstructured' to extract clean text blocks from `.eml` and `.txt` files.
3. Local Storage Sync Handlers:
   - Connects to a local SQLite database file named `joy.db`.
   - Appends rows to a `portfolio_metrics` table to record historical trends.
   - Prepares a text indexing payload array for a local Qdrant Vector database collection named `joy_kb`.
4. Context Memory Cleanup Guardrail: Immediately deletes or renames a source log file to `processed_<filename>` upon ingestion. This keeps our active folders clear and prevents Copilot from duplicate-scanning data chunks.

Output the complete, un-truncated Python code file with zero placeholders or comment shortcuts.
