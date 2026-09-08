from fastapi import Depends, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from jose import jwt, JWTError

from app.core.config import settings
from app.core.database import get_db
from app.core.exceptions import UnauthorizedError, PermissionDeniedError

bearer_scheme = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Security(bearer_scheme),
    db: AsyncSession = Depends(get_db),
) -> dict:
    token = credentials.credentials
    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET,
            algorithms=[settings.JWT_ALGORITHM]
        )
        user_id = int(payload.get("sub"))
        ala_id = payload.get("ala_id")
    except (JWTError, TypeError, ValueError):
        raise UnauthorizedError("Token inválido ou expirado.")

    # Buscar usuário no banco
    result = await db.execute(
        text("""
            SELECT u.id, u.ala_id, u.ativo,
                    m.nome_completo,
                    COALESCE(
                        array_agg(up.permission_code)
                        FILTER (WHERE up.permission_code IS NOT NULL),
                        ARRAY[]::text[]
                    ) as permissions
            FROM usuarios u
            JOIN membros m ON m.id = u.membro_id
            LEFT JOIN user_permissions up ON up.user_id = u.id
            WHERE u.id = :user_id
            GROUP BY u.id, u.ala_id, u.ativo, m.nome_completo
        """),
        {"user_id": user_id}
    )
    user = result.mappings().first()

    if not user:
        raise UnauthorizedError("Usuário não encontrado.")
    if not user["ativo"]:
        raise UnauthorizedError("Usuário inativo.")

    return dict(user)

def require_permission(permission_code: str):
    async def checker(
        current_user: dict = Depends(get_current_user),
    ) -> dict:
        if permission_code not in current_user["permissions"]:
            raise PermissionDeniedError()
        return current_user
    return checker