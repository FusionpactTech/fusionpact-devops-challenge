# GitHub Token Setup for Jenkins CI/CD
param(
    [string]$GitHubToken = ""
)

Write-Host "🔑 GITHUB TOKEN SETUP FOR JENKINS CI/CD" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Yellow
Write-Host ""

# Check if Jenkins is running
Write-Host "1. 🔍 Checking Jenkins status..." -ForegroundColor Magenta
$jenkinsProcess = Get-Process -Name java -ErrorAction SilentlyContinue
if ($jenkinsProcess) {
    Write-Host "   ✅ Jenkins is running (PID: $($jenkinsProcess.Id))" -ForegroundColor Green
} else {
    Write-Host "   ❌ Jenkins not running. Please start Jenkins first!" -ForegroundColor Red
    Write-Host "   Run: .\run-jenkins-simple.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "2. 📋 GITHUB TOKEN SETUP INSTRUCTIONS:" -ForegroundColor Magenta
Write-Host ""

if (-not $GitHubToken) {
    Write-Host "🌐 STEP 1: Create GitHub Personal Access Token" -ForegroundColor Cyan
    Write-Host "   1. Go to: https://github.com/settings/tokens" -ForegroundColor White
    Write-Host "   2. Click 'Generate new token (classic)'" -ForegroundColor White
    Write-Host "   3. Token name: Jenkins-DevOps-Challenge" -ForegroundColor White
    Write-Host "   4. Expiration: 90 days" -ForegroundColor White
    Write-Host "   5. Select scopes:" -ForegroundColor White
    Write-Host "      ✅ repo (Full control of private repositories)" -ForegroundColor Green
    Write-Host "      ✅ workflow (Update GitHub Action workflows)" -ForegroundColor Green
    Write-Host "      ✅ admin:repo_hook (Repository hooks)" -ForegroundColor Green
    Write-Host "   6. Generate token and COPY IT!" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "🔧 STEP 2: Configure in Jenkins" -ForegroundColor Cyan
    Write-Host "   1. Go to: http://localhost:8090/credentials/" -ForegroundColor White
    Write-Host "   2. Click: System → Global credentials → Add Credentials" -ForegroundColor White
    Write-Host "   3. Fill in:" -ForegroundColor White
    Write-Host "      Kind: Username with password" -ForegroundColor Gray
    Write-Host "      Username: kingslayer458" -ForegroundColor Gray
    Write-Host "      Password: [paste your GitHub token]" -ForegroundColor Gray
    Write-Host "      ID: github-token" -ForegroundColor Gray
    Write-Host "      Description: GitHub Token for DevOps Challenge" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "🔄 STEP 3: Update Pipeline Job" -ForegroundColor Cyan
    Write-Host "   1. Go to: http://localhost:8090/job/fusionpact-devops-challenge/configure" -ForegroundColor White
    Write-Host "   2. In Source Code Management section:" -ForegroundColor White
    Write-Host "   3. Repository URL: https://github.com/kingslayer458/fusionpact-devops-challenge.git" -ForegroundColor White
    Write-Host "   4. Credentials: Select 'github-token'" -ForegroundColor White
    Write-Host "   5. Click Save" -ForegroundColor White
    Write-Host ""
    
    $openBrowser = Read-Host "Open setup pages in browser? (y/n)"
    if ($openBrowser -eq 'y' -or $openBrowser -eq 'Y') {
        Write-Host "🔗 Opening GitHub token creation page..." -ForegroundColor Yellow
        Start-Process "https://github.com/settings/tokens"
        Start-Sleep 3
        Write-Host "🔗 Opening Jenkins credentials page..." -ForegroundColor Yellow
        Start-Process "http://localhost:8090/credentials/"
        Start-Sleep 2
        Write-Host "🔗 Opening Jenkins job configuration..." -ForegroundColor Yellow
        Start-Process "http://localhost:8090/job/fusionpact-devops-challenge/configure"
    }
} else {
    Write-Host "✅ GitHub token provided via parameter" -ForegroundColor Green
    Write-Host "📋 Use this token in Jenkins credentials configuration:" -ForegroundColor Cyan
    Write-Host "   Token: $($GitHubToken.Substring(0,10))..." -ForegroundColor Gray
}

Write-Host ""
Write-Host "🧪 STEP 4: Test Configuration" -ForegroundColor Magenta
Write-Host "   After setting up the token, test with:" -ForegroundColor White
Write-Host "   git commit --allow-empty -m 'Test GitHub token auth'" -ForegroundColor Gray
Write-Host "   git push origin main" -ForegroundColor Gray
Write-Host ""

Write-Host "🔍 VERIFICATION CHECKLIST:" -ForegroundColor Cyan
Write-Host "   ✅ GitHub token created with correct scopes" -ForegroundColor White
Write-Host "   ✅ Jenkins credentials configured (username + token)" -ForegroundColor White
Write-Host "   ✅ Pipeline job updated with github-token credential" -ForegroundColor White
Write-Host "   ✅ Test commit triggers automatic build" -ForegroundColor White
Write-Host ""

Write-Host "⚠️  COMMON ISSUES:" -ForegroundColor Yellow
Write-Host "   • 403 Forbidden: Wrong token or expired" -ForegroundColor Red
Write-Host "   • No credentials specified: Token not configured in job" -ForegroundColor Red
Write-Host "   • Authentication failed: Wrong username or token" -ForegroundColor Red
Write-Host ""

Write-Host "🎯 EXPECTED RESULT:" -ForegroundColor Green
Write-Host "   After configuration, builds should trigger automatically" -ForegroundColor White
Write-Host "   when you push commits to GitHub!" -ForegroundColor White
Write-Host ""

Write-Host "📞 Need help? Check the console output in Jenkins builds" -ForegroundColor Cyan
Write-Host "   for detailed error messages." -ForegroundColor White
