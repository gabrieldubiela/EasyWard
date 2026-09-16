from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db, check_db_connection
from app.core.response import success_response
from app.core.config import settings

router = APIRouter(tags=["health"])

@router.get("/health")
async def health_check(db: AsyncSession = Depends(get_db)):
    db_connected = await check_db_connection()
    return success_response(
        data={
            "status": "ok",
            "environment": settings.APP_ENV,
            "database": "connected" if db_connected else "disconnected",
        }
    )