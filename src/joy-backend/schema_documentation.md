The Master Schema Spec-Kit Prompt
Whenever you introduce a new tracking metric, modify your upstream CSV layout fields, or onboard completely new datasets inside src/joy-datapipeline/, you can paste this reusable Spec-Kit Prompt Template into your single VS Code Copilot Chat window (with your workspace set to Auto Mode).
This prompt instructs the agent to analyze your files via the local Code Graph Index and automatically synchronize your data models, database structures, and documentation simultaneously [INDEX, INDEX]:

# [@Spec-Context: Joy-Database-Architecture]
# [Source: docs/schema_documentation.md]
# [Target-Orchestrator: src/joy-backend/pipeline_orchestrator.py]

Act as an Enterprise Lead Database Administrator and Senior Software Architect. Review our master schema data definitions indexed inside the attached `#file:docs/schema_documentation.md` alongside our dynamic database migration tool inside `#file:src/joy-backend/pipeline_orchestrator.py`.

I am rolling out an architecture update to our tracking capabilities. Please inspect our current code graph and handle this operation following these sequential constraints:

1. SCHEMA EVOLUTION DESIGN:
   Analyze the updated columns, data types, and structural tables outlined in the user configuration prompt. Map out the corresponding relational properties for `joy_resources`, `joy_initiatives`, or `joy_defects`.

2. ORCHESTRATOR CODE COMPILATION:
   Modify the dynamic database mapping logic inside `pipeline_orchestrator.py`. Ensure its PRAGMA table-info scanning loops can dynamically intercept these new parameters, execute un-cached 'ALTER TABLE' queries on our local SQLite ledger, and safely store incoming rows without breaking historical trend rows.

3. DATA DICTIONARY RE-COMPILATION:
   Update `docs/schema_documentation.md` to reflect these newly introduced fields. Re-write the Markdown tables to capture the exact Column Name, Data Type, Key Constraints, and explicit Business Purpose of the updated metrics.

4. AUTOMATED HTML SCHEMATIC GENERATION:
   Force the execution loop to trigger the 'generate_html_schema_diagram()' module, instantly outputting a beautifully responsive, single-file interactive CSS/HTML visual structure grid layout inside `docs/schema_diagram.html` to keep our team documentation live.

5. CLEANUP & CACHING POLICY:
   Maintain strict token-preservation metrics. Ensure that all raw text dumps or processing artifacts are cleared instantly upon database ingestion to protect our \$2,000 monthly allowance and consistently hit Copilot's native 94% prompt-caching discount tier.

Output the full, updated code block for `pipeline_orchestrator.py` and the updated documentation text blocks with ZERO truncation shortcuts or placeholders.
