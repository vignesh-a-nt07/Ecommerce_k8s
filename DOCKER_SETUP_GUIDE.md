# 🚀 Docker Compose - Step-by-Step Setup Guide

## 📋 Prerequisites Check

Before starting, verify you have:
- ✅ Docker installed: `docker --version`
- ✅ Docker Compose installed: `docker-compose --version`
- ✅ Ports available: 3000, 3001, 3306, 8080
- ✅ Minimum 4GB RAM available
- ✅ Internet connection (for pulling images)

## 🎯 Quick Start (5 minutes)

### Step 1: Navigate to Project
```bash
cd /home/luffy/Documents/practice/ECOMMERCE/Ecommerce_k8s
```

### Step 2: Build Images
```bash
docker-compose build
```
⏳ This will take 2-3 minutes the first time

**Expected output:**
```
Building mysql
Building backend  
Building frontend
Successfully built...
Successfully tagged...
```

### Step 3: Start Services
```bash
docker-compose up -d
```

**Expected output:**
```
Creating ecommerce-mysql ... done
Creating ecommerce-backend ... done
Creating ecommerce-frontend ... done
```

### Step 4: Verify Services
```bash
docker-compose ps
```

**Expected output:**
```
NAME                  STATUS              PORTS
ecommerce-mysql       Up 30s (healthy)    0.0.0.0:3306->3306/tcp
ecommerce-backend     Up 20s (healthy)    0.0.0.0:3001->3001/tcp
ecommerce-frontend    Up 10s              0.0.0.0:3000->3000/tcp
```

## 🌐 Access the Application

Open in your browser:

