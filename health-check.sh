#!/bin/bash

# Health Check Script for Fusionpact DevOps Challenge
# This script monitors the health of both frontend and backend services

echo "🔍 Fusionpact DevOps Challenge - Health Check"
echo "=============================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running"
    exit 1
fi

# Check container status
echo "📊 Container Status:"
docker-compose ps

echo ""

# Test Frontend
echo "🌐 Testing Frontend Service..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8070)
if [ "$FRONTEND_STATUS" -eq 200 ]; then
    echo "✅ Frontend: HEALTHY (Status: $FRONTEND_STATUS)"
else
    echo "❌ Frontend: UNHEALTHY (Status: $FRONTEND_STATUS)"
fi

# Test Backend API
echo "⚡ Testing Backend API..."
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8060)
if [ "$BACKEND_STATUS" -eq 200 ]; then
    echo "✅ Backend API: HEALTHY (Status: $BACKEND_STATUS)"
    
    # Test API response
    API_RESPONSE=$(curl -s http://localhost:8060)
    echo "   Response: $API_RESPONSE"
else
    echo "❌ Backend API: UNHEALTHY (Status: $BACKEND_STATUS)"
fi

# Test Metrics Endpoint
echo "📈 Testing Metrics Endpoint..."
METRICS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8060/metrics)
if [ "$METRICS_STATUS" -eq 200 ]; then
    echo "✅ Metrics: HEALTHY (Status: $METRICS_STATUS)"
else
    echo "❌ Metrics: UNHEALTHY (Status: $METRICS_STATUS)"
fi

# Test Users API
echo "👥 Testing Users API..."
USERS_GET_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8060/users)
if [ "$USERS_GET_STATUS" -eq 200 ]; then
    echo "✅ Users GET: HEALTHY (Status: $USERS_GET_STATUS)"
    
    # Show current users
    USERS_DATA=$(curl -s http://localhost:8000/users)
    echo "   Current users: $USERS_DATA"
else
    echo "❌ Users GET: UNHEALTHY (Status: $USERS_GET_STATUS)"
fi

# Test POST endpoint with sample data
echo "📝 Testing Users POST..."
POST_RESPONSE=$(curl -s -X POST http://localhost:8060/users \
    -H "Content-Type: application/json" \
    -d '{"first_name":"Test","last_name":"User","age":25}' \
    -w "%{http_code}")

POST_STATUS="${POST_RESPONSE: -3}"
POST_BODY="${POST_RESPONSE%???}"

if [ "$POST_STATUS" -eq 200 ]; then
    echo "✅ Users POST: HEALTHY (Status: $POST_STATUS)"
    echo "   Response: $POST_BODY"
else
    echo "❌ Users POST: UNHEALTHY (Status: $POST_STATUS)"
fi

# Check data persistence
echo "💾 Checking Data Persistence..."
if docker volume ls | grep -q "backend-data"; then
    echo "✅ Data volume exists"
    VOLUME_INFO=$(docker volume inspect fusionpact-devops-challenge_backend-data --format '{{.Mountpoint}}')
    echo "   Volume location: $VOLUME_INFO"
else
    echo "❌ Data volume missing"
fi

# Resource usage
echo "💻 Resource Usage:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

echo ""
echo "🏁 Health check complete!"
echo "=============================================="
