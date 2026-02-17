# 📝 Full-Stack Todo Application

A modern, production-ready task management application built with Next.js, FastAPI, and PostgreSQL. Features secure JWT authentication, real-time optimistic updates, and a beautiful, accessible UI.

## ⚡ Quick Start (One Command)

```bash
# Install dependencies
npm run install:all

# Run both frontend and backend together
npm run dev
```

**That's it!** Frontend runs on http://localhost:3000, Backend on http://localhost:8000

---

## 🚀 Features

### Authentication & Security

- 🔐 Secure JWT-based authentication
- 🔒 Password hashing with bcrypt
- 👤 User isolation at all layers
- 🛡️ Protected API endpoints with middleware

### Task Management

- ✅ Create tasks with title and description
- 📋 View tasks organized by status (pending/completed)
- ✏️ Edit task details with modal interface
- 🔄 Toggle task completion status
- 🗑️ Delete tasks with confirmation dialog
- ⚡ Optimistic UI updates with automatic rollback

### User Experience

- 🎨 Modern, clean UI with Tailwind CSS
- 📱 Responsive design (mobile, tablet, desktop)
- ♿ Accessible components with ARIA attributes
- 🎯 Touch-friendly (44px minimum touch targets)
- 💫 Loading states and skeleton screens
- ❌ Comprehensive error handling with retry
- 🎭 Empty states with friendly messages

## 🛠️ Technology Stack

### Frontend

- **Framework**: Next.js 15.1.0 (App Router)
- **Language**: TypeScript 5.3.3
- **Styling**: Tailwind CSS 3.4.1
- **HTTP Client**: Axios 1.6.5
- **Authentication**: Better Auth 1.0.0

### Backend

- **Framework**: FastAPI 0.109.0
- **Language**: Python 3.11+
- **Database**: PostgreSQL
- **ORM**: SQLModel 0.0.14
- **Authentication**: JWT (python-jose)
- **Password Hashing**: Passlib with bcrypt
- **Migrations**: Alembic 1.13.1

## 📋 Prerequisites

- **Node.js**: 18.x or higher
- **Python**: 3.11 or higher
- **PostgreSQL**: 14.x or higher
- **npm** or **yarn**: Latest version

## 🚀 Getting Started

### Method 1: Quick Start (Recommended) ⚡

```bash
# 1. Install all dependencies
npm run install:all

# 2. Setup environment variables
cd backend && copy .env.example .env
cd ../frontend && copy .env.example .env.local

# 3. Run both frontend and backend together
npm run dev
```

**Done!** 🎉
- Frontend: http://localhost:3000
- Backend: http://localhost:8000
- API Docs: http://localhost:8000/docs

### Method 2: Manual Setup (Advanced)

#### Backend Setup

1. **Install Python Dependencies**
```bash
cd backend
pip install -r requirements.txt
```

2. **Configure Environment Variables**

Create `backend/.env`:
```env
DATABASE_URL=sqlite:///./todo.db
JWT_SECRET_KEY=your-secret-key-change-in-production
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
CORS_ORIGINS=http://localhost:3000
```

3. **Start Backend**
```bash
cd backend
uvicorn src.main:app --reload --port 8000
```

#### Frontend Setup

1. **Install Node Dependencies**
```bash
cd frontend
npm install
```

2. **Configure Environment Variables**

Create `frontend/.env.local`:
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_APP_NAME=Todo Application
```

3. **Start Frontend**
```bash
cd frontend
npm run dev
```

### Method 3: Docker (Production-Ready) 🐳

```bash
# Build and run with Docker Compose
docker-compose up --build

