To implement and link this 100% offline, enterprise-grade chatbot system into your application without text shortcuts, open your Copilot Edits / Agentic Chat Window (Open in Editor -> Auto Mode).
Ensure that your data_ref/ folder is positioned at your root workspace directory and that you have attached your data dictionary (#file:docs/schema_documentation.md) and your repository maps (#file:docs/codegraph_index.json). Then, execute this comprehensive multi-layer prompt:


# [@Spec-Context: Joy-Unified-Intelligence-Chatbot-Integration]
# [Target-Frontend: src/joy-frontend/src/components/ChatBotPane.tsx]
# [Target-Backend: src/joy-backend/app.py]
# [Target-Storage: src/joy-backend/rag_engine.py]
# [Target-Watcher: src/joy-backend/watcher_worker.py]

You have direct file-writing privileges across our entire monorepo workspace. Please completely build out, optimize, and link the conversational intelligence layer end-to-end across our data extraction workers, FastAPI endpoints, and Next.js presentation views. 

Do not leave behind any truncated code blocks, placeholder routines, or comments like '// TODO'. Write out every single file fully to ensure absolute production readiness:

## 🗃️ STEP 1: DYNAMIC COMPRESSION & TEXT CHUNKING ENGINE (src/joy-backend/rag_engine.py)
- Fully implement the standalone data processing script. It must recursively walk the project root folder directory path `data_ref/` and any of its dynamic nested subdirectories via 'os.walk()'.
- Multi-Source Parser: Natively parse text metrics from `.txt`, `.eml`, `.msg` (via extract_msg), `.docx` (via docx), `.xlsx` (via openpyxl), and `.pdf` (via pypdf).
- Sliding-Window Tokenizer: Slice data into 150-word atomic blocks with an overlapping window configuration of 25 words to protect context continuity.
- Time-Variant Status Collision Protection: Compare file modification timestamps (`os.path.getmtime`). If a newer document contains a project status contradiction (e.g., today's email says GREEN while a month-old memo says RED), the newer entry must instantly invalidate and overwrite the conflicting context blocks inside our local ChromaDB PersistentClient vector store, guaranteeing the chatbot always caches only the latest ground truth.

## 🛰️ STEP 2: RECURSIVE FOLDER SURVEILLANCE WATCHDOG (src/joy-backend/watcher_worker.py)
- Build a lightweight background worker loop that polls the root `data_ref/` folder and any subdirectories recursively every 5 seconds. 
- If a file addition, modification, or drop occurs on disk, instantly log the event to the console and fire 'run_auto_scanning_context_refresh()' from our RAG module to rebuild the local vector index tables seamlessly.

## ⚙️ STEP 3: STATELESS REST GATEWAY ENDPOINTS (src/joy-backend/app.py)
- Expose a `POST /api/v1/chat` endpoint receiving a JSON request body with a `prompt` string.
- The endpoint must cleanly map the user query string parameter straight into the `execute_offline_rag_query()` function from our RAG core module, fetch the relevant coordinate text block from the local vector database, and return the structured text answer back as a clean JSON response object.

## 💬 STEP 4: INTERACTIVE OCTAGON SLIDE-OUT OVERLAY PANEL (src/joy-frontend/src/components/ChatBotPane.tsx)
- Build out the visual workspace overlay panel using design elements and tokens from '@octagon/react'. The component must slide out smoothly from the right side of the user interface.
- Scrollable Conversation Log: Render custom text bubble frames differentiating user inputs from the assistant's technical reports. Natively support Markdown text formatting inside the bubbles to print code variables or metadata bold tags cleanly.
- Reactive Async Network Integration: Submitting a question must append the user string instantly to the log matrix, flash an animated thinking or loading state icon spinner, and issue an asynchronous network `fetch` call directly to our local backend server (`POST http://127.0.0`). Map the returning response text dynamically to clear the loading panel, rendering the result text seamlessly.

When generation completes, write and save the completed code directly into each respective file path cleanly.
