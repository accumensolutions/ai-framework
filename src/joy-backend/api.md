@workspace Read `#file:docs/schema_documentation.md` and `#file:docs/codegraph_index.json`. 

You have direct file-writing privileges. Please generate and save the complete, production-ready Python 3.14 code for our server gateway directly into the file space at `src/joy-backend/app.py`. 

Implement these exact functional components sequentially, ensuring zero placeholders or '# TODO' comments are left behind:

1. CORE INFRASTRUCTURE LAYER:
   - Instantiate a FastAPI application instance with CORSMiddleware blocks allowing open communication with our Next.js dashboard on port 3000.
   - Establish a direct sqlite3 session connector pointing to our local tracking database ('joy.db').

2. PARAMETERIZED METRICS STREAM ROUTE:
   - Expose a `GET /api/v1/portfolio/stream` REST endpoint.
   - It must accept an optional string query parameter: `groupBy` ("team", "priority", "status", "group").
   - Dynamically form an aggregated SQL statement using the `groupBy` value to execute a clean, un-cached `COUNT(*)` or `SUM()` execution block grouped by that target column index. Return a nested JSON payload mapping directly to our data dictionary contract schema.

3. MANAGEMENT MUTATION CONFIGURATIONS (CRUD):
   - Expose endpoints `POST`, `PUT`, and `DELETE` under an `/api/v1/resources` route group.
   - This handles inserting, editing, or soft-deleting human resource profiles on the fly inside SQLite. If any user write action attempts to submit an allocation value greater than 100, return an operational validation flag within the JSON response payload.

4. AUTOMATED ON-DEMAND PIPELINE TRIGGER:
   - Expose a `POST /api/v1/pipeline/trigger` endpoint.
   - When invoked, it must launch a FastAPI BackgroundTask that safely executes 'src/joy-backend/pipeline_orchestrator.py' as an isolated sub-process. This allows the system to fetch fresh data files, run schema migrations, and overwrite markdown files dynamically in the background without locking the dashboard view layer.

5. CONVERSATIONAL CHAT DISPATCH HANDLER:
   - Expose a `POST /api/v1/chat` endpoint receiving prompt text string arrays.
   - If the user asks for metrics or counts, run a fast parameterized SQL lookup against our SQLite catalog and emit the numeric response natively to eliminate expensive token waste.

When generation completes, physically save the code directly to `src/joy-backend/app.py`.