# Or use npm script
npm run docker:dev
```

## 📁 Project Structure

```
Phase_2/
├── backend/
│   ├── src/
│   │   ├── api/           # API route handlers
│   │   │   ├── auth.py    # Authentication endpoints
│   │   │   └── tasks.py   # Task CRUD endpoints
│   │   ├── models/        # Database models
│   │   │   ├── user.py    # User model
│   │   │   └── task.py    # Task model
│   │   ├── services/      # Business logic
│   │   │   ├── auth.py    # Auth utilities (JWT, password hashing)
│   │   │   └── tasks.py   # Task operations
│   │   ├── middleware/    # Custom middleware
│   │   │   └── jwt_auth.py # JWT verification
│   │   ├── database.py    # Database configuration
│   │   └── main.py        # FastAPI application
│   ├── alembic/           # Database migrations
│   ├── requirements.txt   # Python dependencies
│   └── .env.example       # Environment variables template
│
├── frontend/
│   ├── src/
│   │   ├── app/           # Next.js App Router pages
│   │   │   ├── sign-up/   # Sign-up page
│   │   │   ├── sign-in/   # Sign-in page
│   │   │   ├── dashboard/ # Main dashboard
│   │   │   ├── layout.tsx # Root layout
│   │   │   └── page.tsx   # Landing page
│   │   ├── components/    # React components
│   │   │   ├── ui/        # Reusable UI components
│   │   │   ├── tasks/     # Task-specific components
│   │   │   └── layouts/   # Layout components
│   │   ├── lib/           # Utilities and configurations
│   │   │   ├── api.ts     # API client with interceptors
│   │   │   ├── auth.ts    # Auth helpers
│   │   │   └── types.ts   # TypeScript types
│   │   └── styles/        # Global styles
│   ├── package.json       # Node dependencies
│   └── .env.example       # Environment variables template
│
└── specs/                 # Project documentation
    └── 001-todo-frontend/
        ├── spec.md        # Feature specifications
        ├── plan.md        # Implementation plan
        ├── tasks.md       # Task breakdown
        └── contracts/     # API contracts (OpenAPI)
```

## 🔌 API Endpoints

### Authentication

- `POST /api/auth/signup` - Create new user account
- `POST /api/auth/signin` - Authenticate existing user

### Tasks (Protected)

- `GET /api/tasks` - List all user tasks
- `POST /api/tasks` - Create new task
- `PUT /api/tasks/{id}` - Update task
- `DELETE /api/tasks/{id}` - Delete task

### System

- `GET /health` - Health check endpoint
- `GET /` - API information

## 🧪 Testing the Application

### Manual Testing Flow

1. **Sign Up**: Create a new account at `/sign-up`
2. **Sign In**: Log in with your credentials at `/sign-in`
3. **Create Task**: Add a new task from the dashboard
4. **Toggle Completion**: Mark tasks as complete/pending
5. **Edit Task**: Click edit button to modify task details
6. **Delete Task**: Click delete button and confirm deletion
7. **Sign Out**: Use the sign-out button in the header

### Testing Optimistic Updates

1. Create a task - it appears immediately
2. Toggle completion - status changes instantly
3. Edit a task - changes reflect immediately
4. Delete a task - it disappears right away
5. If any operation fails, changes automatically rollback

## 🎨 Design System

### Colors

- **Primary**: Blue (#2563EB)
- **Success**: Green (#10B981)
- **Error**: Red (#EF4444)
- **Warning**: Yellow (#F59E0B)
- **Neutral**: Gray scale

### Typography

- **Scale**: 12px, 14px, 16px, 20px, 24px, 32px
- **Font**: System font stack (antialiased)

### Spacing

- **Scale**: 4px, 8px, 12px, 16px, 24px, 32px, 48px, 64px

### Touch Targets

- **Minimum**: 44x44px for all interactive elements

## 🔒 Security Considerations

- Passwords are hashed using bcrypt before storage
- JWT tokens expire after 7 days (configurable)
- All task operations verify user ownership
- CORS is configured to allow only specified origins
- SQL injection protection via SQLModel ORM
- XSS protection via React's built-in escaping

## 🚀 Deployment

### Kubernetes Deployment (Phase 4) 🐳

**Production-ready cloud-native deployment with Docker and Kubernetes:**

#### Prerequisites
- Docker installed and running
- Kubernetes cluster (Minikube, Docker Desktop, or cloud provider)
- kubectl CLI installed and configured

#### Quick Deploy to Kubernetes

**Windows:**
```bash
deploy-k8s.bat
```

**Linux/Mac:**
```bash
chmod +x deploy-k8s.sh
./deploy-k8s.sh
```

#### Manual Kubernetes Deployment

1. **Build Docker Images:**
```bash
# Backend
cd backend
docker build -t phase4-backend:latest .

