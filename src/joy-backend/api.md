@workspace Read `#file:docs/schema_documentation.md`. Write the complete, production-ready Python code for `src/joy-backend/app.py`. 

The API must be structured to natively support dynamic UI filtering matrices, chart-switching parameters, and URL trail navigation queries without requiring backend file rewrites. Implement these exact functional layers:

1. GLOBAL SERVER SETTINGS:
   - Instantiate a FastAPI app instance equipped with complete CORSMiddleware blocks to allow open communication with our Next.js dashboard running on port 3000.

2. PARAMETERIZED METRICS STREAM ROUTE:
   - Expose a `GET /api/v1/portfolio/stream` REST endpoint.
   - It must accept an optional string query parameter: `groupBy` (Allowed bounds: "team", "priority", "status", "group").
   - Connect to our local 'joy.db' SQLite ledger and dynamically form an aggregated SQL statement using the `groupBy` parameter value to execute a clean, un-cached `COUNT(*)` or `SUM()` execution block grouped by that target column index.
   - Return a beautifully structured nested JSON payload mapping directly to our data dictionary contract schema so the Recharts canvas components can parse it abstractly in one shot.

3. MANAGEMENT MUTATION CONFIGURATIONS (CRUD):
   - Expose endpoints `POST`, `PUT`, and `DELETE` under an `/api/v1/resources` route group. 
   - This handles inserting, editing, or soft-deleting human resource profiles on the fly inside SQLite. If any user write action attempts to submit an allocation value greater than 100, return an operational validation flag within the JSON response text payload.

4. AUTOMATED ON-DEMAND PIPELINE TRIGGER:
   - Expose a `POST /api/v1/pipeline/trigger` endpoint. 
   - When invoked from the UI settings tab, it must launch a FastAPI BackgroundTask that safely executes 'src/joy-backend/pipeline_orchestrator.py' as an isolated sub-process. This allows the system to fetch fresh data files, run schema migrations, and overwrite markdown files dynamically in the background without locking the dashboard view layer.

5. CONVERSATIONAL CHAT DISPATCH HANDLER:
   - Expose a `POST /api/v1/chat` endpoint receiving prompt text string arrays.
   - If user asks for metrics or counts, run a fast parameterized SQL lookup against our SQLite catalog and emit the numeric response natively to eliminate expensive token waste.

Output the full file with complete imports, absolute type-safety controls, and ZERO truncate placeholders like '# TODO'.
