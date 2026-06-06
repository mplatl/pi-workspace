#!/bin/bash
# Deploy an AL app to a BC SaaS sandbox
# Usage: ./deploy-to-bc.sh <app-file.app> [env] [company]
# Credentials are read from environment or .env file

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load .env if present
if [ -f "$REPO_ROOT/.env" ]; then
    set -a; source "$REPO_ROOT/.env"; set +a
fi

APP_FILE="${1:-}"
ENV="${2:-Sandbox}"
COMPANY="${3:-CRONUS AT}"

if [ -z "$APP_FILE" ]; then
    echo "Usage: $0 <app-file.app> [env] [company]"
    echo "  env     - Environment name (default: Sandbox)"
    echo "  company - Company name (default: CRONUS AT)"
    echo ""
    echo "Required .env variables:"
    echo "  BC_TENANT_ID     - Azure AD tenant ID"
    echo "  BC_CLIENT_ID     - Azure AD app registration client ID"
    echo "  BC_CLIENT_SECRET - Azure AD app registration client secret"
    exit 1
fi

if [ ! -f "$APP_FILE" ]; then
    echo "Error: App file not found: $APP_FILE"
    exit 1
fi

# Validate required env vars
if [ -z "${BC_TENANT_ID:-}" ] || [ -z "${BC_CLIENT_ID:-}" ] || [ -z "${BC_CLIENT_SECRET:-}" ]; then
    echo "Error: Missing required environment variables. Check .env file."
    echo "  BC_TENANT_ID, BC_CLIENT_ID, BC_CLIENT_SECRET are required."
    exit 1
fi

echo "==> Deploying $APP_FILE to $ENV / $COMPANY"
pwsh -File "$SCRIPT_DIR/bc-deploy-app.ps1" \
    -tenantId "$BC_TENANT_ID" \
    -clientId "$BC_CLIENT_ID" \
    -clientSecret "$BC_CLIENT_SECRET" \
    -appFile "$APP_FILE" \
    -env "$ENV" \
    -companyName "$COMPANY"
