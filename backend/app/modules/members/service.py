from datetime import date
from math import ceil

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import BusinessRuleError, ConflictError, NotFoundError
from app.modules.members.schemas import MemberCreate, MemberUpdate

COLUNAS = """
    id, ala_id, organizacao_id, nome_completo, sexo, cargo, aniversario,
    familia_id, grupo_limpeza_id, chamado_id, data_inicio_chamado,
    apto_trocar_chamado, data_ultimo_discurso, mes_recomendacao,
    apto_recomendacao, ativo
"""


async def calcular_organizacao(
    ala_id: int,
    sexo: str | None,
    aniversario: date | None,
    db: AsyncSession,
) -> int | None:
    # RN-035: sem aniversário ou sem sexo definido, a atribuição é manual
    if aniversario is None or sexo not in ("masculino", "feminino"):
        return None

    idade_no_ano = date.today().year - aniversario.year

    result = await db.execute(
        text("""
            SELECT o.id
            FROM organizacoes o
            JOIN tipos_organizacao t ON t.id = o.tipo_organizacao_id
            WHERE o.ala_id = :ala_id
              AND t.nome = 'principal'
              AND o.ativo = TRUE
              AND (o.sexo_alvo IS NULL OR o.sexo_alvo = :sexo)
              AND o.idade_min <= :idade
              AND (o.idade_max IS NULL OR o.idade_max >= :idade)
            ORDER BY o.id
            LIMIT 1
        """),
        {"ala_id": ala_id, "sexo": sexo, "idade": idade_no_ano},
    )
    return result.scalar_one_or_none()


async def garantir_nome_unico(
    ala_id: int,
    nome: str,
    db: AsyncSession,
    ignorar_id: int | None = None,
) -> None:
    result = await db.execute(
        text("""
            SELECT id FROM membros
            WHERE ala_id = :ala_id
              AND ativo = TRUE
              AND LOWER(nome_completo) = LOWER(:nome)
              AND (CAST(:ignorar_id AS INT) IS NULL OR id <> :ignorar_id)
        """),
        {"ala_id": ala_id, "nome": nome, "ignorar_id": ignorar_id},
    )
    if result.first():
        raise ConflictError("Já existe um membro ativo com esse nome nesta ala.")


VINCULOS = {
    "familia_id": "SELECT 1 FROM familias WHERE id = :id AND ala_id = :ala_id",
    "grupo_limpeza_id": "SELECT 1 FROM grupos_limpeza WHERE id = :id AND ala_id = :ala_id",
    # chamados globais têm ala_id NULL e valem para todas as alas
    "chamado_id": "SELECT 1 FROM chamados WHERE id = :id AND (ala_id = :ala_id OR ala_id IS NULL)",
}


async def validar_vinculos(campos: dict, ala_id: int, db: AsyncSession) -> None:
    for campo, sql in VINCULOS.items():
        valor = campos.get(campo)
        if valor is None:
            continue
        result = await db.execute(text(sql), {"id": valor, "ala_id": ala_id})
        if not result.first():
            raise BusinessRuleError(f"O valor informado em {campo} não existe nesta ala.")


async def create_member(data: MemberCreate, ala_id: int, db: AsyncSession) -> dict:
    await garantir_nome_unico(ala_id, data.nome_completo, db)
    await validar_vinculos(data.model_dump(), ala_id, db)
    organizacao_id = await calcular_organizacao(
        ala_id, data.sexo, data.aniversario, db
    )

    result = await db.execute(
        text(f"""
            INSERT INTO membros (
                ala_id, organizacao_id, nome_completo, sexo, cargo, aniversario,
                familia_id, grupo_limpeza_id, chamado_id, data_inicio_chamado,
                mes_recomendacao
            )
            VALUES (
                :ala_id, :organizacao_id, :nome_completo,
                CAST(:sexo AS sexo_tipo), :cargo, :aniversario,
                :familia_id, :grupo_limpeza_id, :chamado_id, :data_inicio_chamado,
                :mes_recomendacao
            )
            RETURNING {COLUNAS}
        """),
        {**data.model_dump(), "ala_id": ala_id, "organizacao_id": organizacao_id},
    )
    return dict(result.mappings().one())


