# Deploy AL App to BC SaaS Sandbox (Automation API v2.0)
# Usage: pwsh -File deploy.ps1 -tenantId "..." -clientId "..." -clientSecret "..." -appFile "./MyApp.app"

param(
    [string]$tenantId = "",
    [string]$clientId = "",
    [string]$clientSecret = "",
    [string]$env = "Sandbox",
    [string]$companyName = "CRONUS AT",
    [string]$appFile = ""
)

# Validate inputs
if (-not $tenantId -or -not $clientId -or -not $clientSecret -or -not $appFile) {
    Write-Host "❌ Error: Missing required parameters!" -ForegroundColor Red
    Write-Host "Usage: pwsh -File deploy.ps1 -tenantId '...' -clientId '...' -clientSecret '...' -appFile './MyApp.app' [-env 'Sandbox'] [-companyName 'CRONUS AT']"
    exit 1
}

if (-not (Test-Path $appFile)) {
    Write-Host "❌ Error: App file not found: $appFile" -ForegroundColor Red
    exit 1
}

Write-Host "🚀 BC Extension Deployment" -ForegroundColor Cyan
Write-Host ("=" * 60)

# Step 1: Auth
Write-Host "`n🔐 Authenticating..." -ForegroundColor Yellow
try {
    $tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method Post -Body @{
        client_id     = $clientId
        client_secret = $clientSecret
        scope         = "https://api.businesscentral.dynamics.com/.default"
        grant_type    = "client_credentials"
    } -TimeoutSec 15
    $token = $tokenResponse.access_token
    Write-Host "✅ Token obtained" -ForegroundColor Green
} catch {
    Write-Host "❌ Auth failed: $_" -ForegroundColor Red
    exit 1
}

$httpClient = [System.Net.Http.HttpClient]::new()
$httpClient.Timeout = [TimeSpan]::FromMinutes(2)
$httpClient.DefaultRequestHeaders.Authorization = [System.Net.Http.Headers.AuthenticationHeaderValue]::new("Bearer", $token)

$companyParam = "?company=$([uri]::EscapeDataString($companyName))"
$baseUrl = "https://api.businesscentral.dynamics.com/v2.0/$tenantId/$env/api/microsoft/automation/v2.0"

# Step 2: Find or create extensionUpload entity
Write-Host "`n📤 Searching for extensionUpload entity..." -ForegroundColor Yellow
$listUrl = "$baseUrl/extensionUpload$companyParam"
$listResponse = $httpClient.GetAsync($listUrl).GetAwaiter().GetResult()
$listBody = $listResponse.Content.ReadAsStringAsync().GetAwaiter().GetResult()
$listJson = $listBody | ConvertFrom-Json

if ($listJson.value.Count -eq 0) {
    Write-Host "   No existing entity, creating new one..." -ForegroundColor Gray
    $createPayload = @{
        schedule = "Current_x0020_version"
        schemaSyncMode = "Add"
    } | ConvertTo-Json
    
    $createUrl = "$baseUrl/extensionUpload$companyParam"
    $createContent = [System.Net.Http.StringContent]::new($createPayload, [System.Text.Encoding]::UTF8, "application/json")
    $createResponse = $httpClient.PostAsync($createUrl, $createContent).GetAwaiter().GetResult()
    $createBody = $createResponse.Content.ReadAsStringAsync().GetAwaiter().GetResult()
    
    if (-not $createResponse.IsSuccessStatusCode) {
        Write-Host "❌ Create failed: $createBody" -ForegroundColor Red
        $httpClient.Dispose()
        exit 1
    }
    
    $responseJson = $createBody | ConvertFrom-Json
    $systemId = $responseJson.systemId
    Write-Host "✅ Entity created: $systemId" -ForegroundColor Green
} else {
    $existing = $listJson.value[0]
    $systemId = $existing.systemId
    $mediaUrl = $existing.'extensionContent@odata.mediaEditLink'
    Write-Host "✅ Existing entity: $systemId" -ForegroundColor Green
}

# Step 3: Upload app file content
Write-Host "`n📦 Uploading app file..." -ForegroundColor Yellow
$appBytes = [System.IO.File]::ReadAllBytes($appFile)
Write-Host "   Size: $($appBytes.Length) bytes" -ForegroundColor Gray

if (-not $mediaUrl) {
    $mediaUrl = "$baseUrl/extensionUpload($systemId)/extensionContent$companyParam"
}

# CRITICAL: If-Match header for concurrency token
$httpClient.DefaultRequestHeaders.Remove("If-Match")
$httpClient.DefaultRequestHeaders.Add("If-Match", "*")

$byteContent = [System.Net.Http.ByteArrayContent]::new($appBytes)
$byteContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::new("application/octet-stream")

try {
    $putResponse = $httpClient.PutAsync($mediaUrl, $byteContent).GetAwaiter().GetResult()
    $putBody = $putResponse.Content.ReadAsStringAsync().GetAwaiter().GetResult()
    
    if ($putResponse.IsSuccessStatusCode) {
        Write-Host "✅ App file uploaded" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Upload status: $($putResponse.StatusCode)" -ForegroundColor Yellow
        if ($putBody) { Write-Host "   Body: $putBody" -ForegroundColor Gray }
    }
} catch {
    Write-Host "❌ Upload error: $_" -ForegroundColor Red
}

# Step 4: Trigger deployment
Write-Host "`n🚀 Triggering deployment (upload action)..." -ForegroundColor Yellow
$actionUrl = "$baseUrl/extensionUpload($systemId)/Microsoft.NAV.upload$companyParam"

$actionContent = [System.Net.Http.StringContent]::new("{}", [System.Text.Encoding]::UTF8, "application/json")
$httpClient.DefaultRequestHeaders.Remove("If-Match")
$httpClient.DefaultRequestHeaders.Add("If-Match", "*")

try {
    $actionResponse = $httpClient.PostAsync($actionUrl, $actionContent).GetAwaiter().GetResult()
    $actionBody = $actionResponse.Content.ReadAsStringAsync().GetAwaiter().GetResult()
    
    Write-Host "   Status: $($actionResponse.StatusCode)" -ForegroundColor $(if($actionResponse.IsSuccessStatusCode){"Green"}else{"Yellow"})
    
    if ($actionResponse.IsSuccessStatusCode) {
        Write-Host ""
        Write-Host "✅✅✅ DEPLOYMENT TRIGGERED SUCCESSFULLY! ✅✅✅" -ForegroundColor Green
        Write-Host ""
        Write-Host "   Sandbox: https://businesscentral.dynamics.com/$tenantId/$env" -ForegroundColor Cyan
        Write-Host "   (Deployment runs asynchronously - check extensionDeploymentStatus)" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Action failed: $_" -ForegroundColor Red
}

$httpClient.Dispose()