# Frontend
cd ../frontend
docker build -t phase4-frontend:latest .
```

2. **Configure Secrets:**
```bash
# Copy and edit secrets file
cp k8s/base/secrets.yaml.example k8s/base/secrets.yaml
# Edit k8s/base/secrets.yaml with your actual values
```

3. **Deploy to Kubernetes:**
```bash
# Apply all manifests
kubectl apply -f k8s/base/

# Or use Kustomize
kubectl apply -k k8s/base/
```

4. **Access the Application:**
```bash
# For Minikube
minikube service frontend-service -n todo-app

# For Docker Desktop
kubectl get service frontend-service -n todo-app
# Access via http://localhost:3000
```

**Features:**
- ✅ Multi-stage Docker builds for optimized images
- ✅ Health checks and readiness probes
- ✅ Resource limits and requests
- ✅ Non-root container users
- ✅ ConfigMaps and Secrets management
- ✅ Horizontal scaling ready
- ✅ LoadBalancer service for frontend

**See [k8s/README.md](k8s/README.md) for detailed Kubernetes deployment guide.**

---

### One-Command Deployment (Development)

**Windows:**
```bash
deploy.bat
```

**Linux/Mac:**
```bash
chmod +x deploy.sh
./deploy.sh
```

### Platform-Specific Deployment

#### Vercel (Recommended for Quick Deploy)
```bash
npm run deploy:vercel
```
- ✅ Automatic HTTPS & CDN
- ✅ Zero configuration
- ⚠️ Requires PostgreSQL (not SQLite)

#### Railway (Best for Full-Stack)
```bash
# Install Railway CLI
npm install -g @railway/cli

# Deploy
railway up
```
- ✅ Free PostgreSQL included
- ✅ No cold starts
- ✅ $5 free credit/month

#### Render (Free Database)
```bash
# Push to GitHub and connect in Render dashboard
```
- ✅ Free PostgreSQL
- ✅ Auto-deploy from Git
- ⚠️ Free tier sleeps after 15min

#### Docker (Any Platform)
```bash
docker-compose up --build -d
```
- ✅ Works anywhere
- ✅ Full control
- ✅ Production-ready

**📖 Detailed Guide:** See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)

## 📚 Documentation

### Quick References
- **Quick Start:** [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - Most used commands
- **Setup Guide:** [SETUP_COMPLETE.md](./SETUP_COMPLETE.md) - Complete setup instructions
- **Deployment:** [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) - Multi-platform deployment

### Specifications
- **Feature Specs**: `specs/001-todo-frontend/spec.md`
- **Implementation Plan**: `specs/001-todo-frontend/plan.md`
- **Task Breakdown**: `specs/001-todo-frontend/tasks.md`
- **API Contracts**: `specs/001-todo-frontend/contracts/`

### Additional Guides
- **Deployment Status**: [DEPLOYMENT_COMPLETE.md](./DEPLOYMENT_COMPLETE.md)
- **User Guide**: [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md)
- **Design System**: [UI_UX_IMPROVEMENTS.md](./UI_UX_IMPROVEMENTS.md)
- **Testing Report**: [TESTING_REPORT.md](./TESTING_REPORT.md)

## 🤝 Contributing

1. Follow the existing code style and conventions
2. Write clear commit messages
3. Test your changes thoroughly
4. Update documentation as needed

## 📝 License

This project is part of the Governor House Hackathon Q4.

## 🙏 Acknowledgments

Built with modern best practices following:

- Spec-Driven Development (SDD)
- Separation of Concerns
- Security by Design
- UI/UX Excellence
- Optimistic UI patterns

---

**Status**: ✅ MVP Complete (Phases 1-8 implemented)

For questions or issues, please refer to the project documentation:

- **Deployment Guide**: [Vercel Deployment Guide](./VERCEL_DEPLOYMENT_GUIDE.md)
- **User Guide**: [Quick Start Guide](./QUICK_START_GUIDE.md)
- **Design System**: [UI/UX Improvements](./UI_UX_IMPROVEMENTS.md)
- **Testing Report**: [Testing Report](./TESTING_REPORT.md)
- **Roadmap**: [Improvement Plan](./COMPREHENSIVE_IMPROVEMENT_PLAN.md)
- **Specifications**: See `specs/` directory
# Hackathon-Phase-2-Todo-Web
# Hackathon-Phase-2
# Hackathon-Phase-2-Todo-Web
