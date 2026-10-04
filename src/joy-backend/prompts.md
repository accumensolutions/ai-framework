# [@Spec-Context: Joy-Schema-Evolution]
# [Target: src/joy-backend/pipeline_orchestrator.py]

Act as a Principal Solutions Architect specializing in Schema Evolution and Data Lineage Tracking. Review our configuration-driven pipelines inside `#folder:src/joy-datapipeline` alongside our database orchestrator script inside `#file:src/joy-backend/pipeline_orchestrator.py`.

I am rolling out a pipeline modification/new source parameter. Please inspect the code graph of our source files and handle the task following these strict steps:

1. CONTRACT SYNCHRONIZATION:
   Evaluate the data schema payload changes inside `src/joy-datapipeline/`. Map any updated headers or new API fields.

2. SYSTEM CONTEXT MUTATION:
   Modify the table inspection routine inside `pipeline_orchestrator.py` to ensure its dynamic PRAGMA loops append the new database column structures seamlessly via un-cached 'ALTER TABLE' expressions without corrupting existing records.

3. LIVING DIAGRAM COMPILATION:
   Update the 'generate_html_schema_diagram()' template string function to represent new data structures. It must automatically dump an updated, responsive, interactive CSS/HTML schema layout into `docs/schema_diagram.html` right upon script execution.

4. CACHING AND TOKEN BOUNDARY COMPLIANCE:
   Maintain absolute token preservation rules. Ensure all data dumps inside `src/joy-backend/data_ref/` are deleted or archived instantly after processing to keep our Code Graph index slim and lock in our native 94% prompt-caching discount.

Output the entire, updated `pipeline_orchestrator.py` script cleanly with no code omissions or truncation shortcuts.