async def get_member(member_id: int, ala_id: int, db: AsyncSession) -> dict:
    result = await db.execute(
        text(f"""
            SELECT {COLUNAS} FROM membros
            WHERE id = :id AND ala_id = :ala_id
        """),
        {"id": member_id, "ala_id": ala_id},
    )
    row = result.mappings().first()
    if not row:
        raise NotFoundError("Membro não encontrado.")
    return dict(row)


async def list_members(
    ala_id: int,
    db: AsyncSession,
    *,
    organizacao_id: int | None = None,
    chamado_id: int | None = None,
    grupo_limpeza_id: int | None = None,
    sexo: str | None = None,
    ativo: bool | None = True,
    search: str | None = None,
    page: int = 1,
    page_size: int = 20,
) -> dict:
    conditions = ["ala_id = :ala_id"]
    params: dict = {"ala_id": ala_id}

    if ativo is not None:
        conditions.append("ativo = :ativo")
        params["ativo"] = ativo
    if organizacao_id is not None:
        conditions.append("organizacao_id = :organizacao_id")
        params["organizacao_id"] = organizacao_id
    if chamado_id is not None:
        conditions.append("chamado_id = :chamado_id")
        params["chamado_id"] = chamado_id
    if grupo_limpeza_id is not None:
        conditions.append("grupo_limpeza_id = :grupo_limpeza_id")
        params["grupo_limpeza_id"] = grupo_limpeza_id
    if sexo:
        conditions.append("sexo = CAST(:sexo AS sexo_tipo)")
        params["sexo"] = sexo
    if search:
        conditions.append("nome_completo ILIKE :search")
        params["search"] = f"%{search.strip()}%"

    where = " AND ".join(conditions)

    total = (
        await db.execute(text(f"SELECT COUNT(*) FROM membros WHERE {where}"), params)
    ).scalar_one()

    result = await db.execute(
        text(f"""
            SELECT {COLUNAS} FROM membros
            WHERE {where}
            ORDER BY nome_completo
            LIMIT :limit OFFSET :offset
        """),
        {**params, "limit": page_size, "offset": (page - 1) * page_size},
    )

    return {
        "items": [dict(r) for r in result.mappings()],
        "total": total,
        "page": page,
        "page_size": page_size,
        "total_pages": ceil(total / page_size) if total else 0,
    }


async def update_member(
    member_id: int, data: MemberUpdate, ala_id: int, db: AsyncSession
) -> dict:
    atual = await get_member(member_id, ala_id, db)
    changes = data.model_dump(exclude_unset=True)
    if not changes:
        return atual

    if "nome_completo" in changes:
        if changes["nome_completo"] is None:
            raise BusinessRuleError("O nome do membro não pode ser removido.")
        await garantir_nome_unico(
            ala_id, changes["nome_completo"], db, ignorar_id=member_id
        )

    await validar_vinculos(changes, ala_id, db)

    # Se sexo ou aniversário mudaram, a organização é recalculada
    if "sexo" in changes or "aniversario" in changes:
        sexo = changes.get("sexo", atual["sexo"])
        aniversario = changes.get("aniversario", atual["aniversario"])
        changes["organizacao_id"] = await calcular_organizacao(
            ala_id, sexo, aniversario, db
        )

    set_parts = []
    for campo in changes:
        if campo == "sexo":
            set_parts.append("sexo = CAST(:sexo AS sexo_tipo)")
        else:
            set_parts.append(f"{campo} = :{campo}")

    result = await db.execute(
        text(f"""
            UPDATE membros SET {", ".join(set_parts)}
            WHERE id = :id AND ala_id = :ala_id
            RETURNING {COLUNAS}
        """),
        {**changes, "id": member_id, "ala_id": ala_id},
    )
    return dict(result.mappings().one())


async def set_member_status(
    member_id: int, ativo: bool, ala_id: int, db: AsyncSession
) -> dict:
    membro = await get_member(member_id, ala_id, db)

    # Reativar pode criar um nome duplicado entre os ativos
    if ativo and not membro["ativo"]:
        await garantir_nome_unico(
            ala_id, membro["nome_completo"], db, ignorar_id=member_id
        )

    result = await db.execute(
        text(f"""
            UPDATE membros SET ativo = :ativo
            WHERE id = :id AND ala_id = :ala_id
            RETURNING {COLUNAS}
        """),
        {"ativo": ativo, "id": member_id, "ala_id": ala_id},
    )
    return dict(result.mappings().one())


