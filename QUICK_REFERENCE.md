# E-Commerce Project - Quick Reference & Troubleshooting

## 🚀 Quick Start (TL;DR)

### Option 1: Docker Compose (Easiest) ⭐
```bash
cd /home/luffy/Documents/practice/ECOMMERCE/Ecommerce_k8s
docker-compose up
# Access: http://localhost:3000
```

### Option 2: Manual Setup
```bash
# Terminal 1: Backend
cd /home/luffy/Documents/practice/ECOMMERCE/Ecommerce_k8s/server
npm run dev

# Terminal 2: Frontend
cd /home/luffy/Documents/practice/ECOMMERCE/Ecommerce_k8s
npm run dev

# Terminal 3: Start MySQL
docker run -d --name mysql -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=navat \
  -e MYSQL_DATABASE=singitronic_nextjs \
  mysql:8.0
```

### Option 3: Automated Script
```bash
cd /home/luffy/Documents/practice/ECOMMERCE/Ecommerce_k8s
bash quick-start.sh
```

---

## 🔗 Access Points

| Service | URL | Credentials |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | - |
| Backend API | http://localhost:3001 | - |
| Database Admin | http://localhost:8080 | root / navat |
| Prisma Studio | `npm run db:studio` | - |

---

## 🛠️ Common Commands

### Project Commands
```bash
# Frontend
npm install               # Install dependencies
npm run dev              # Start dev server
npm run build            # Production build
npm start                # Start production server
npm run lint             # Run linter
npm run db:generate      # Generate Prisma client
npm run db:push          # Sync database
npm run db:studio        # Open database UI

# Backend
cd server
npm install              # Install dependencies
npm run dev              # Start with watch mode
npm start                # Start production
npm run logs             # View logs
npm run logs:access      # View access logs
npm run migrate:safe     # Safe database migration

# Database
npm run db:backup        # Backup database
npm run db:restore       # Restore from backup
```

### Docker Commands
```bash
# Start all services
docker-compose up

# Start in background
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Access MySQL container
docker exec -it ecommerce-mysql mysql -u root -pnavat

# Reset everything
docker-compose down -v
docker-compose up --build
```

### Database Commands
```bash
# Connect to MySQL
mysql -u root -pnavat -h localhost

# Create database
CREATE DATABASE singitronic_nextjs;

# Use database
USE singitronic_nextjs;

# Show tables
SHOW TABLES;

# View Prisma schema
npm run db:studio
```

---

## 🐛 Troubleshooting

### Issue: "Cannot find module 'next'"

**Solution:**
```bash
cd /home/luffy/Documents/practice/ECOMMERCE/Ecommerce_k8s
npm install
npm run db:generate
```

### Issue: "Error: connect ECONNREFUSED 127.0.0.1:3306"

**Solution:**
```bash
# Check MySQL status
docker ps | grep mysql

# Start MySQL if stopped
docker-compose up -d mysql

# Or if using local MySQL
sudo service mysql start  # Linux
brew services start mysql # macOS

# Test connection
mysql -u root -pnavat -e "SELECT 1"
```

### Issue: "Port 3000 already in use"

**Solution:**
```bash
# Find process using port
lsof -i :3000

# Kill the process
kill -9 <PID>

# Or use different port
PORT=3002 npm run dev
```

### Issue: "Port 3001 already in use"

**Solution:**
```bash
# Find process
lsof -i :3001

# Kill process
kill -9 <PID>

# Or use different port in server/.env
PORT=3002 npm run dev
```

### Issue: "Database migrations failed"

**Solution:**
```bash
# Ensure MySQL is running
docker-compose up -d mysql
sleep 5

# Generate Prisma client
npm run db:generate

# Push schema
npm run db:push

# If still fails, backup and reset
npm run migrate:backup
npx prisma migrate deploy
```

### Issue: "Prisma client not found"

**Solution:**
```bash
cd /home/luffy/Documents/practice/ECOMMERCE/Ecommerce_k8s
npm run db:generate
rm -rf node_modules/.prisma
npm install
npm run db:generate
```

### Issue: "CORS error - API not responding"

**Solution:**
```bash
# Check backend is running
lsof -i :3001

# Check environment variables
cat .env | grep NEXT_PUBLIC_API_BASE_URL
cat server/.env | grep CORS_ORIGIN

# Backend should have:
# CORS_ORIGIN=http://localhost:3000

# Frontend should have:
# NEXT_PUBLIC_API_BASE_URL=http://localhost:3001
```

### Issue: "NextAuth session error"

