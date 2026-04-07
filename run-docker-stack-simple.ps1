# Docker Stack Runner for PowerShell (Simple Version)
# This script builds and runs the complete logging pipeline

Write-Host "Starting Docker Stack Setup..." -ForegroundColor Green

# Check if Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Host "ERROR: Docker is not running. Please start Docker first." -ForegroundColor Red
    exit 1
}

# Check if docker-compose is available
if (!(Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: docker-compose is not installed." -ForegroundColor Red
    exit 1
}

# Build Spring Boot application
Write-Host "Building Spring Boot application..." -ForegroundColor Blue
$mavenResult = mvn clean package -q

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Maven build failed." -ForegroundColor Red
    exit 1
}

# Copy JAR to api directory
Write-Host "Copying JAR to api directory..." -ForegroundColor Blue
$jarPath = "target/api-logfile-filebeat-graylog-1.0.0.jar"
$destPath = "api/app.jar"

if (!(Test-Path $jarPath)) {
    Write-Host "ERROR: JAR file not found at $jarPath" -ForegroundColor Red
    exit 1
}

Copy-Item $jarPath $destPath

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to copy JAR file." -ForegroundColor Red
    exit 1
}

# Stop any existing containers
Write-Host "Stopping existing containers..." -ForegroundColor Yellow
docker-compose down -v

# Build and start services
Write-Host "Building and starting Docker services..." -ForegroundColor Blue
docker-compose up --build -d

# Wait for services to be ready
Write-Host "Waiting for services to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Check service status
Write-Host "Checking service status..." -ForegroundColor Cyan
docker-compose ps

# Display access information
Write-Host ""
Write-Host "SUCCESS: Docker Stack is running!" -ForegroundColor Green
Write-Host ""
Write-Host "Service URLs:" -ForegroundColor Cyan
Write-Host "   - Spring Boot API:     http://localhost:8080"
Write-Host "   - Graylog Dashboard:   http://localhost:9000"
Write-Host ""
Write-Host "Graylog Login:" -ForegroundColor Cyan
Write-Host "   - Username: admin"
Write-Host "   - Password: admin"
Write-Host ""
Write-Host "Test the API:" -ForegroundColor Cyan
Write-Host "   curl -X POST http://localhost:8080/items -H `"Content-Type: application/json`" -d '{`"name`":`"Test Book`",`"description`":`"A test book`"}'"
Write-Host ""
Write-Host "Useful Commands:" -ForegroundColor Cyan
Write-Host "   - View logs:    docker-compose logs -f"
Write-Host "   - Stop stack:   docker-compose down"
Write-Host "   - Restart:      docker-compose restart"
Write-Host ""
Write-Host "Check logs in Graylog:" -ForegroundColor Cyan
Write-Host "   1. Open http://localhost:9000"
Write-Host "   2. Go to System -> Inputs"
Write-Host "   3. Ensure Beats input is running on port 5044"
Write-Host "   4. Go to Search to see API logs"
Write-Host ""

# Optional: Test API automatically
$test = Read-Host "Do you want to test the API automatically? (y/n)"
if ($test -eq 'y' -or $test -eq 'Y') {
    Write-Host "Testing API endpoints..." -ForegroundColor Blue
    
    try {
        # Create an item
        Write-Host "Creating test item..." -ForegroundColor Yellow
        $createResponse = Invoke-RestMethod -Uri "http://localhost:8080/items" -Method Post -ContentType "application/json" -Body '{"name":"Test Book","description":"A test book for logging"}'
        Write-Host "SUCCESS: Created item with id=$($createResponse.id)" -ForegroundColor Green
        
        # Get all items
        Write-Host "Getting all items..." -ForegroundColor Yellow
        $getItems = Invoke-RestMethod -Uri "http://localhost:8080/items" -Method Get
        Write-Host "SUCCESS: Found $($getItems.Count) items" -ForegroundColor Green
        
        Write-Host "SUCCESS: API test completed. Check Graylog for logs!" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: API test failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "DEBUG: Check if the API is running with: docker-compose logs api" -ForegroundColor Yellow
    }
}

Write-Host "Setup complete! Your logging pipeline is ready." -ForegroundColor Green
