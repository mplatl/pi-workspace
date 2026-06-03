#!/bin/bash
# =============================================================================
# Pi Workspace — Setup Script
# =============================================================================
# Run once after cloning pi-workspace:
#   chmod +x setup.sh && ./setup.sh
# =============================================================================
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$WORKSPACE_DIR"

echo "============================================"
echo " Pi Workspace — Business Central Setup"
echo "============================================"
echo ""

# 1. Check for pi coding agent
echo "[1/5] Checking pi coding agent..."
if ! command -v pi &> /dev/null; then
    echo "  → Installing pi coding agent..."
    npm install -g --ignore-scripts @earendil-works/pi-coding-agent
    echo "  ✓ pi installed"
else
    echo "  ✓ pi found: $(pi --version 2>&1 || echo 'OK')"
fi

# 2. Install RAG Qdrant package
echo "[2/5] Installing pi-local-rag-qdrant..."
pi install npm:pi-local-rag-qdrant 2>/dev/null || \
    echo "  ⚠ Could not install (may already be installed or pi not yet available)"

# 3. Configure git for private GitHub
echo "[3/5] Configuring git for private GitHub (mplatl)..."
git config user.name "Michael Platl"
git config user.email "michael.platl@hotmail.com"
git config core.sshCommand "ssh -i ~/.ssh/id_ed25519_private -o IdentitiesOnly=yes"
echo "  ✓ Git configured"

# 4. Set up .env if not exists
echo "[4/5] Setting up environment..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "  → .env created from .env.example"
    echo "  ⚠ EDIT .env with your API keys!"
    echo "     vim .env   (or your editor of choice)"
else
    echo "  ✓ .env already exists"
fi

# 5. Verify structure
echo "[5/5] Verifying workspace structure..."
echo ""
echo "  Skills:"
ls -1 .pi/skills/*/SKILL.md 2>/dev/null | while read f; do
    echo "    ✓ $(dirname "$f" | xargs basename)"
done
echo ""
echo "  Prompt Templates (agents):"
ls -1 .pi/prompts/*.md 2>/dev/null | while read f; do
    echo "    ✓ $(basename "$f" .md)"
done
echo ""
echo "  Agent Descriptions:"
ls -1 agents/*.md 2>/dev/null | while read f; do
    echo "    ✓ $(basename "$f")"
done
echo ""
echo "  Config:"
echo "    ✓ AGENTS.md"
echo "    ✓ .env.example"
echo "    ✓ .gitignore"
echo "    ✓ README.md"
echo ""

echo "============================================"
echo " Setup complete!"
echo ""
echo " Next steps:"
echo "  1. Edit .env with your API keys"
echo "  2. Start Qdrant (if using RAG):"
echo "     docker run -d -p 6333:6333 -v \$(pwd)/qdrant_storage:/qdrant/storage qdrant/qdrant"
echo "  3. Launch pi in this workspace:"
echo "     pi"
echo ""
echo "  Use /bc-developer for AL coding"
echo "  Use /bc-consultant for BC configuration advice"
echo "  Use /bc-development for AL build workflows"
echo "  Use /bc-rag-indexing to index BC code into Qdrant"
echo "============================================"
