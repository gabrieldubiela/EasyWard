from fastapi import APIRouter, Depends, Response, Cookie
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.response import success_response
from app.core.exceptions import UnauthorizedError
from app.modules.auth.schemas import LoginRequest, LoginResponse
from app.modules.auth import service

router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/login")
async def login(
    request_data: LoginRequest,
    response: Response,
    db: AsyncSession = Depends(get_db),
):
    result = await service.login(
        request_data.email,
        request_data.password,
        db
    )
    
    # Coloca o refresh_token no cookie httpOnly
    response.set_cookie(
        key="refresh_token",
        value=result["refresh_token"],
        httponly=True,
        secure=True,         # apenas HTTPS
        samesite="strict",
        max_age=60 * 60 * 24 * 7,  # 7 dias em segundos
    )
    
    return success_response(
        data={
            "access_token": result["access_token"],
            "user": result["user"],
        },
        message="Login realizado com sucesso."
    )
    
@router.post("/logout")
async def logout(
    response: Response,
    refresh_token: str | None = Cookie(default=None),
    db: AsyncSession = Depends(get_db),
):
    if refresh_token:
        await service.logout(refresh_token, db)
    
    response.delete_cookie("refresh_token")
    return success_response(message="Logout realizado com sucesso.")

@router.post("/refresh")
async def refresh(
    response: Response,
    refresh_token: str | None = Cookie(default=None),
    db: AsyncSession = Depends(get_db),
):
    if not refresh_token:
        raise UnauthorizedError("Refresh token não encontrado.")
    
    result = await service.refresh_access_token(refresh_token, db)
    
    return success_response(
        data={"access_token": result["access_token"]},
        message="Token renovado com sucesso."
    )