| Service | URL | Purpose |
|---------|-----|---------|
| **Frontend** | [http://localhost:3000](http://localhost:3000) | Main e-commerce app |
| **Backend API** | [http://localhost:3001](http://localhost:3001) | REST API |
| **PhpMyAdmin** | [http://localhost:8080](http://localhost:8080) | Database management |

**PhpMyAdmin Credentials:**
- Username: `root`
- Password: `navat`

## 📊 Understanding the Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Docker Network                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐      ┌──────────────┐  ┌──────────────┐  │
│  │  Frontend    │      │   Backend    │  │    MySQL     │  │
│  │  (Next.js)   │◄────►│  (Express)   │◄─┤  (Database)  │  │
│  │  Port 3000   │      │  Port 3001   │  │  Port 3306   │  │
│  └──────────────┘      └──────────────┘  └──────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │       PhpMyAdmin (Port 8080) - DB Management         │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 🔍 Monitoring & Debugging

### View All Logs
```bash
# Follow all logs in real-time
docker-compose logs -f

# View last 50 lines
docker-compose logs --tail=50

# Clear and start fresh
docker-compose logs --follow frontend
```

### View Specific Service Logs
```bash
# Frontend logs
docker-compose logs -f frontend

# Backend logs
docker-compose logs -f backend

# MySQL logs
docker-compose logs -f mysql
```

### Check Service Health
```bash
# Show status of all services
docker-compose ps

# Detailed health info
docker-compose ps -a

# Check MySQL health
docker-compose exec mysql mysql -u root -pnavat -e "SELECT 1;"

# Check if backend is responding
docker-compose exec frontend curl http://backend:3001/api/health
```

## 🛠️ Common Operations

### View Application Files
```bash
# List files in frontend container
docker-compose exec frontend ls -la

# View Next.js config
docker-compose exec frontend cat next.config.mjs

# View Prisma schema
docker-compose exec backend cat prisma/schema.prisma
```

### Run Database Queries
```bash
# Connect to MySQL CLI
docker-compose exec mysql mysql -u root -pnavat singitronic_nextjs

# Common queries:
# SHOW TABLES;
# SELECT * FROM users;
# SELECT COUNT(*) FROM products;
```

### Restart Services
```bash
# Restart all
docker-compose restart

# Restart specific service
docker-compose restart frontend
docker-compose restart backend
docker-compose restart mysql
```

### View Resource Usage
```bash
# Real-time resource usage
docker stats

# Specific container
docker stats ecommerce-frontend
```

## 🚨 Troubleshooting

### Problem: "Port already in use"

**Error message:**
```
ERROR: for ecommerce-frontend Cannot start service frontend: 
driver failed programming external connectivity on endpoint
```

**Solution:**
```bash
# Find what's using port 3000
lsof -i :3000

# Kill the process (replace PID with actual number)
kill -9 <PID>

# Or change port in docker-compose.yml
# ports:
#   - "3002:3000"  # Use 3002 instead
```

### Problem: "Database connection refused"

**Error message:**
```
Error: connect ECONNREFUSED 127.0.0.1:3306
```

**Solution:**
```bash
# Check MySQL is running and healthy
docker-compose ps | grep mysql

# If not healthy, restart it
docker-compose restart mysql

# Wait 30 seconds for it to be ready
sleep 30

# Verify connection
docker-compose exec mysql mysql -u root -pnavat -e "SELECT 1;"
```

### Problem: "Frontend can't reach backend"

**Error message:**
```
Failed to fetch from http://localhost:3001
```

**Solution:**
```bash
# Inside frontend, try to reach backend
docker-compose exec frontend curl http://backend:3001

# Check backend logs for errors
docker-compose logs backend | tail -50

# Verify backend is healthy
docker-compose ps | grep backend
```

### Problem: "Docker image build fails"

**Error message:**
```
ERROR: Service backend failed to build
```

**Solution:**
```bash
# Rebuild without cache
docker-compose build --no-cache

# Or rebuild specific service
docker-compose build --no-cache backend

# Check Docker disk space
docker system df

# Clean up old images
docker system prune -f
```

### Problem: "Changes don't take effect"

**Solution:**
```bash
# Rebuild and restart
docker-compose down
docker-compose build
docker-compose up -d

# Or for development changes (volumes are mounted):
# Just restart the service
docker-compose restart frontend
```

## 🧹 Cleanup Operations

### Stop Services (keep data)
```bash
docker-compose stop
```

### Stop & Remove Containers (keep data)
```bash
docker-compose down
```

### Stop & Remove Everything (including database!)
```bash
docker-compose down -v
```

### Remove Unused Docker Objects
```bash
# Remove dangling images
docker image prune -f

# Remove all stopped containers
docker container prune -f

# Remove dangling volumes
docker volume prune -f

# Complete cleanup (safe)
docker system prune -f

# Complete cleanup (aggressive - removes all unused)
docker system prune -a -f
```

## 📈 Performance Optimization

### Reduce Memory Usage
Add to `docker-compose.yml` services:
```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'      # Use 50% of one CPU
      memory: 512M     # Limit to 512MB
    reservations:
      cpus: '0.25'
      memory: 256M
```

### Speed Up Builds
```bash
# Use BuildKit (faster builds)
export DOCKER_BUILDKIT=1
docker-compose build

# Cache layers
# Don't add volumes for production builds
```

## 🔐 Security Notes

### Don't Commit These Files
```bash
# Add to .gitignore
echo ".env*" >> .gitignore
echo "docker-compose.override.yml" >> .gitignore
```

### Change Default Passwords
Edit `docker-compose.yml` and `server/.env`:
- Change `MYSQL_PASSWORD` from `navat` to something strong
- Change `NEXTAUTH_SECRET` to a secure value
- Change `MYSQL_ROOT_PASSWORD`

### Use Environment Files (Production)
```bash
# Create .env.production
docker-compose --env-file .env.production up -d
```

## 📚 Useful Resources

| Resource | Link |
|----------|------|
| Docker Docs | https://docs.docker.com |
| Docker Compose Docs | https://docs.docker.com/compose |
| Dockerfile Reference | https://docs.docker.com/engine/reference/builder |
| Compose File Spec | https://docs.docker.com/compose/compose-file |

## ✅ Verification Checklist

Before considering setup complete:

- [ ] All three containers running: `docker-compose ps`
- [ ] MySQL is healthy (green status)
- [ ] Backend is healthy (green status)
- [ ] Frontend is running
- [ ] Can access http://localhost:3000
- [ ] Can access http://localhost:3001
- [ ] Can access http://localhost:8080
- [ ] Database is accessible from backend
- [ ] No errors in logs: `docker-compose logs | grep -i error`

## 🎓 Next Steps

1. **Explore the Admin Dashboard**
   - Login with admin credentials
   - Check product management
   - View orders

2. **Test API Endpoints**
   ```bash
   # Test health
   curl http://localhost:3001/api/health
   
   # Test products
   curl http://localhost:3001/api/products
   ```

3. **Set Up Database Backups**
   ```bash
   docker-compose exec mysql mysqldump -u root -pnavat singitronic_nextjs > backup.sql
   ```

4. **Configure for Development**
   - Add your IDE to VS Code
   - Set up hot reload
   - Configure debugger

## 📞 Need Help?

If something doesn't work:

1. Check the error in logs: `docker-compose logs`
2. Read `DOCKER_COMPOSE_ISSUES.md` for detailed solutions
3. Consult `DOCKER_COMMANDS_REFERENCE.md` for all commands
4. Try complete reset: `docker-compose down -v && docker-compose up -d`

---

**Happy coding! 🚀**
