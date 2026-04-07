#!/bin/bash

# Docker Stack Runner
# This script builds and runs the complete logging pipeline

echo "🐳 Starting Docker Stack Setup..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed."
    exit 1
fi

# Build Spring Boot application
echo "📦 Building Spring Boot application..."
mvn clean package -q

if [ $? -ne 0 ]; then
    echo "❌ Maven build failed."
    exit 1
fi

# Copy JAR to api directory
echo "📋 Copying JAR to api directory..."
cp target/api-logfile-filebeat-graylog-1.0.0.jar api/app.jar

if [ $? -ne 0 ]; then
    echo "❌ Failed to copy JAR file."
    exit 1
fi

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose down -v

# Build and start services
echo "🚀 Building and starting Docker services..."
docker-compose up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Check service status
echo "📊 Checking service status..."
docker-compose ps

# Display access information
echo ""
echo "✅ Docker Stack is running!"
echo ""
echo "🌐 Service URLs:"
echo "   - Spring Boot API:     http://localhost:8080"
echo "   - Graylog Dashboard:   http://localhost:9000"
echo ""
echo "🔑 Graylog Login:"
echo "   - Username: admin"
echo "   - Password: admin"
echo ""
echo "🧪 Test the API:"
echo "   curl -X POST http://localhost:8080/items -H \"Content-Type: application/json\" -d '{\"name\":\"Test Book\",\"description\":\"A test book\"}'"
echo ""
echo "📋 Useful Commands:"
echo "   - View logs:    docker-compose logs -f"
echo "   - Stop stack:   docker-compose down"
echo "   - Restart:      docker-compose restart"
echo ""
echo "🔍 Check logs in Graylog:"
echo "   1. Open http://localhost:9000"
echo "   2. Go to System → Inputs"
echo "   3. Ensure Beats input is running on port 5044"
echo "   4. Go to Search to see API logs"
echo ""

# Optional: Test API automatically
read -p "🧪 Do you want to test the API automatically? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧪 Testing API endpoints..."
    
    # Create an item
    echo "Creating test item..."
    curl -s -X POST http://localhost:8080/items \
        -H "Content-Type: application/json" \
        -d '{"name":"Test Book","description":"A test book for logging"}'
    
    # Get all items
    echo -e "\nGetting all items..."
    curl -s http://localhost:8080/items
    
    echo -e "\n✅ API test completed. Check Graylog for logs!"
fi

echo "🎉 Setup complete! Your logging pipeline is ready."
