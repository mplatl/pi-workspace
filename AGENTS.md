# =============================================================================
# Pi Workspace — Business Central Development
# =============================================================================
# Master context file loaded by pi coding agent at startup.
# Pi reads AGENTS.md from cwd and parent directories.
# =============================================================================

## Project Identity

This is a **Business Central AL extension development workspace** powered by the pi coding agent.
GitHub: **mplatl** (private), repo: **pi-workspace**

## Key Commands

### Compile AL Code
```bash
# Container-based compile (requires BC container running)
Compile-AppInBcContainer -containerName $env:BC_CONTAINER_NAME -appProjectFolder . -appOutputFolder ./output
```

### Run Tests
```bash
Run-TestsInBcContainer -containerName $env:BC_CONTAINER_NAME -extensionId "your-app-id"
```

### Publish App
```bash
Publish-BcContainerApp -containerName $env:BC_CONTAINER_NAME -appFile "./output/YourApp.app" -sync -install
```

### Index BC Code into Qdrant
```bash
rag_index --collection "bc-24.0-de" --path "./src"
```

### Search Indexed BC Code
```bash
rag_query --collection "bc-24.0-de" --query "sales posting"
```

## Available Skills

- `/bc-development` — Full AL dev workflow (compile, publish, test, artifacts)
- `/bc-rag-indexing` — Index BC code/symbols into Qdrant collections

## Available Prompt Templates

- `/bc-developer` — Developer mode: best practice AL coding, clean architecture
- `/bc-consultant` — Consultant mode: standard-first analysis, configuration over customization

## Environment

Copy `.env.example` to `.env` and configure:
- `ANTHROPIC_API_KEY` / `OPENAI_API_KEY` — LLM access
- `QDRANT_URL` — Vector DB for RAG
- `BC_CONTAINER_NAME` — BC sandbox container
- `GITHUB_TOKEN` — Private repo access

## Git Config (this repo)
- Account: **mplatl** (private)
- Email: michael.platl@hotmail.com
- SSH key: `~/.ssh/id_ed25519_private`

## Coding Standards (AL)

- Standard-first: exhaust BC features before custom logic
- Clean architecture: TableExtension = data, PageExtension = UI, Codeunit = logic
- Events over overrides, Enum over Option
- Always `LockTable()` before modify
- `Error()` for validation, never `Message()`
- XML-doc all public procedures
- Test codeunits for all business logic
- IDs within assigned range in app.json

## BC28 Documentation (Jekyll / GitHub Pages)

Ziel-Repo: `git@github.com:MPSWIT/bc28-documentation` (branch `main`)
Lokal: `./bc28-documentation/` (eigenständiges Git-Repo, kein Submodul)

### Navigation: Vertikales Baum-Menü

Für klickbare Links in Monospace-Baumstrukturen **niemals** Markdown-Codeblöcke (```) verwenden — Liquid `{{ }}` Tags werden darin **nicht** verarbeitet. **Immer `<pre>` + `<a>` HTML verwenden:**

```html
<pre>
4. Finanzwesen
 │
 ├── <a href="{{ '/04-finance/fibu-einrichtung/' | relative_url }}">Fibu-Einrichtung</a>
 ├─▶ Aktuelle Seite  ← Sie sind hier
 └── <a href="{{ '/04-finance/entwickler/' | relative_url }}">Entwickler-Referenz</a>
</pre>
```

- `├─▶` markiert die aktuelle Seite (nicht verlinkt)
- `&amp;` für `&` in HTML-Attributen
- Commit + Push mit: `GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_private -o IdentitiesOnly=yes" git push origin main`
