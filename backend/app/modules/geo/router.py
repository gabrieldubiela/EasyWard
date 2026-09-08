from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.response import success_response
from app.modules.geo import service

router = APIRouter(prefix="/geo", tags=["geo"])


@router.get("/states")
async def get_states(db: AsyncSession = Depends(get_db)):
    states = await service.get_states(db)
    return success_response(data=states)


@router.get("/states/{estado_id}/stakes")
async def get_stakes(estado_id: int, db: AsyncSession = Depends(get_db)):
    stakes = await service.get_stakes_by_state(estado_id, db)
    return success_response(data=stakes)


@router.get("/stakes/{estaca_id}/wards")
async def get_wards(estaca_id: int, db: AsyncSession = Depends(get_db)):
    wards = await service.get_wards_by_stake(estaca_id, db)
    return success_response(data=wards)