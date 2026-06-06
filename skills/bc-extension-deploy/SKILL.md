# BC Extension Deployment Skill

## Overview
Deploys a compiled AL app (.app file) to a Microsoft Dynamics 365 Business Central SaaS sandbox using the OData Automation API v2.0 with PowerShell.

## Prerequisites
- Azure AD app registration with `client_credentials` grant and `Dynamics 365 Business Central` API permission
- Tenant ID, Client ID, Client Secret
- BC environment name (e.g., `Sandbox`) and company name (e.g., `CRONUS AT`)
- Compiled `.app` file
- `pwsh` (PowerShell) available on the deployment machine

## Deployment Steps (Automation API v2.0)

### 1. Authenticate via OAuth
```powershell
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method Post -Body @{
    client_id     = $clientId
    client_secret = $clientSecret
    scope         = "https://api.businesscentral.dynamics.com/.default"
    grant_type    = "client_credentials"
}
$token = $tokenResponse.access_token
```

### 2. Set Up HTTP Client
```powershell
$httpClient = [System.Net.Http.HttpClient]::new()
$httpClient.Timeout = [TimeSpan]::FromMinutes(2)
$httpClient.DefaultRequestHeaders.Authorization = 
    [System.Net.Http.Headers.AuthenticationHeaderValue]::new("Bearer", $token)
```

### 3. Find or Create extensionUpload Entity
```powershell
$baseUrl = "https://api.businesscentral.dynamics.com/v2.0/$tenantId/$env/api/microsoft/automation/v2.0"
$companyParam = "?company=$([uri]::EscapeDataString($companyName))"

# List existing entities
$listResponse = $httpClient.GetAsync("$baseUrl/extensionUpload$companyParam").GetAwaiter().GetResult()
$listJson = ($listResponse.Content.ReadAsStringAsync().GetAwaiter().GetResult()) | ConvertFrom-Json

if ($listJson.value.Count -gt 0) {
    # Reuse existing entity
    $existing = $listJson.value[0]
    $systemId = $existing.systemId
    $etag = $existing.'@odata.etag'
    $mediaUrl = $existing.'extensionContent@odata.mediaEditLink'
} else {
    # Create new entity (systemId is auto-assigned)
    $createPayload = @{ schedule = "Current_x0020_version"; schemaSyncMode = "Add" } | ConvertTo-Json
    $createResponse = $httpClient.PostAsync("$baseUrl/extensionUpload$companyParam", 
        [System.Net.Http.StringContent]::new($createPayload, [System.Text.Encoding]::UTF8, "application/json")
    ).GetAwaiter().GetResult()
    $responseJson = ($createResponse.Content.ReadAsStringAsync().GetAwaiter().GetResult()) | ConvertFrom-Json
    $systemId = $responseJson.systemId
    $mediaUrl = "$baseUrl/extensionUpload($systemId)/extensionContent$companyParam"
}
```

### 4. Upload App File (Stream)
```powershell
$appBytes = [System.IO.File]::ReadAllBytes($appFilePath)

# CRITICAL: Must include If-Match header for concurrency token validation
$httpClient.DefaultRequestHeaders.Remove("If-Match")
$httpClient.DefaultRequestHeaders.Add("If-Match", "*")

$byteContent = [System.Net.Http.ByteArrayContent]::new($appBytes)
$byteContent.Headers.ContentType = "application/octet-stream"

# PUT to the mediaEditLink URL
$putResponse = $httpClient.PutAsync($mediaUrl, $byteContent).GetAwaiter().GetResult()
# Successful PUT returns 204 No Content or 200 OK with final ETag
```

### 5. Trigger Deployment
```powershell
$actionUrl = "$baseUrl/extensionUpload($systemId)/Microsoft.NAV.upload$companyParam"
$actionContent = [System.Net.Http.StringContent]::new("{}", [System.Text.Encoding]::UTF8, "application/json")

$httpClient.DefaultRequestHeaders.Remove("If-Match")
$httpClient.DefaultRequestHeaders.Add("If-Match", "*")

$actionResponse = $httpClient.PostAsync($actionUrl, $actionContent).GetAwaiter().GetResult()
# Successful returns 200 OK, deployment runs asynchronously
```

### 6. Verify Deployment Status
```powershell
$statusUrl = "$baseUrl/extensionDeploymentStatus?company=$companyParam&`$orderby=startedOn desc&`$top=3"
$resp = $httpClient.GetAsync($statusUrl).GetAwaiter().GetResult()
$json = ($resp.Content.ReadAsStringAsync().GetAwaiter().GetResult()) | ConvertFrom-Json

foreach ($item in $json.value) {
    # Statuses: Scheduled → InProgress → Completed | Failed
    Write-Host "$($item.name): $($item.status)"
}

# Check installed extensions
$extUrl = "$baseUrl/extensions?company=$companyParam"
$resp = $httpClient.GetAsync($extUrl).GetAwaiter().GetResult()
$json = ($resp.Content.ReadAsStringAsync().GetAwaiter().GetResult()) | ConvertFrom-Json
foreach ($ext in $json.value) {
    if ($ext.isInstalled -eq $true) {
        Write-Host "✅ $($ext.displayName) v$($ext.versionMajor).$($ext.versionMinor)"
    }
}
```

## Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `Internal_EntityWithSameKeyExists` (Id='0') | Previous entity exists (singleton table) | **Delete** old entity first, or **reuse** existing entity (steps above handle this) |
| `Could not validate client concurrency token` | Missing `If-Match` header on PUT | Add `$httpClient.DefaultRequestHeaders.Add("If-Match", "*")` before PUT |
| `PTE0004: Table is missing a matching permission set` | Per-tenant extension requires permission sets for all tables | Create `.PermissionSet.al` files for every table (R + RIMD sets) |
| `The record in table already exists` + App-ID conflict | `app.json` `id` GUID collides with existing AppSource extension | Generate new GUID: `uuidgen` → update `app.json` → rebuild |
| `BadRequest_NotSupported` on `$filter` | `extensionDeploymentStatus` entity doesn't support filter on all fields | Use `$orderby` + `$top` and filter client-side |
| Event subscriber runtime failure | Event name or parameter signature doesn't match target BC version | Verify event exists in symbol packages; prefer public procedures over fragile subscribers |
| Deployment status `Failed` (generic) | Various runtime issues during sync | Check `extensionDeploymentStatus` for specific error message; validate app against target BC version symbols |

## Full Deployment Script
See: `deploy.ps1` in the app project directory (generated by this skill)

## Notes
- The `extensionUpload` entity behaves like a **singleton** per environment — there's only one upload slot
- Deployments are **asynchronous**: the API returns immediately, processing happens in the background
- Check `extensionDeploymentStatus` with polling (5-15s intervals) to track progress
- The `If-Match: *` header is required for both the content PUT and the upload action
- Use `If-Match` with the actual ETag from GET for stricter concurrency, or `*` to bypass
- Company names must be URL-encoded: `[uri]::EscapeDataString("CRONUS AT")`
- BC SaaS sandboxes validate per-tenant extensions: every table needs a permission set
