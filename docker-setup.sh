#!/bin/bash

# Docker Compose Setup & Troubleshooting Guide

set -e

echo "======================================"
echo "Docker Compose - Setup & Fix Guide"
echo "======================================"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking Prerequisites..."
echo ""

if ! command_exists docker; then
    echo "❌ Docker is not installed"
    echo "Install from: https://docs.docker.com/get-docker/"
    exit 1
else
    echo "✅ Docker is installed"
fi

if ! command_exists docker-compose; then
    echo "❌ Docker Compose is not installed"
    echo "Install from: https://docs.docker.com/compose/install/"
    exit 1
else
    echo "✅ Docker Compose is installed"
fi

echo ""
echo "======================================"
echo "Step 1: Fix Configuration Files"
echo "======================================"
echo ""

# Check if server/.env exists
if [ -f "server/.env" ]; then
    echo "✅ server/.env found"
    if grep -q "mysql-db" server/.env; then
        echo "⚠️  Found old hostname 'mysql-db', updating to 'mysql'..."
        sed -i 's/mysql-db/mysql/g' server/.env
        echo "✅ Updated server/.env"
    else
        echo "✅ server/.env already has correct hostname"
    fi
else
    echo "❌ server/.env not found"
    exit 1
fi

# Check if Dockerfile.dev exists
if [ ! -f "Dockerfile.dev" ]; then
    echo "⚠️  Dockerfile.dev not found, creating..."
    cat > Dockerfile.dev << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npx prisma generate

EXPOSE 3000

CMD ["npm", "run", "dev"]
EOF
    echo "✅ Created Dockerfile.dev"
else
    echo "✅ Dockerfile.dev already exists"
fi

# Check if scripts/init-db.sql exists
if [ ! -f "scripts/init-db.sql" ]; then
    echo "⚠️  scripts/init-db.sql not found, creating..."
    mkdir -p scripts
    cat > scripts/init-db.sql << 'EOF'
-- Initialize database with basic structure
-- This script runs on MySQL container startup
EOF
    echo "✅ Created scripts/init-db.sql"
else
    echo "✅ scripts/init-db.sql already exists"
fi

echo ""
echo "======================================"
echo "Step 2: Clean Up (Optional)"
echo "======================================"
echo ""
echo "Run the following to clean up old containers/images:"
echo ""
echo "  docker-compose down -v"
echo "  docker system prune -f"
echo ""

echo ""
echo "======================================"
echo "Step 3: Build Images"
echo "======================================"
echo ""
echo "Run the following to build all Docker images:"
echo ""
echo "  docker-compose build"
echo ""

echo ""
echo "======================================"
echo "Step 4: Start Services"
echo "======================================"
echo ""
echo "Run the following to start all services:"
echo ""
echo "  docker-compose up -d"
echo ""

echo ""
echo "======================================"
echo "Step 5: Verify Services"
echo "======================================"
echo ""
echo "Check service status:"
echo "  docker-compose ps"
echo ""
echo "View logs:"
echo "  docker-compose logs -f"
echo ""
echo "Check specific service:"
echo "  docker-compose logs -f frontend"
echo "  docker-compose logs -f backend"
echo "  docker-compose logs -f mysql"
echo ""

echo ""
echo "======================================"
echo "Common Issues & Solutions"
echo "======================================"
echo ""
echo "1. Port already in use:"
echo "   lsof -i :3000  (then kill -9 <PID>)"
echo "   lsof -i :3001  (then kill -9 <PID>)"
echo "   lsof -i :3306  (then kill -9 <PID>)"
echo ""
echo "2. Database connection refused:"
echo "   Wait 30 seconds for MySQL to be healthy"
echo "   docker-compose logs mysql"
echo ""
echo "3. Prisma errors:"
echo "   docker-compose exec backend npx prisma generate"
echo "   docker-compose exec backend npx prisma db push"
echo ""
echo "4. Frontend can't connect to backend:"
echo "   Check NEXT_PUBLIC_API_BASE_URL in docker-compose.yml"
echo "   docker-compose logs frontend | grep -i error"
echo ""
echo "5. Permission denied:"
echo "   sudo usermod -aG docker $USER"
echo "   newgrp docker"
echo ""

echo ""
echo "======================================"
echo "Useful Commands"
echo "======================================"
echo ""
echo "# Start services in background"
echo "docker-compose up -d"
echo ""
echo "# Stop services"
echo "docker-compose down"
echo ""
echo "# Reset everything (including database)"
echo "docker-compose down -v"
echo ""
echo "# View logs"
echo "docker-compose logs -f"
echo ""
echo "# Execute command in service"
echo "docker-compose exec backend npm run logs"
echo ""
echo "# Access MySQL database"
echo "docker-compose exec mysql mysql -u root -p singitronic_nextjs"
echo ""
echo "# View database structure"
echo "docker-compose exec mysql mysql -u root -p -e \"SHOW TABLES;\" singitronic_nextjs"
echo ""

echo ""
echo "======================================"
echo "Setup Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. cd /home/luffy/Documents/practice/ECOMMERCE/Ecommerce_k8s"
echo "2. docker-compose build"
echo "3. docker-compose up -d"
echo "4. docker-compose logs -f"
echo ""
echo "Then access:"
echo "- Frontend: http://localhost:3000"
echo "- Backend API: http://localhost:3001"
echo "- PhpMyAdmin: http://localhost:8080"
echo ""
