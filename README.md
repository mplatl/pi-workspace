# Pi Workspace — Business Central AL Development

AI-powered Business Central development workspace using [pi coding agent](https://github.com/badlogic/pi-coding-agent).

## What's Inside

| Component | Path | Description |
|-----------|------|-------------|
| **BC Development Skill** | `.pi/skills/bc-development/SKILL.md` | Compile, publish, test, download BC artifacts |
| **BC RAG Indexing Skill** | `.pi/skills/bc-rag-indexing/SKILL.md` | Index AL code & symbols into Qdrant collections |
| **Developer Agent** | `.pi/prompts/bc-developer.md` | `/bc-developer` — best-practice AL coding |
| **Consulting Agent** | `.pi/prompts/bc-consultant.md` | `/bc-consultant` — standard-first BC analysis |
| **BC Deploy Skill** | `skills/bc-extension-deploy/SKILL.md` | Deploy .app files to BC SaaS sandbox via Automation API |
| **Project Context** | `AGENTS.md` | Auto-loaded by pi at startup |
| **Environment Template** | `.env.example` | All required env vars with documentation |

## Quick Start

```bash
# 1. Install pi coding agent
npm install -g --ignore-scripts @earendil-works/pi-coding-agent

# 2. Install RAG indexing package
pi install npm:pi-local-rag-qdrant

# 3. Copy and configure environment
cp .env.example .env
# Edit .env — set ANTHROPIC_API_KEY or OPENAI_API_KEY

# 4. Start Qdrant (if using RAG)
docker run -d -p 6333:6333 -v $(pwd)/qdrant_storage:/qdrant/storage qdrant/qdrant

# 5. Launch pi in this workspace
cd ~/Dokumente/development/pi-workspace
pi
```

## Using the Agents

### Developer Mode
Start pi with the developer prompt template:
```bash
pi --prompt-template .pi/prompts/bc-developer.md "Create a new table extension for Sales Header"
```
Or in interactive mode:
```
/bc-developer Create a table extension for Sales Header with a new status field
```

### Consultant Mode
Start pi with the consulting prompt template:
```bash
pi --prompt-template .pi/prompts/bc-consultant.md "We need a credit limit approval workflow"
```
Or in interactive mode:
```
/bc-consultant The customer wants to automate credit limit approvals
```

## Indexing BC Code

After building an extension, index it for AI-assisted search:
```bash
# In pi interactive mode
/bc-rag-indexing

# Or directly
rag_index --collection "bc-24.0-de" --path "./src"
rag_query --collection "bc-24.0-de" --query "how is sales posting handled"
```

## Deployment Scripts

Deploy an AL app to a BC SaaS sandbox using the Automation API v2.0:

```bash
# 1. Build your app
# 2. Deploy
./scripts/deploy-to-bc.sh ./output/MyApp.app Sandbox "CRONUS AT"

# 3. Check deployment status
./scripts/check-bc-deployment.sh Sandbox "CRONUS AT"
```

Requires `.env` variables: `BC_TENANT_ID`, `BC_CLIENT_ID`, `BC_CLIENT_SECRET`.

## Repository

**Private GitHub**: `mplatl/pi-workspace`
**Git config**: Uses `~/.ssh/id_ed25519_private` for authentication
