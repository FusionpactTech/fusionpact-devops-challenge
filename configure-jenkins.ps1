# Jenkins Quick Configuration Script
Write-Host "🚀 Jenkins Configuration Helper" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

# Check Jenkins status
Write-Host "`n📊 Checking Jenkins Status..." -ForegroundColor Yellow
$jenkinsRunning = $false
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8090" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $jenkinsRunning = $true
    Write-Host "✅ Jenkins is running on port 8090" -ForegroundColor Green
} catch {
    Write-Host "❌ Jenkins is not accessible" -ForegroundColor Red
}

if ($jenkinsRunning) {
    Write-Host "`n🌐 Jenkins Access Information:" -ForegroundColor Cyan
    Write-Host "URL: http://localhost:8090" -ForegroundColor White
    Write-Host "Status: Running and accessible" -ForegroundColor White
    
    Write-Host "`n🔧 Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Open Jenkins in browser: http://localhost:8090" -ForegroundColor White
    Write-Host "2. If prompted for password, it may be in Jenkins console output" -ForegroundColor White
    Write-Host "3. Since setup wizard is disabled, you might see:" -ForegroundColor White
    Write-Host "   - A login page (try admin/admin123)" -ForegroundColor White
    Write-Host "   - Or direct access to Jenkins dashboard" -ForegroundColor White
    
    Write-Host "`n🔨 Create Pipeline Job:" -ForegroundColor Yellow
    Write-Host "1. Click 'New Item'" -ForegroundColor White
    Write-Host "2. Name: fusionpact-devops-challenge" -ForegroundColor White
    Write-Host "3. Type: Pipeline" -ForegroundColor White
    Write-Host "4. Configure Git repository:" -ForegroundColor White
    Write-Host "   Repository URL: file:///C:/Users/manoj/OneDrive/Desktop/devops%20intern/fusionpact-devops-challenge" -ForegroundColor Gray
    Write-Host "   Branch: */main" -ForegroundColor Gray
    Write-Host "   Script Path: Jenkinsfile" -ForegroundColor Gray
    
    Write-Host "`n🎯 Ready Actions:" -ForegroundColor Green
    Write-Host "• Open Jenkins Dashboard" -ForegroundColor White
    Write-Host "• Create Pipeline Job" -ForegroundColor White
    Write-Host "• Run First Build" -ForegroundColor White
    Write-Host "• Monitor Pipeline Execution" -ForegroundColor White
    
    # Open Jenkins automatically
    Write-Host "`n🌐 Opening Jenkins Dashboard..." -ForegroundColor Yellow
    Start-Process "http://localhost:8090"
    
} else {
    Write-Host "`n🔧 Jenkins Troubleshooting:" -ForegroundColor Red
    Write-Host "1. Check if Jenkins process is running:" -ForegroundColor White
    Write-Host "   Get-Process -Name 'java' | Where-Object { `$_.CommandLine -like '*jenkins*' }" -ForegroundColor Gray
    Write-Host "2. Check port availability:" -ForegroundColor White
    Write-Host "   netstat -an | findstr :8090" -ForegroundColor Gray
    Write-Host "3. Start Jenkins manually:" -ForegroundColor White
    Write-Host "   java -jar C:\Jenkins\jenkins.war --httpPort=8090" -ForegroundColor Gray
}

Write-Host "`n📋 Project Status:" -ForegroundColor Cyan
Write-Host "Level 1: ✅ Containerization Complete" -ForegroundColor Green
Write-Host "Level 2: ✅ Monitoring Complete" -ForegroundColor Green
Write-Host "Level 3: 🔧 Jenkins Running - Pipeline Setup Needed" -ForegroundColor Yellow

Write-Host "`n🎉 Almost Complete! Just configure the pipeline job and run your first build! 🚀" -ForegroundColor Green
