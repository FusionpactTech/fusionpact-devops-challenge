# Jenkins Setup for admin1/admin458
Write-Host "Setting up Jenkins with admin1/admin458 credentials..." -ForegroundColor Green

# Stop current Jenkins if running
Write-Host "Stopping current Jenkins..." -ForegroundColor Yellow
Get-Process -Name "java" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*jenkins*" } | Stop-Process -Force -ErrorAction SilentlyContinue

Start-Sleep 5

# Set Jenkins home
$jenkinsHome = "C:\Jenkins\jenkins_home"
$env:JENKINS_HOME = $jenkinsHome

# Create directories
$usersDir = "$jenkinsHome\users"
$adminDir = "$usersDir\admin1_123456789"
$jobsDir = "$jenkinsHome\jobs"
$pipelineDir = "$jobsDir\fusionpact-devops-challenge"

New-Item -ItemType Directory -Path $usersDir -Force | Out-Null
New-Item -ItemType Directory -Path $adminDir -Force | Out-Null
New-Item -ItemType Directory -Path $jobsDir -Force | Out-Null
New-Item -ItemType Directory -Path $pipelineDir -Force | Out-Null

Write-Host "Created Jenkins directories" -ForegroundColor Green

# Create admin1 user with admin458 password (bcrypt hash)
$userConfig = @'
<?xml version='1.1' encoding='UTF-8'?>
<user>
  <fullName>Administrator</fullName>
  <properties>
    <hudson.security.HudsonPrivateSecurityRealm_-Details>
      <passwordHash>#jbcrypt:$2a$10$XOJhAOmmmS5KhUhRYbCfzOFAFh4K.oKk7EcF1QFChJgxsN5xBhSgG</passwordHash>
    </hudson.security.HudsonPrivateSecurityRealm_-Details>
  </properties>
</user>
'@

$userConfig | Out-File -FilePath "$adminDir\config.xml" -Encoding UTF8
Write-Host "Created admin1 user configuration" -ForegroundColor Green

# Create Jenkins main config
$mainConfig = @'
<?xml version='1.1' encoding='UTF-8'?>
<hudson>
  <version>2.401.3</version>
  <installStateName>RUNNING</installStateName>
  <numExecutors>2</numExecutors>
  <mode>NORMAL</mode>
  <useSecurity>true</useSecurity>
  <authorizationStrategy class="hudson.security.FullControlOnceLoggedInAuthorizationStrategy">
    <denyAnonymousReadAccess>true</denyAnonymousReadAccess>
  </authorizationStrategy>
  <securityRealm class="hudson.security.HudsonPrivateSecurityRealm">
    <disableSignup>true</disableSignup>
    <enableCaptcha>false</enableCaptcha>
  </securityRealm>
  <views>
    <hudson.model.AllView>
      <owner class="hudson" reference="../../.."/>
      <name>all</name>
      <filterExecutors>false</filterExecutors>
      <filterQueue>false</filterQueue>
    </hudson.model.AllView>
  </views>
  <primaryView>all</primaryView>
</hudson>
'@

$mainConfig | Out-File -FilePath "$jenkinsHome\config.xml" -Encoding UTF8
Write-Host "Created Jenkins main configuration" -ForegroundColor Green

# Get current path for Git repository
$currentPath = (Get-Location).Path
$gitPath = "file:///$($currentPath.Replace('\', '/').Replace(' ', '%20'))"

# Create pipeline job
$jobConfig = @"
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition>
  <description>Fusionpact DevOps Challenge CI/CD Pipeline</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
      <triggers>
        <hudson.triggers.SCMTrigger>
          <spec>H/5 * * * *</spec>
          <ignorePostCommitHooks>false</ignorePostCommitHooks>
        </hudson.triggers.SCMTrigger>
      </triggers>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition">
    <scm class="hudson.plugins.git.GitSCM">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>$gitPath</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/main</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
    </scm>
    <scriptPath>Jenkinsfile</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
"@

$jobConfig | Out-File -FilePath "$pipelineDir\config.xml" -Encoding UTF8
Write-Host "Created pipeline job configuration" -ForegroundColor Green

# Start Jenkins with new configuration
Write-Host "Starting Jenkins on port 8090..." -ForegroundColor Yellow
Start-Job -ScriptBlock {
    param($jenkinsHome)
    $env:JENKINS_HOME = $jenkinsHome
    & java "-Djenkins.install.runSetupWizard=false" "-jar" "C:\Jenkins\jenkins.war" "--httpPort=8090"
} -ArgumentList $jenkinsHome | Out-Null

Write-Host "Waiting for Jenkins to start..." -ForegroundColor Yellow
Start-Sleep 30

# Test Jenkins
try {
    Invoke-WebRequest -Uri "http://localhost:8090" -UseBasicParsing -TimeoutSec 10 | Out-Null
    Write-Host "Jenkins is running!" -ForegroundColor Green
} catch {
    Write-Host "Jenkins may still be starting..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Jenkins Setup Complete!" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green
Write-Host "URL: http://localhost:8090" -ForegroundColor White
Write-Host "Username: admin1" -ForegroundColor White
Write-Host "Password: admin458" -ForegroundColor White
Write-Host "Pipeline Job: fusionpact-devops-challenge" -ForegroundColor White
Write-Host ""
Write-Host "Open Jenkins and click 'Build Now' to run the pipeline!" -ForegroundColor Cyan
