set shell := ["bash", "-c"]

export PATH := "$HOME/.local/bin:$PATH"

# Default action is to list available commands
default:
    @just --list

# Format the codebase using ruff
format:
    uv run ruff format

# Lint the codebase using ruff
lint: format
    uv run ruff check --fix src/

# Install python dependencies via uv
install:
    uv sync

# Generate Python models from UCP JSON Schemas. (Usage: just generate [version])
generate version="": install
    #!/usr/bin/env bash
    set -e

    if ! command -v git &> /dev/null; then
        echo "Error: git not found. Please install git."
        exit 1
    fi

    if ! command -v uv &> /dev/null; then
        echo "Error: uv not found. Please install uv first."
        exit 1
    fi

    if [ -z "{{version}}" ]; then
        BRANCH="main"
        echo "No version specified, cloning main branch..."
    else
        BRANCH="release/{{version}}"
        echo "Cloning version {{version}} (branch: $BRANCH)..."
    fi

    rm -rf ucp
    git clone -b "$BRANCH" --depth 1 https://github.com/Universal-Commerce-Protocol/ucp ucp

    OUTPUT_DIR="src/ucp_sdk/models/schemas"
    SCHEMA_DIR="ucp/source/schemas"

    echo "Preprocessing schemas..."
    uv run python preprocess_schemas.py

    echo "Generating Pydantic models from preprocessed schemas..."
    rm -rf "$OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"

    uv run \
        --link-mode=copy \
        --extra-index-url https://pypi.org/simple python \
        -m datamodel_code_generator \
        --input "$SCHEMA_DIR" \
        --input-file-type jsonschema \
        --output "$OUTPUT_DIR" \
        --output-model-type pydantic_v2.BaseModel \
        --use-schema-description \
        --field-constraints \
        --use-field-description \
        --enum-field-as-literal all \
        --disable-timestamp \
        --use-double-quotes \
        --no-use-annotated \
        --allow-extra-fields \
        --custom-template-dir templates \
        --additional-imports pydantic.ConfigDict

    echo "Formatting generated models..."
    uv run ruff format src/ucp_sdk/models/schemas/
    uv run ruff check --fix "$OUTPUT_DIR"

    echo "Done. Models generated in $OUTPUT_DIR"

# Check if the codebase is clean (useful for CI)
check-clean:
    #!/usr/bin/env bash
    git diff --exit-code || (echo "Error: Working directory is not clean. Did you forget to run 'just generate' or 'just lint'?" && exit 1)
