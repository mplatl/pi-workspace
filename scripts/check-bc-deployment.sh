#!/bin/bash
# Check BC extension deployment status
# Usage: ./check-bc-deployment.sh [env] [company]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -f "$REPO_ROOT/.env" ]; then
    set -a; source "$REPO_ROOT/.env"; set +a
fi

ENV="${1:-Sandbox}"
COMPANY="${2:-CRONUS AT}"

if [ -z "${BC_TENANT_ID:-}" ] || [ -z "${BC_CLIENT_ID:-}" ] || [ -z "${BC_CLIENT_SECRET:-}" ]; then
    echo "Error: Missing BC_TENANT_ID, BC_CLIENT_ID, BC_CLIENT_SECRET in environment"
    exit 1
fi

pwsh -File /dev/stdin << PSEOF
\$tenantId = "$BC_TENANT_ID"
\$clientId = "$BC_CLIENT_ID"
\$clientSecret = "$BC_CLIENT_SECRET"
\$env = "$ENV"
\$companyName = "$COMPANY"

\$r = Invoke-RestMethod -Uri "https://login.microsoftonline.com/\$tenantId/oauth2/v2.0/token" -Method Post -Body @{
    client_id=\$clientId; client_secret=\$clientSecret
    scope="https://api.businesscentral.dynamics.com/.default"; grant_type="client_credentials"
} -TimeoutSec 10
\$token = \$r.access_token

\$http = [System.Net.Http.HttpClient]::new()
\$http.Timeout = [TimeSpan]::FromSeconds(15)
\$http.DefaultRequestHeaders.Authorization = [System.Net.Http.Headers.AuthenticationHeaderValue]::new("Bearer", \$token)
\$base = "https://api.businesscentral.dynamics.com/v2.0/\$tenantId/\$env/api/microsoft/automation/v2.0"
\$company = [uri]::EscapeDataString(\$companyName)

Write-Host "=== Deployment Status ===" -ForegroundColor Cyan
\$resp = \$http.GetAsync("\$base/extensionDeploymentStatus?company=\$company&\`\$orderby=startedOn desc&\`\$top=5").GetAwaiter().GetResult()
\$body = \$resp.Content.ReadAsStringAsync().GetAwaiter().GetResult()
(\$body | ConvertFrom-Json).value | ForEach-Object {
    \$c = if(\$_.status -eq "Completed"){"Green"}elseif(\$_.status -eq "InProgress"){"Yellow"}else{"Red"}
    Write-Host "  \$(\$_.name): \$(\$_.status)" -ForegroundColor \$c
    Write-Host "    Version: \$(\$_.appVersion) | Started: \$(\$_.startedOn)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== Installed Extensions ===" -ForegroundColor Cyan
\$resp2 = \$http.GetAsync("\$base/extensions?company=\$company").GetAwaiter().GetResult()
\$body2 = \$resp2.Content.ReadAsStringAsync().GetAwaiter().GetResult()
(\$body2 | ConvertFrom-Json).value | Where-Object { \$_.isInstalled -eq \$true } | ForEach-Object {
    Write-Host "  \$(\$_.displayName) v\$(\$_.versionMajor).\$(\$_.versionMinor).\$(\$_.versionBuild).\$(\$_.versionRevision)" -ForegroundColor Green
    Write-Host "    Publisher: \$(\$_.publisher)" -ForegroundColor Gray
}
\$http.Dispose()
PSEOF