**Solution:**
```bash
# Check NEXTAUTH_SECRET and NEXTAUTH_URL in .env
NEXTAUTH_SECRET=12D16C923BA17672F89B18C1DB22A
NEXTAUTH_URL=http://localhost:3000

# Clear browser cookies and cache
# Then restart application
```

### Issue: "File upload fails"

**Solution:**
```bash
# Check disk space
df -h

# Verify upload directory exists
mkdir -p server/uploads

# Check file permissions
chmod 755 server/uploads

# Limit file size in .env if needed
MAX_FILE_SIZE=10485760  # 10MB
```

### Issue: "Docker container keeps restarting"

**Solution:**
```bash
# Check logs
docker-compose logs -f

# Rebuild container
docker-compose down
docker-compose build --no-cache
docker-compose up

# Or remove all and restart
docker-compose down -v
docker-compose up
```

### Issue: "Package installation fails"

**Solution:**
```bash
# Clear cache
npm cache clean --force

# Delete node_modules
rm -rf node_modules package-lock.json

# Reinstall
npm install

# For backend too
cd server && rm -rf node_modules package-lock.json && npm install && cd ..
```

---

## 📝 Environment Variables

### Frontend (.env)
```properties
# API Configuration
NEXT_PUBLIC_API_BASE_URL=http://localhost:3001

# Database
DATABASE_URL=mysql://root:navat@localhost:3306/singitronic_nextjs

# Environment
NODE_ENV=development

# NextAuth
NEXTAUTH_SECRET=12D16C923BA17672F89B18C1DB22A
NEXTAUTH_URL=http://localhost:3000
```

### Backend (server/.env)
```properties
# Database
DATABASE_URL=mysql://root:navat@localhost:3306/singitronic_nextjs

# Server
PORT=3001
NODE_ENV=development

# CORS
CORS_ORIGIN=http://localhost:3000

# File Upload
MAX_FILE_SIZE=10485760  # 10MB

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000  # 15 minutes
RATE_LIMIT_MAX_REQUESTS=10
```

---

## 🔍 Project Structure Quick Guide

```
Ecommerce_k8s/
├── app/                      # Next.js App Router
│   ├── (dashboard)/         # Admin dashboard
│   ├── api/                 # API routes
│   ├── cart/                # Shopping cart
│   ├── checkout/            # Checkout flow
│   ├── product/             # Product details
│   ├── shop/                # Shop pages
│   ├── search/              # Search functionality
│   └── layout.tsx           # Root layout
├── components/              # React components (50+)
├── server/                  # Express backend
│   ├── controllers/         # Request handlers
│   ├── routes/              # API routes
│   ├── middleware/          # Custom middleware
│   ├── services/            # Business logic
│   ├── scripts/             # DB utilities
│   └── app.js               # Express server
├── prisma/                  # Database
│   ├── schema.prisma        # Data models
│   └── migrations/          # DB migrations
├── public/                  # Static files
├── types/                   # TypeScript types
├── lib/                     # Utilities
├── hooks/                   # React hooks
├── utils/                   # Helper functions
├── .env                     # Frontend config
├── .env.local              # Local overrides (git ignored)
├── next.config.mjs         # Next.js config
├── tsconfig.json           # TypeScript config
├── tailwind.config.ts      # Tailwind config
├── docker-compose.yml      # Docker setup
└── Dockerfile              # Frontend container
```

---

## 📊 Key Metrics

| Metric | Value |
|--------|-------|
| Frontend Components | 50+ |
| API Endpoints | 20+ |
| Database Models | 10+ |
| Dependencies | 38 (frontend) + 15 (backend) |
| Test Cases | 350+ |
| Code Lines | ~10,000+ |
| Database Tables | 10 |
| Security Headers | 3+ |

---

## 🔐 Security Checklist

- ✅ SQL Injection Prevention (Prisma ORM)
- ✅ XSS Protection (DOMPurify)
- ✅ CSRF Tokens
- ✅ Password Hashing (bcryptjs)
- ✅ Rate Limiting
- ✅ CORS Configuration
- ✅ Security Headers (X-Frame-Options, etc.)
- ✅ Input Validation (Zod)
- ✅ Session Management (NextAuth)
- ✅ Role-Based Access Control

### Before Production
- ⚠️ Enable HTTPS/SSL
- ⚠️ Setup Web Application Firewall
- ⚠️ Enable 2FA
- ⚠️ Configure backup & recovery
- ⚠️ Setup monitoring & alerts
- ⚠️ Regular security audits

---

## 🎯 Development Workflow

### 1. Daily Startup
```bash
cd /home/luffy/Documents/practice/ECOMMERCE/Ecommerce_k8s

# Start all services
docker-compose up

# Or manually in 2 terminals:
# Terminal 1:
cd server && npm run dev

# Terminal 2:
npm run dev
```

