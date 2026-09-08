from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text


async def get_states(db: AsyncSession) -> list[dict]:
    result = await db.execute(
        text("SELECT id, nome, sigla FROM estados ORDER BY nome")
    )
    return [dict(row) for row in result.mappings()]


async def get_stakes_by_state(estado_id: int, db: AsyncSession) -> list[dict]:
    result = await db.execute(
        text("""
            SELECT id, nome 
            FROM estacas 
            WHERE estado_id = :estado_id 
            ORDER BY nome
        """),
        {"estado_id": estado_id}
    )
    return [dict(row) for row in result.mappings()]


async def get_wards_by_stake(estaca_id: int, db: AsyncSession) -> list[dict]:
    result = await db.execute(
        text("""
            SELECT id, nome 
            FROM alas 
            WHERE estaca_id = :estaca_id 
            ORDER BY nome
        """),
        {"estaca_id": estaca_id}
    )
    return [dict(row) for row in result.mappings()]


async def create_stake(estado_id: int, nome: str, db: AsyncSession) -> dict:
    result = await db.execute(
        text("""
            INSERT INTO estacas (estado_id, nome)
            VALUES (:estado_id, :nome)
            RETURNING id, nome
        """),
        {"estado_id": estado_id, "nome": nome}
    )
    return dict(result.mappings().first())