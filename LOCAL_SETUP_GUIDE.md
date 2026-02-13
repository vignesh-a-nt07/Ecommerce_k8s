# E-Commerce Project - Local Setup & Analysis Guide

## Project Overview

**Project Name:** Electronics eCommerce Shop With Admin Dashboard  
**Tech Stack:** Next.js 15, Node.js, MySQL, Prisma ORM, TypeScript  
**Architecture:** Monorepo with Frontend (Next.js) and Backend (Express)  
**Current Node Version:** v22.21.0  
**Current npm Version:** 10.9.4  

### Key Features
- 🛒 Full E-Commerce Store with product catalog
- 🛡️ Admin Dashboard for management
- 👤 User Authentication (NextAuth)
- 🛍️ Shopping Cart & Wishlist functionality
- 📦 Bulk Upload management for products
- 📊 Analytics & Order management
- 🎨 Responsive design with TailwindCSS & DaisyUI
- 🔐 Security headers (X-Frame-Options, XSS Protection, etc.)

---

## Project Structure

```
Ecommerce_k8s/
├── app/                    # Next.js Frontend Application
│   ├── (dashboard)/       # Admin Dashboard routes
│   ├── api/               # API routes
│   ├── actions/           # Server actions
│   ├── cart/              # Cart pages
│   ├── checkout/          # Checkout flow
│   ├── product/           # Product pages
│   ├── shop/              # Shop pages
│   └── search/            # Search functionality
├── components/            # React Components
│   ├── modules/           # Feature modules
│   └── index.ts           # Component exports
├── server/                # Express Backend
│   ├── controllers/       # Request handlers
│   ├── routes/            # API routes
│   ├── middleware/        # Custom middleware
│   ├── services/          # Business logic
│   ├── scripts/           # Database scripts
│   └── app.js             # Express entry point
├── prisma/                # Database
│   ├── schema.prisma      # Data models
│   └── migrations/        # Database migrations
├── public/                # Static assets
├── types/                 # TypeScript types
├── lib/                   # Utility libraries
├── hooks/                 # React hooks
├── utils/                 # Helper functions
└── middleware.ts          # Next.js middleware
```

---

## Technology Stack

### Frontend (Next.js)
- **Framework:** Next.js 15.5.3
- **UI Library:** React 18.3.1
- **Styling:** TailwindCSS 3.3.0, DaisyUI 4.7.2
- **Authentication:** NextAuth 4.24.11
- **State Management:** Zustand 4.5.1
- **Charts:** React ApexCharts 1.4.1
- **Icons:** React Icons 5.0.1
- **Carousel:** React Slick 0.30.2
- **Validation:** Zod 3.22.4
- **Notifications:** React Hot Toast 2.4.1
- **Utilities:** date-fns, dompurify, nanoid

### Backend (Express)
- **Runtime:** Node.js 18+
- **Framework:** Express 4.18.3
- **Database ORM:** Prisma 6.16.1
- **Authentication:** bcryptjs 2.4.3
- **Rate Limiting:** express-rate-limit 8.1.0
- **File Upload:** express-fileupload 1.5.0
- **Logging:** Winston 3.8.2
- **CSV Processing:** csv-parse 5.6.0
- **HTTP Client:** Axios 1.12.1

### Database
- **Type:** MySQL
- **ORM:** Prisma
- **Schema:** Multi-model with relations (Products, Users, Orders, Categories, etc.)

---

## Prerequisites

✅ **Already Installed:**
- Node.js v22.21.0
- npm 10.9.4

