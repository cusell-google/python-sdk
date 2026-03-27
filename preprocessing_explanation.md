# UCP Python SDK Schema Preprocessing

This document lists the preprocessing steps executed by `preprocess_schemas.py` on the raw UCP OpenAPI/JSON schemas before `datamodel-codegen` is run. This preprocessing pipeline ensures that code generation succeeds cleanly and creates idiomatically correct Python models for the latest specification merged in `main`.

## Preprocessing Pipeline

### 1. Metadata Normalization
- **Function**: `normalize_metadata_schemas`
- **Purpose**: Unifies references to the generic `ucp` metadata property across all schema definitions. Ensures `ucp.json` defines a root union of specific platform/business schema configurations, simplifying SDK representations.

### 2. Iterative Schema Flattening
The core transformation runs in a `while` loop until convergence, repeatedly parsing tree nodes to guarantee that dynamically resolved inner references are also processed.
- **Entity Resolution (`flatten_entity_reference`)**: Replaces references to the base `Entity` definition (e.g., `ucp.json#/$defs/entity`) with direct properties. This converts abstract inheritance into concrete data fields for reliable Pydantic definition.
- **`allOf` Merging (`merge_all_of_to_node`)**: Flattens `allOf` inheritance structures directly into standard properties. This prevents the generator from producing unneeded intermediary classes and simplifies object inheritance graphs.
- **Polymorphic Property Distribution (`distribute_properties_to_branches`)**: Automatically copies base properties and requirement markers into the individual branches of `anyOf` or `oneOf` blocks. This ensures each union branch is structurally complete and fully self-contained as a Pydantic `BaseModel`.

### 3. Variant State Propagation
- **Function**: `propagate_needs_transitive`
- **Purpose**: Crawls the properties graph to find fields annotated with `@ucp_request` markers that indicate context-specific payloads (e.g., `create`, `update`, `complete`). When a parent object requires a variant (like a `create` request model), this step forces child components to also generate matching `create` variants to keep references type-safe down the tree.

### 4. Special Variant Generation
- **Function**: `generate_variants` and `_create_single_variant`
- **Purpose**: Ultimately generates targeted physical JSON Schema files (such as `product_create_request.json`) based on the operation types found in the tree. Read-only fields are stripped, and `omit` or `required` instructions from the `ucp_request` JSON markers are specifically evaluated for the payload variant. External file references (`$ref`) are successfully rewritten to point to their corresponding variant schemas.
