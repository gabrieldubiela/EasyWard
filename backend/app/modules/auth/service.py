from passlib.context import CryptContext
from jose import jwt
from datetime import datetime, timedelta, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
import hashlib
import secrets

from app.core.config import settings
from app.core.exceptions import UnauthorizedError

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)

def create_access_token(user_id: int, ala_id: int) -> str:
    expire = datetime.now(timezone.utc) + timedelta(
        minutes=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES
    )
    payload = {
        "sub": str(user_id),   # "sub" = subject, convenção JWT
        "ala_id": ala_id,
        "exp": expire,
    }
    return jwt.encode(payload, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)

def hash_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()

async def create_refresh_token(user_id: int, db: AsyncSession) -> str:
    # 1. Gerar token aleatório
    token = secrets.token_hex(32)
    
    # 2. Calcular expiração
    expires_at = datetime.now(timezone.utc) + timedelta(
        days=settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS
    )
    
    # 3. Hash do token
    token_hash = hash_token(token)
    
    # 4. Salvar no banco
    await db.execute(
        text("""
            INSERT INTO refresh_tokens (user_id, token_hash, expires_at)
            VALUES (:user_id, :token_hash, :expires_at)
        """),
        {"user_id": user_id, "token_hash": token_hash, "expires_at": expires_at}
    )
    
    # 5. Retornar o token original
    return token

async def get_user_by_email(email: str, db: AsyncSession) -> dict | None:
    result = await db.execute(
        text("""
            SELECT 
                u.id,
                u.senha,
                u.ativo,
                u.ala_id,
                m.nome_completo,
                COALESCE(
                    array_agg(up.permission_code) 
                    FILTER (WHERE up.permission_code IS NOT NULL),
                    ARRAY[]::text[]
                ) as permissions
            FROM usuarios u
            JOIN membros m ON m.id = u.membro_id
            LEFT JOIN user_permissions up ON up.user_id = u.id
            WHERE u.email = :email
            GROUP BY u.id, u.senha, u.ativo, u.ala_id, m.nome_completo
        """),
        {"email": email}
    )
    row = result.mappings().first()
    return dict(row) if row else None

async def login(email: str, password: str, db: AsyncSession) -> dict:
    # 1. Buscar usuário
    user = await get_user_by_email(email, db)
    
    # 2. Validar se existe e está ativo
    if not user:
        raise UnauthorizedError("E-mail ou senha inválidos.")
    if not user["ativo"]:
        raise UnauthorizedError("Usuário inativo.")
    
    # 3. Verificar senha
    if not verify_password(password, user["senha"]):
        raise UnauthorizedError("E-mail ou senha inválidos.")
    
    # 4. Gerar tokens
    access_token = create_access_token(user["id"], user["ala_id"])
    refresh_token = await create_refresh_token(user["id"], db)
    
    # 5. Retornar dados
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "user": {
            "id": user["id"],
            "name": user["nome_completo"],
            "ala_id": user["ala_id"],
            "permissions": user["permissions"],
        }
    }

async def logout(token: str, db: AsyncSession) -> None:
    await db.execute(
        text("""
            UPDATE refresh_tokens 
            SET revoked = TRUE
            WHERE token_hash = :token_hash
            AND revoked = FALSE
        """),
        {"token_hash": hash_token(token)}
    )

async def refresh_access_token(token: str, db: AsyncSession) -> dict:
    result = await db.execute(
        text("""
            SELECT user_id FROM refresh_tokens
            WHERE token_hash = :token_hash
            AND revoked = FALSE
            AND expires_at > NOW()
        """),
        {"token_hash": hash_token(token)}
    )
    row = result.mappings().first()
    
    if not row:
        raise UnauthorizedError("Refresh token inválido ou expirado.")
    
    # Buscar dados do usuário para gerar novo access token
    user = await db.execute(
        text("SELECT id, ala_id FROM usuarios WHERE id = :id"),
        {"id": row["user_id"]}
    )
    user_row = user.mappings().first()
    
    access_token = create_access_token(user_row["id"], user_row["ala_id"])
    return {"access_token": access_token}