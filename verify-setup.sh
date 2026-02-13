#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  E-Commerce Project - Local Setup Verification Script${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"

# Check Node.js
echo -e "${YELLOW}[1] Checking Node.js...${NC}"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓ Node.js installed: $NODE_VERSION${NC}"
else
    echo -e "${RED}✗ Node.js not found${NC}"
fi

# Check npm
echo -e "\n${YELLOW}[2] Checking npm...${NC}"
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✓ npm installed: $NPM_VERSION${NC}"
else
    echo -e "${RED}✗ npm not found${NC}"
fi

# Check Git
echo -e "\n${YELLOW}[3] Checking Git...${NC}"
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    echo -e "${GREEN}✓ Git installed: $GIT_VERSION${NC}"
else
    echo -e "${YELLOW}⚠ Git not found (optional)${NC}"
fi

# Check Docker
echo -e "\n${YELLOW}[4] Checking Docker...${NC}"
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✓ Docker installed: $DOCKER_VERSION${NC}"
    
    # Check if MySQL container is running
    if docker ps | grep -q mysql; then
        echo -e "${GREEN}  ✓ MySQL container is running${NC}"
    else
        echo -e "${YELLOW}  ⚠ MySQL container not running (start with: docker-compose up)${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Docker not found (optional for containerized setup)${NC}"
fi

# Check MySQL
echo -e "\n${YELLOW}[5] Checking MySQL...${NC}"
if command -v mysql &> /dev/null; then
    MYSQL_VERSION=$(mysql --version)
    echo -e "${GREEN}✓ MySQL CLI installed: $MYSQL_VERSION${NC}"
    
    # Test connection
    if mysql -u root -pnavat -e "SELECT 1" &> /dev/null; then
        echo -e "${GREEN}  ✓ MySQL connection successful (root@localhost)${NC}"
    else
        echo -e "${YELLOW}  ⚠ MySQL connection failed (check password/server status)${NC}"
    fi
else
    echo -e "${YELLOW}⚠ MySQL CLI not found (use Docker or update PATH)${NC}"
fi

# Check project files
echo -e "\n${YELLOW}[6] Checking project files...${NC}"

if [ -f "package.json" ]; then
    echo -e "${GREEN}✓ Frontend package.json found${NC}"
else
    echo -e "${RED}✗ Frontend package.json not found${NC}"
fi

if [ -f "server/package.json" ]; then
    echo -e "${GREEN}✓ Backend package.json found${NC}"
else
    echo -e "${RED}✗ Backend package.json not found${NC}"
fi

if [ -f ".env" ]; then
    echo -e "${GREEN}✓ Frontend .env file found${NC}"
else
    echo -e "${RED}✗ Frontend .env file not found${NC}"
fi

if [ -f "server/.env" ]; then
    echo -e "${GREEN}✓ Backend .env file found${NC}"
else
    echo -e "${RED}✗ Backend .env file not found${NC}"
fi

if [ -f "prisma/schema.prisma" ]; then
    echo -e "${GREEN}✓ Prisma schema found${NC}"
else
    echo -e "${RED}✗ Prisma schema not found${NC}"
fi

# Check dependencies
echo -e "\n${YELLOW}[7] Checking dependencies installation...${NC}"

if [ -d "node_modules" ]; then
    FRONTEND_DEPS=$(find node_modules -maxdepth 1 -type d | wc -l)
    echo -e "${GREEN}✓ Frontend dependencies installed ($((FRONTEND_DEPS - 1)) packages)${NC}"
else
    echo -e "${YELLOW}⚠ Frontend dependencies not installed (run: npm install)${NC}"
fi

if [ -d "server/node_modules" ]; then
    BACKEND_DEPS=$(find server/node_modules -maxdepth 1 -type d | wc -l)
    echo -e "${GREEN}✓ Backend dependencies installed ($((BACKEND_DEPS - 1)) packages)${NC}"
else
    echo -e "${YELLOW}⚠ Backend dependencies not installed (run: cd server && npm install)${NC}"
fi

# Summary
echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "\n${GREEN}Next Steps:${NC}"
echo "  1. Install dependencies: npm install && cd server && npm install && cd .."
echo "  2. Start MySQL: docker-compose up -d mysql (or local MySQL)"
echo "  3. Setup database: npm run db:push"
echo "  4. Start backend: cd server && npm run dev"
echo "  5. Start frontend: npm run dev"
echo "  6. Access app: http://localhost:3000"
echo -e "\n${YELLOW}For detailed setup instructions, see: LOCAL_SETUP_GUIDE.md${NC}\n"
