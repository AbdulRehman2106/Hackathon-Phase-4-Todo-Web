from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Configure logging first
from src.config.logging import setup_logging
setup_logging()

# Create FastAPI application
app = FastAPI(
    title="Todo Application API with AI Chatbot",
    description="Backend API for Todo application with JWT authentication and AI-powered conversational task management",
    version="2.0.0",
)

# CORS Configuration
CORS_ORIGINS = os.getenv("CORS_ORIGINS", "http://localhost:3000,http://localhost:3001,http://localhost:3002,http://localhost:3003,http://localhost:3004,http://localhost:3005").split(",")

# Configure CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    allow_headers=["*"],
    expose_headers=["*"],
    max_age=3600,
)

# Initialize database tables on startup
from src.database import create_db_and_tables

@app.on_event("startup")
def on_startup():
    """Initialize database tables and MCP server on application startup."""
    try:
        create_db_and_tables()
    except Exception as e:
        print(f"Warning: Could not initialize database tables: {e}")
        # Continue anyway - tables might already exist

    # Initialize MCP server with tools
    try:
        from src.mcp.server import mcp_server
        from src.mcp.tools import register_all_tools  # This triggers tool registration
        print(f"MCP Server initialized: {mcp_server.name} v{mcp_server.version}")
        print(f"Registered tools: {len(mcp_server.tools)}")
    except Exception as e:
        print(f"Warning: Could not initialize MCP server: {e}")

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint with API information."""
    return {
        "message": "Todo Application API",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health"
    }

# Router registration
from src.api import auth, tasks, subtasks, password_reset, chat, health
# AI router temporarily disabled due to Vercel size constraints
# from src.api import ai

# Health check endpoints (no prefix for Kubernetes probes)
app.include_router(health.router, tags=["Health"])

app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(password_reset.router, prefix="/api/auth", tags=["Password Reset"])
app.include_router(tasks.router, prefix="/api/tasks", tags=["Tasks"])
app.include_router(subtasks.router, prefix="/api", tags=["Subtasks"])
app.include_router(chat.router, prefix="/api/v1", tags=["AI Chat"])
# app.include_router(ai.router, prefix="/api/ai", tags=["AI Features"])
