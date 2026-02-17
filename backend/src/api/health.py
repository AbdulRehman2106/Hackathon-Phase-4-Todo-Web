"""
Health check endpoints for Kubernetes probes
"""
from fastapi import APIRouter, status
from fastapi.responses import JSONResponse
from datetime import datetime
from sqlalchemy import text
from src.database import get_session

router = APIRouter()


@router.get("/health", status_code=status.HTTP_200_OK)
async def health_check():
    """
    Liveness probe endpoint
    Returns 200 OK if the FastAPI server is running

    Used by: Kubernetes liveness probe
    """
    return {
        "status": "healthy",
        "service": "todo-backend",
        "timestamp": datetime.utcnow().isoformat()
    }


@router.get("/ready", status_code=status.HTTP_200_OK)
async def readiness_check():
    """
    Readiness probe endpoint
    Returns 200 OK if the application is ready to serve traffic
    Checks database connection pool health

    Used by: Kubernetes readiness probe
    """
    try:
        # Check database connectivity
        db = next(get_session())

        # Simple query to verify database connection
        result = db.execute(text("SELECT 1"))
        result.fetchone()

        return {
            "status": "ready",
            "service": "todo-backend",
            "database": "connected",
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={
                "status": "not_ready",
                "service": "todo-backend",
                "database": "disconnected",
                "error": str(e),
                "timestamp": datetime.utcnow().isoformat()
            }
        )
