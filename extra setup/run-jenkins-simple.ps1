# Simple Jenkins Runner
Write-Host "Starting Jenkins..." -ForegroundColor Green

# Check if Jenkins is running
$jenkinsProcess = Get-Process -Name "java" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*jenkins.war*" }
if ($jenkinsProcess) {
    Write-Host "Jenkins is already running!" -ForegroundColor Yellow
    Start-Process "http://localhost:8090"
    exit 0
}

# Set environment
$env:JENKINS_HOME = "C:\Jenkins\jenkins_home"
$jenkinsWar = "C:\Jenkins\jenkins.war"

if (-not (Test-Path $jenkinsWar)) {
    Write-Host "Jenkins not found! Run setup-jenkins-simple.ps1 first" -ForegroundColor Red
    exit 1
}

Write-Host "Starting Jenkins server..." -ForegroundColor Yellow
Write-Host "Jenkins Home: $env:JENKINS_HOME" -ForegroundColor Cyan

# Start Jenkins in background
$jenkinsJob = Start-Job -ScriptBlock {
    param($jenkinsWar, $jenkinsHome)
    $env:JENKINS_HOME = $jenkinsHome
    & java "-Djenkins.install.runSetupWizard=false" "-jar" $jenkinsWar "--httpPort=8090"
} -ArgumentList $jenkinsWar, $env:JENKINS_HOME

Write-Host "Jenkins starting (Job ID: $($jenkinsJob.Id))..." -ForegroundColor Yellow
Write-Host "Waiting for Jenkins to be ready..." -ForegroundColor Yellow

# Wait for Jenkins
$maxWait = 120
$waited = 0
$ready = $false

while ($waited -lt $maxWait -and -not $ready) {
    Start-Sleep -Seconds 5
    $waited += 5
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8090" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $ready = $true
        }
    } catch {
        Write-Host "." -NoNewline -ForegroundColor Gray
    }
}

Write-Host ""

if ($ready) {
    Write-Host "Jenkins is ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "ACCESS INFO:" -ForegroundColor Cyan
    Write-Host "URL: http://localhost:8090" -ForegroundColor White
    Write-Host "Username: admin" -ForegroundColor White
    Write-Host "Password: admin123" -ForegroundColor White
    Write-Host ""
    Write-Host "Opening Jenkins..." -ForegroundColor Yellow
    Start-Process "http://localhost:8090"
    
    # Save session info
    @{
        JobId = $jenkinsJob.Id
        StartTime = Get-Date
        URL = "http://localhost:8090"
    } | ConvertTo-Json | Out-File "jenkins-session.json"
    
} else {
    Write-Host "Jenkins failed to start!" -ForegroundColor Red
    Write-Host "Check output: Get-Job $($jenkinsJob.Id) | Receive-Job" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "To stop Jenkins: Stop-Job $($jenkinsJob.Id)" -ForegroundColor Cyan
