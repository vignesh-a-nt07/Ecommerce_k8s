# Docker Compose Issues & Solutions

## Problems Identified

### 1. **Command Syntax Error**
**Issue**: Running `docker-compose.yml up` instead of `docker-compose up`
```bash
# ❌ WRONG
docker-compose.yml up

# ✅ CORRECT
docker-compose up
```

### 2. **Database URL Mismatch**
**Location**: `server/.env` vs `docker-compose.yml`

- **server/.env** uses: `mysql-db:3306`
- **docker-compose.yml** uses: `mysql:3306` (service name is `mysql`)

**Solution**: Update server/.env
```properties
DATABASE_URL=mysql://root:navat@mysql:3306/singitronic_nextjs
```

### 3. **Frontend Dockerfile Issue**
**Problem**: The frontend Dockerfile uses production commands but docker-compose runs dev mode

**Current Dockerfile** (`/Dockerfile`):
```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build  # ← This requires Prisma generation

# ---- Production image ----
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app ./
EXPOSE 3000
CMD ["npm", "start"]
```

**Issues**:
- Tries to build in Dockerfile but docker-compose overrides with `npm run dev`
- `npm run build` requires `prisma generate` which happens in script
- The build fails because environment variables might not be set

**Solution**: Create a dev-friendly Dockerfile
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run db:generate

EXPOSE 3000

CMD ["npm", "run", "dev"]
```

### 4. **Missing init-db.sql Script**
**Problem**: `docker-compose.yml` references `./scripts/init-db.sql` but it might not exist

```yaml
volumes:
  - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init.sql:ro  # ← File missing?
```

**Solution**: Create the script or remove the volume mount

### 5. **Backend Dockerfile Issues**
**Problem**: Backend runs migrations on startup which can conflict with multiple container starts

```dockerfile
CMD ["sh", "-c", "npx prisma migrate deploy && node app.js"]
```

**Issues**:
- If multiple containers start simultaneously, migrations might conflict
- No retry logic if database isn't ready

**Solution**: Add health check and retry logic

### 6. **Frontend Depends On Backend - But Backend Needs DB**
**Dependency Chain Issue**:
```yaml
frontend:
  depends_on:
    - backend  # ← Backend must be healthy
    
backend:
  depends_on:
    mysql:
      condition: service_healthy  # ← Correct health check
```

**Problem**: Frontend doesn't wait for backend to be truly healthy
- Backend service starts but might not be listening yet
- Frontend tries to connect and fails

**Solution**: Add health checks to backend

## Step-by-Step Fix

### Step 1: Fix server/.env
```bash
cd server
# Update DATABASE_URL
sed -i 's/mysql-db/mysql/g' .env
```

### Step 2: Create/Fix Frontend Dockerfile
Create a new file `/Dockerfile.dev`:
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npx prisma generate

EXPOSE 3000

CMD ["npm", "run", "dev"]
```

### Step 3: Update docker-compose.yml
Replace:
```yaml
  frontend:
    build:
      context: .
      dockerfile: Dockerfile
```

With:
```yaml
  frontend:
    build:
      context: .
      dockerfile: Dockerfile.dev
```

### Step 4: Add Health Checks
Add to backend service:
```yaml
  backend:
    # ... existing config
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001/health || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 5
```

### Step 5: Create Init Database Script
Create `/scripts/init-db.sql`:
```sql
-- Initialize database if needed
-- Add initial seed data here if required
```

### Step 6: Update Frontend depends_on
```yaml
  frontend:
    depends_on:
      backend:
        condition: service_healthy
      mysql:
        condition: service_healthy
```

## Correct Commands to Run

```bash
# Build all images
docker-compose build

# Start all services
docker-compose up -d

# Check logs
docker-compose logs -f

# Check specific service
docker-compose logs -f frontend
docker-compose logs -f backend
docker-compose logs -f mysql

# Stop all services
docker-compose down

# Remove volumes too (reset database)
docker-compose down -v
```

## Quick Verification Steps

```bash
# 1. Check if containers are running
docker-compose ps

# 2. Check if MySQL is accessible
docker-compose exec mysql mysql -u root -p singitronic_nextjs -e "SHOW TABLES;"

# 3. Check if backend is running
curl http://localhost:3001/health

# 4. Check frontend logs
docker-compose logs frontend | tail -50

# 5. Check if frontend is running
curl http://localhost:3000
```

## Common Issues & Quick Fixes

| Issue | Solution |
|-------|----------|
| Port already in use | `lsof -i :3000` then `kill -9 <PID>` |
| Database connection refused | Wait 30s for MySQL to be healthy |
| Prisma migration errors | `docker-compose exec backend npx prisma migrate reset` |
| Frontend blank page | Check browser console for API errors |
| Backend can't find database | Verify `DATABASE_URL` in `server/.env` |

## For Production

Never use:
- `volumes: .` mounts in docker-compose (for frontend/backend source)
- `npm run dev` in production
- Health checks without proper endpoints
- Hardcoded passwords (use Docker secrets)

Use proper production:
```yaml
  frontend:
    build: .
    command: ["npm", "start"]
    restart: always
```