### 2. Making Changes

#### Backend (Express)
```bash
# Edit server/app.js or controllers/
# Server auto-reloads with nodemon
# Test with curl or Postman
curl http://localhost:3001/api/products
```

#### Frontend (Next.js)
```bash
# Edit app/ or components/
# Page auto-reloads with HMR
# Changes visible at http://localhost:3000
```

#### Database (Prisma)
```bash
# Edit prisma/schema.prisma
npm run db:generate    # Update Prisma client
npm run db:push        # Apply schema changes
npm run db:studio      # Verify in UI
```

### 3. Testing Changes
```bash
# Build and test
npm run build

# Type checking
npx tsc --noEmit

# Lint check
npm run lint
```

---

## 🚀 Deployment Checklist

### Before Deployment
- ✅ Run tests: `npm run test`
- ✅ Build: `npm run build`
- ✅ Check for errors: `npm run lint`
- ✅ Review security settings
- ✅ Update environment variables
- ✅ Backup database
- ✅ Test in staging environment

### Deployment Options

#### Option 1: Docker Compose (VPS)
```bash
# Build images
docker-compose build

# Run services
docker-compose up -d

# Verify
docker-compose logs -f
```

#### Option 2: Kubernetes (k8s)
```bash
# Build images
docker build -t ecommerce-frontend:1.0 .
docker build -t ecommerce-backend:1.0 ./server

# Push to registry
docker push your-registry/ecommerce-frontend:1.0
docker push your-registry/ecommerce-backend:1.0

# Deploy
kubectl apply -f k8s/
```

#### Option 3: Cloud Platforms
- **Frontend:** Vercel, Netlify
- **Backend:** Railway, Render, Heroku
- **Database:** PlanetScale, AWS RDS

---

## 📞 Getting Help

### Documentation Files
- `LOCAL_SETUP_GUIDE.md` - Setup instructions
- `PROJECT_ANALYSIS.md` - Full analysis
- `README.md` - Project overview
- `verify-setup.sh` - Check environment
- `quick-start.sh` - Automated setup

### Common Resources
- Next.js Docs: https://nextjs.org/docs
- Prisma Docs: https://www.prisma.io/docs
- Express Docs: https://expressjs.com
- MySQL Docs: https://dev.mysql.com/doc
- Docker Docs: https://docs.docker.com

### Project GitHub
- Repository: [Electronics-eCommerce-Shop](https://github.com/Kuzma02/Electronics-eCommerce-Shop-With-Admin-Dashboard-NextJS-NodeJS)

---

## ✅ Setup Verification

Run this to verify everything is working:

```bash
cd /home/luffy/Documents/practice/ECOMMERCE/Ecommerce_k8s

# Check system
bash verify-setup.sh

# Expected output:
# ✓ Node.js installed: v22.21.0
# ✓ npm installed: 10.9.4
# ✓ Git installed
# ✓ Docker installed
# ✓ MySQL CLI installed
# ✓ MySQL connection successful
# ✓ Frontend package.json found
# ✓ Backend package.json found
# ✓ Frontend .env file found
# ✓ Backend .env file found
# ✓ Prisma schema found
# ✓ Frontend dependencies installed
# ✓ Backend dependencies installed
```

---

## 📈 Performance Tips

### Frontend
- Use Next.js Image for images
- Enable Incremental Static Regeneration (ISR)
- Use dynamic imports for large components
- Minimize bundle size
- Enable gzip compression

### Backend
- Use database indexes
- Implement caching (Redis)
- Use connection pooling
- Optimize queries with Prisma
- Enable compression middleware

### Database
- Regular backups
- Proper indexing
- Query optimization
- Regular maintenance
- Monitor performance

---

## 🎓 Learning Resources

### For Beginners
1. Learn React basics
2. Understand Next.js fundamentals
3. Learn TailwindCSS
4. Study databases

### For Intermediate
1. Study authentication (NextAuth)
2. Learn Prisma ORM
3. Understand state management (Zustand)
4. Learn Express.js basics

### For Advanced
1. System design patterns
2. Microservices architecture
3. DevOps & deployment
4. Performance optimization
5. Security best practices

---

## 🎯 Next Steps

1. ✅ Run `docker-compose up` to start all services
2. ✅ Access http://localhost:3000
3. ✅ Create a test account
4. ✅ Explore the admin dashboard
5. ✅ Make your first code change
6. ✅ Deploy to production when ready

---

**Last Updated:** February 13, 2026  
**Status:** Ready for Development ✅
