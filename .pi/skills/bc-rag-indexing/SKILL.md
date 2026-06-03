---
name: bc-rag-indexing
description: Index Business Central AL source code, compiled artifacts (.app), and symbol files into Qdrant collections for hybrid (BM25 + vector) search. Creates versioned collections per BC release. Use this skill after building AL extensions, when setting up a new BC project for AI-assisted development, or when you need to search across multiple BC versions. Triggers: "index BC", "rag index", "qdrant collection", "symbol index", "create collection for business central".
---

# Business Central RAG Indexing (Qdrant)

Index Business Central AL code and artifacts into Qdrant vector database for AI-assisted development across BC versions.

## Setup: Ensure rag_index Tool is Available

The `rag_index` tool is a built-in pi tool that indexes files/directories into Qdrant. Verify it is loaded:

```bash
# Check if rag_index is available (it is auto-loaded when Qdrant is configured)
rag_status
```

If `rag_index` is not available, ensure your pi configuration has Qdrant connected. The tool is provided by the `pi-local-rag-qdrant` package.

### Install the RAG extension (if needed)
```bash
pi install npm:pi-local-rag-qdrant
```

After installation, restart pi. The tools `rag_index`, `rag_query`, and `rag_status` will be available.

## Indexing Workflow

### 1. Index a Single BC Version (Post-Build)

After compiling an AL extension, index its source and artifacts:

```bash
# Index the entire AL project into a versioned collection
rag_index --collection "bc-24.0-de" --path "./MyApp/src"

# Index compiled app metadata
rag_index --collection "bc-24.0-de" --path "./MyApp/output"
```

**Collection naming convention**: `bc-{version}-{country}`
- `bc-24.0-de` — Germany, version 24.0
- `bc-23.5-w1` — W1 (worldwide), version 23.5
- `bc-25.0-at` — Austria, version 25.0

### 2. Index BC Base App Symbols

To enable searching standard BC code patterns, index downloaded symbols:

```powershell
# Download symbols first
$folders = Download-Artifacts -artifactUrl (Get-BCArtifactUrl -country "de" -version "24")
$symbolsPath = $folders[0]

# Index with rag_index (run in pi or bash)
# Only index .al symbol files, not binaries
```

```bash
# Index symbols into the collection
rag_index --collection "bc-24.0-base-de" --path "/path/to/symbols"
```

### 3. Index All Installed BC Versions

```bash
#!/bin/bash
# Index multiple BC versions from artifacts folder
for version_dir in /bcartifacts/*/; do
  version=$(basename "$version_dir")
  echo "Indexing BC version: $version"
  
  # Index app symbols
  rag_index --collection "bc-${version}-base" --path "${version_dir}/symbols"
  
  # Index platform (alc.exe, DLLs metadata)
  rag_index --collection "bc-${version}-platform" --path "${version_dir}/platform"
done
```

### 4. Querying Indexed Collections

```bash
# Search across a specific BC version
rag_query --collection "bc-24.0-de" --query "Sales Header posting routine"

# Search across all BC versions (broad)
rag_query --collection "bc-24.0-de" --query "customer ledger entry table"
rag_query --collection "bc-24.0-base-de" --query "Item Journal Post"

# Check which collections exist
rag_status
```

## Collection Management

### List all BC collections
```bash
rag_status
# Shows all collections, file counts, and vector coverage
```

### Delete a collection (clean up old versions)
```bash
# rag_index does not have a delete command directly.
# Use Qdrant HTTP API to delete a collection:
curl -X DELETE "http://localhost:6333/collections/bc-22.0-de"
```

### Re-index after updating extension
```bash
# Delete and re-create: just re-index with the same collection name.
# The rag_index tool will upsert — new chunks replace old ones.
rag_index --collection "bc-24.0-de" --path "./MyApp/src"
```

## Recommended Collection Architecture

```
bc-24.0-de-custom/          # Your custom AL extensions for DE, v24
bc-24.0-de-base/            # Base BC symbols for DE, v24
bc-23.5-w1-custom/          # W1 custom extensions, v23.5
bc-23.5-w1-base/            # W1 base symbols, v23.5
bc-patterns/                # Common AL patterns (cross-version)
bc-tests/                   # Test codeunits and patterns
```

## .gitignore for Indexed Content

Add to `.gitignore` to avoid committing indexed data:
```gitignore
# Qdrant data directory
qdrant_storage/
qdrant_data/

# Indexed cache
.rag_cache/
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `rag_index` not found | Install `pi install npm:pi-local-rag-qdrant` and restart pi |
| "Connection refused" | Ensure Qdrant is running: `docker run -p 6333:6333 qdrant/qdrant` or local Qdrant is started |
| "Collection not found" | Run `rag_status` to list available collections; index first |
| Indexing too slow | Index by subdirectories, skip binary files, use `--path` for targeted folders |
| Vector embeddings fail | Check Qdrant URL in pi config; ensure embedding model is configured |
