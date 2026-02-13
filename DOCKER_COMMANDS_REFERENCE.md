# Docker Compose Quick Reference

## 🔧 Basic Commands

### Build Images
```bash
# Build all images
docker-compose build

# Build specific service
docker-compose build frontend
docker-compose build backend
docker-compose build mysql

# Build without cache (force rebuild)
docker-compose build --no-cache
```

### Start & Stop Services
```bash
# Start all services in background
docker-compose up -d

# Start all services with logs in foreground
docker-compose up

# Stop all services (keeps containers)
docker-compose stop

# Start stopped services
docker-compose start

# Stop and remove containers
docker-compose down

# Stop, remove containers AND volumes (reset database)
docker-compose down -v
```

### View Status & Logs
```bash
# Show running containers
docker-compose ps

# Show all containers (including stopped)
docker-compose ps -a

# View logs from all services
docker-compose logs

# View logs from specific service
docker-compose logs frontend
docker-compose logs backend
docker-compose logs mysql

# Follow logs in real-time
docker-compose logs -f

# Follow specific service
docker-compose logs -f frontend

# View last 50 lines
docker-compose logs --tail=50

# View logs with timestamps
docker-compose logs --timestamps
```

## 🔍 Inspection & Debugging

### Access Container Shell
```bash
# Access frontend container
docker-compose exec frontend sh

# Access backend container
docker-compose exec backend sh

# Access MySQL container
docker-compose exec mysql bash
```

### Check Service Health
```bash
# Check if services are healthy
docker-compose ps

# Check MySQL connection
docker-compose exec mysql mysql -u root -pnavat -e "SELECT 1;"

# Check backend health
docker-compose exec frontend curl http://backend:3001/api/health

# Check if port is listening
docker-compose exec backend wget -q -O- http://localhost:3001
```

### Access Databases
```bash
# Connect to MySQL
docker-compose exec mysql mysql -u root -pnavat singitronic_nextjs

# View all databases
docker-compose exec mysql mysql -u root -pnavat -e "SHOW DATABASES;"

# View all tables
docker-compose exec mysql mysql -u root -pnavat singitronic_nextjs -e "SHOW TABLES;"

# Run SQL query
docker-compose exec mysql mysql -u root -pnavat singitronic_nextjs -e "SELECT * FROM users LIMIT 5;"

# Backup database
docker-compose exec mysql mysqldump -u root -pnavat singitronic_nextjs > backup.sql

# Restore database
docker-compose exec -T mysql mysql -u root -pnavat singitronic_nextjs < backup.sql
```

## 🛠️ Running Commands in Containers

### Frontend (Next.js)
```bash
# View frontend logs
docker-compose logs -f frontend

# Restart frontend
docker-compose restart frontend

# Run prisma commands
docker-compose exec frontend npx prisma generate
docker-compose exec frontend npx prisma db push
docker-compose exec frontend npx prisma studio

# Access frontend shell
docker-compose exec frontend sh
```

### Backend (Express)
```bash
# View backend logs
docker-compose logs -f backend

# Restart backend
docker-compose restart backend

# Run prisma commands
docker-compose exec backend npx prisma generate
docker-compose exec backend npx prisma migrate deploy

# View application logs
docker-compose exec backend npm run logs
docker-compose exec backend npm run logs:error

# Access backend shell
docker-compose exec backend sh
```

### MySQL
```bash
# View MySQL logs
docker-compose logs -f mysql

# Restart MySQL
docker-compose restart mysql

# Create new user
docker-compose exec mysql mysql -u root -pnavat -e "CREATE USER 'newuser'@'%' IDENTIFIED BY 'password';"

# Grant privileges
docker-compose exec mysql mysql -u root -pnavat -e "GRANT ALL PRIVILEGES ON *.* TO 'newuser'@'%'; FLUSH PRIVILEGES;"
```

## 🚨 Troubleshooting

### Port Conflicts
```bash
# Check what's using port 3000
lsof -i :3000

# Check what's using port 3001
lsof -i :3001

# Check what's using port 3306
lsof -i :3306

# Kill process using port (replace PID)
kill -9 <PID>
```

### Clean Up & Reset
```bash
# Remove all stopped containers
docker-compose down

# Remove images
docker-compose down --rmi all

# Remove everything including volumes
docker-compose down -v

# Prune system (removes dangling images)
docker system prune -f

# Prune everything (WARNING: removes all unused Docker objects)
docker system prune -a -f
```

### Rebuild After Code Changes
```bash
# Option 1: Rebuild and restart (recommended)
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Option 2: Rebuild without stopping (faster for small changes)
docker-compose build
docker-compose up -d
```

### Database Issues
```bash
# Reset database (delete all data)
docker-compose down -v
docker-compose up -d

# Backup current database
docker-compose exec mysql mysqldump -u root -pnavat singitronic_nextjs > backup_$(date +%Y%m%d_%H%M%S).sql

# Check database size
docker-compose exec mysql mysql -u root -pnavat -e "SELECT table_name, ROUND(((data_length + index_length) / 1024 / 1024), 2) as size_mb FROM information_schema.tables WHERE table_schema = 'singitronic_nextjs';"
```

## 📊 Monitoring

### View Resource Usage
```bash
# Check container resource usage
docker stats ecommerce-frontend
docker stats ecommerce-backend
docker stats ecommerce-mysql

# All containers
docker stats
```

### Check Networks
```bash
# List networks
docker network ls

# Inspect network
docker network inspect ecommerce-network

# Test connectivity between containers
docker-compose exec frontend ping backend
docker-compose exec backend ping mysql
```

## 🔐 Security Tips

```bash
# Don't commit sensitive files
echo ".env" >> .gitignore
echo ".env.local" >> .gitignore

# Use environment files
docker-compose --env-file .env.production up -d

# Limit container resources
# Add to docker-compose.yml:
# deploy:
#   resources:
#     limits:
#       cpus: '1'
#       memory: 512M
```

## 📝 Useful Service URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | - |
| Backend API | http://localhost:3001 | - |
| PhpMyAdmin | http://localhost:8080 | root / navat |
| MySQL | localhost:3306 | root / navat |

## ⚡ Quick Start Commands

```bash
# Full setup from scratch
docker-compose down -v          # Clean everything
docker-compose build            # Build images
docker-compose up -d            # Start services
docker-compose logs -f          # View logs

# Quick restart
docker-compose restart

# View status
docker-compose ps

# Tail logs
docker-compose logs -f --tail=50
```

## 🐛 Debug Mode

### Enable Debug Logging
```bash
# Increase verbosity
docker-compose --verbose up -d

# View full container output
docker-compose logs --no-color > full-logs.txt

# View specific error
docker-compose logs | grep -i error
docker-compose logs | grep -i failed
```

### Common Error Messages

| Error | Solution |
|-------|----------|
| `Connection refused` | Wait for MySQL to start, check port 3306 |
| `Can't connect to database` | Verify DATABASE_URL in server/.env |
| `Frontend can't reach backend` | Check NEXT_PUBLIC_API_BASE_URL in docker-compose.yml |
| `Port already in use` | Kill existing process using the port |
| `Prisma migration failed` | `docker-compose exec backend npx prisma db push` |
| `Module not found` | `docker-compose build --no-cache && docker-compose up -d` |
