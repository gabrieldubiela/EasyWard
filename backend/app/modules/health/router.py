from fastapi import APIRouter
from app.core.database import check_db_connection
from app.core.config import settings

router = APIRouter(tags=["health"])

@router.get("/health")
async def health_check():
    db_connected = await check_db_connection()
    return {
        "status": "ok",
        "environment": settings.APP_ENV,
        "database": "connected" if db_connected else "disconnected",
    }