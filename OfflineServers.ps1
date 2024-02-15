# Cloud One Region
$region = "trend-us-1" # Your Region (i.e. us-1)
# Trend Micro Cloud One API endpoint URLs
$apiBaseUrl = "https://workload.$region.cloudone.trendmicro.com/api"
$endpointUrl = "$apiBaseUrl/computers"

# Your Trend Micro Cloud One API key
$apiKey = "YOUR_API_KEY"

# Authenticate and set headers
$headers = @{
    "Authorization" = "ApiKey $apiKey"
    "Content-Type" = "application/json"
    "api-version" = "v1"
}

# Function to retrieve endpoint data
function Get-Endpoints {
    $response = Invoke-RestMethod -Uri $endpointUrl -Headers $headers -Method Get
    return $response.computers
}

# Function to filter offline endpoints
function Get-OfflineEndpoints {
    $endpoints = Get-Endpoints
    $offlineEndpoints = $endpoints | Where-Object { $_.computerStatus.agentStatusMessages -contains "Offline" }
    return $offlineEndpoints
}

# Function to calculate offline duration
function Calculate-OfflineDuration {
    param (
        $lastCommunicationTime
    )

    $offlineDuration = (Get-Date) - (Get-Date -UnixTime "$lastCommunicationTime".Substring(0,10))
    Write-Host $offlineDuration.Days "Days"
    return $offlineDuration
}

# Function to filter endpoints by offline duration
function Get-EndpointsWithOfflineDuration {
    $offlineEndpoints = Get-OfflineEndpoints
    $filteredEndpoints = @()

    foreach ($endpoint in $offlineEndpoints) {
        $offlineDuration = Calculate-OfflineDuration -lastCommunicationTime $endpoint.lastAgentCommunication
        if ($offlineDuration.Days -ge 30) {
            $endpoint | Add-Member -MemberType NoteProperty -Name OfflineDuration -Value "$($offlineDuration.Days) Days"
            $filteredEndpoints += $endpoint
        }
    }

    return $filteredEndpoints
}

# Function to generate report
function Generate-Report {
    $offlineEndpoints = Get-EndpointsWithOfflineDuration
    # Generate report formatting output as needed
    # Example: Convert to CSV, HTML, etc.
    $offlineEndpoints | Export-Csv -Path "offline_endpoints_report.csv" -NoTypeInformation
}

# Execute the script
Generate-Report