⚠️ **Still Need:**
- MySQL Server (local or Docker)
- Git (optional, if you haven't cloned the repo)

---

## Local Setup Instructions

### Step 1: Navigate to Project Directory

```bash
cd /home/luffy/Documents/practice/ECOMMERCE/Ecommerce_k8s
```

### Step 2: Install Dependencies

#### Frontend Dependencies
```bash
npm install
```

#### Backend Dependencies
```bash
cd server
npm install
cd ..
```

### Step 3: Setup MySQL Database

#### Option A: Using Local MySQL (If Already Installed)

```bash
# Create the database
mysql -u root -p -e "CREATE DATABASE singitronic_nextjs;"

# Verify creation
mysql -u root -p -e "SHOW DATABASES;"
```

#### Option B: Using Docker (Recommended)

```bash
# Pull MySQL image
docker pull mysql:8.0

# Run MySQL container
docker run --name ecommerce-mysql \
  -e MYSQL_ROOT_PASSWORD=navat \
  -e MYSQL_DATABASE=singitronic_nextjs \
  -p 3306:3306 \
  -d mysql:8.0
```

**Verify the connection:**
```bash
docker ps  # Check if container is running
```

### Step 4: Setup Environment Variables

The project already has `.env` files, but verify/update them:

#### Frontend `.env` file (already configured):
```properties
NEXT_PUBLIC_API_BASE_URL=http://localhost:3001
NODE_ENV=development
DATABASE_URL="mysql://root:navat@localhost:3306/singitronic_nextjs?sslmode=disabled"
NEXTAUTH_SECRET=12D16C923BA17672F89B18C1DB22A
NEXTAUTH_URL=http://localhost:3000
```

#### Backend `server/.env` file:
```properties
DATABASE_URL=mysql://root:navat@localhost:3306/singitronic_nextjs
NODE_ENV=development
PORT=3001
CORS_ORIGIN=http://localhost:3000
```

### Step 5: Setup Prisma Database

```bash
# Generate Prisma client
npm run db:generate

# Run migrations
npm run db:push

# (Optional) Open Prisma Studio for visual database management
npm run db:studio
```

### Step 6: (Optional) Seed Demo Data

```bash
cd server
npm run migrate:backup  # Backup database first
cd ..

# Insert demo data if available
node utils/insertDemoData.js
```

---

## Running the Application

### Development Mode

#### Terminal 1: Start Backend Server
```bash
cd server
npm run dev
# Backend will run on http://localhost:3001
```

#### Terminal 2: Start Frontend (Next.js)
```bash
npm run dev
# Frontend will run on http://localhost:3000
```

### Production Mode

#### Build
```bash
# Frontend
npm run build

# Backend doesn't require build (Node.js)
```

#### Start
```bash
# Terminal 1: Start Backend
cd server
npm start

# Terminal 2: Start Frontend
npm start
```

---

## Using Docker Compose (Alternative)

Create a `docker-compose.yml` if you want containerized setup:

```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: navat
      MYSQL_DATABASE: singitronic_nextjs
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql

  backend:
    build: ./server
    ports:
      - "3001:3001"
    depends_on:
      - mysql
    environment:
      DATABASE_URL: mysql://root:navat@mysql:3306/singitronic_nextjs
      NODE_ENV: development

  frontend:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - backend
    environment:
      NEXT_PUBLIC_API_BASE_URL: http://backend:3001

volumes:
  mysql_data:
```

Run with:
```bash
docker-compose up
```

---

## Available Scripts

### Frontend Scripts
```bash
npm run dev              # Start development server
npm run build            # Build for production
npm start                # Start production server
npm run lint             # Run ESLint
npm run db:generate      # Generate Prisma client
npm run db:push          # Push schema to database
npm run db:studio        # Open Prisma Studio
```

### Backend Scripts
```bash
cd server
npm run dev              # Start with nodemon (watch mode)
npm start                # Start production server
npm run logs             # View all logs
npm run logs:access      # View access logs
npm run logs:error       # View error logs
npm run logs:security    # View security logs
npm run migrate:validate # Validate migrations
npm run migrate:backup   # Backup database
npm run migrate:safe     # Safe migration
npm run db:backup        # Backup database
npm run db:restore       # Restore database
```

---

## Database Schema Overview

### Key Models
1. **User** - Authentication & user profiles
2. **Product** - Product catalog with pricing, stock
3. **Category** - Product categories
4. **Customer_order** - Orders with customer details
5. **customer_order_product** - Order line items
6. **Wishlist** - User wishlist items
7. **Image** - Product images
8. **Notification** - User notifications
9. **Merchant** - Merchant/seller accounts
10. **bulk_upload_batch** - Bulk upload management

---

## Troubleshooting

### Issue: Database Connection Error

**Solution:**
```bash
# Check if MySQL is running
mysql -u root -p -e "SELECT 1"

# If using Docker, verify container
docker ps | grep mysql

# Restart MySQL
docker restart ecommerce-mysql
```

### Issue: Port Already in Use

```bash
# Find process using port
lsof -i :3000
lsof -i :3001

# Kill process
kill -9 <PID>
```

### Issue: Prisma Client Generation Error

```bash
# Regenerate Prisma client
npm run db:generate

# Clear cache and reinstall
rm -rf node_modules .next
npm install
npm run db:generate
```

### Issue: Missing Environment Variables

Ensure both `.env` files exist:
- `/home/luffy/Documents/practice/ECOMMERCE/Ecommerce_k8s/.env`
- `/home/luffy/Documents/practice/ECOMMERCE/Ecommerce_k8s/server/.env`

---

## Key Features & Functionality

### 🛍️ Shopping
- Browse products with filtering & search
- Product details with images & ratings
- Add to cart functionality
- Wishlist feature
- Checkout process
- Order history

### 🔐 Authentication
- User registration & login
- NextAuth session management
- Role-based access (admin/user)
- Secure password hashing

### 👨‍💼 Admin Dashboard
- Product management
- Order management
- User management
- Bulk upload products
- Analytics & reports
- Notification system

### 📦 Bulk Operations
- Bulk product upload (CSV)
- Bulk delete operations
- Upload history tracking
- Error handling & validation

### 🔒 Security Features
- CORS enabled
- Rate limiting on API
- SQL injection prevention (Prisma)
- XSS protection headers
- Frame options headers
- Input sanitization

---

## Testing

The project includes:
- 350+ manual test cases documented
- Unit testing with black box & white box methods
- Integration testing
- End-to-end testing
- Error tracking & reporting

Access test documentation in the root directory.

---

## Performance Considerations

- Use `npm run build` for production optimization
- Enable caching with Next.js ISR
- Database query optimization via Prisma
- Rate limiting to prevent abuse
- Image optimization via Next.js Image component

---

## Support & Resources

- **GitHub Repo:** [Electronics-eCommerce-Shop](https://github.com/Kuzma02/Electronics-eCommerce-Shop-With-Admin-Dashboard-NextJS-NodeJS)
- **Next.js Docs:** https://nextjs.org/docs
- **Prisma Docs:** https://www.prisma.io/docs
- **NextAuth Docs:** https://next-auth.js.org

---

## Next Steps

1. ✅ Install dependencies
2. ✅ Setup MySQL database
3. ✅ Configure environment variables
4. ✅ Run migrations
5. ✅ Start backend & frontend
6. ✅ Access application at http://localhost:3000
7. ✅ Login to admin dashboard for management

---

**Last Updated:** February 13, 2026  
**Project Status:** Ready for Local Development
