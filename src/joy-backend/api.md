@workspace Read `#file:docs/schema_documentation.md` and review the indexed data models within `#folder:src/joy-datapipeline`. 

Please write the complete, un-truncated production code for our server gateway inside `src/joy-backend/app.py` utilizing Python 3.14 syntax. Implement these exact components:

1. CORE INFRASTRUCTURE LAYER:
   - Instantiate a FastAPI application instance with loose CORSMiddleware handlers allowing integration with our Next.js UI on port 3000.
   - Map a direct sqlite3 session connector pointing to our local tracking database ('joy.db').

2. DYNAMIC REAL-TIME DATA STREAM ENDPOINT:
   - Expose a `GET /api/v1/portfolio/stream` REST route. 
   - This endpoint must run a dynamic table inspection query, extract point-in-time rows from all active 'source_' tables (Jira, Snyk, GitHub, Bitbucket), and structure them into the exact unified object array tree specified in our data dictionary.

3. DYNAMIC CONFIGURATION MUTATION ROUTERS (CRUD):
   - Expose `POST`, `PUT`, and `DELETE` routers inside an `/api/v1/resources` path. 
   - This enables adding, modifying, or soft-deleting human resource matrix records on the fly, storing entries dynamically in the SQLite database blob arrays.

4. AUTOMATED ON-DEMAND PIPELINE TRIGGER:
   - Expose a `POST /api/v1/pipeline/trigger` endpoint. 
   - When invoked, it must execute a FastAPI BackgroundTask that asynchronously runs our 'src/joy-backend/pipeline_orchestrator.py' file as a sub-process wrapper to fetch new files, alter tables, and overwrite documents cleanly without blocking UI interactions.

5. INTELLIGENT CHATBOT DISPATCH GATEWAY:
   - Expose a `POST /api/v1/chat` endpoint receiving prompt strings. 
   - Write light pattern-matching logic: if the prompt asks for counts or allocations, run a fast SQL query statement on SQLite (e.g., check allocation > 100 or count defect rows) and return the statistic convo text directly. This avoids uploading thousands of data rows to an LLM, reducing inputs to zero.

Output the complete script with absolute type-safety handles, complete execution loops, and ZERO truncate placeholders like '# TODO'.
