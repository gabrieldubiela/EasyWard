from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text

ALL_PERMISSIONS = [
    "view_users", "manage_users", "manage_user_permissions",
    "edit_ward",
    "view_organizations", "manage_local_organizations",
    "view_callings", "manage_local_callings", "deactivate_callings",
    "view_cleaning_groups", "manage_cleaning_groups",
    "view_members", "manage_members", "deactivate_members",
    "view_families", "manage_families",
    "view_visitors", "manage_visitors",
    "view_sacrament_meeting", "manage_sacrament_meeting",
    "view_talks", "manage_talks",
    "view_attendance", "register_attendance",
    "view_bishopric_meeting", "manage_bishopric_meeting",
    "view_ward_council", "manage_ward_council",
    "view_interviews", "manage_interviews",
    "view_tasks", "manage_tasks", "complete_tasks",
    "view_cleaning", "manage_cleaning",
    "view_budget", "manage_budget",
    "view_weekly_report", "view_monthly_report",
    "view_quarterly_report", "generate_reports",
    "view_hymns", "manage_hymns",
    "view_jobs", "run_jobs",
]

PRINCIPAL_ORGS = [
    {"nome": "Quórum de Élderes",    "sexo_alvo": "masculino", "idade_min": 18,  "idade_max": None},
    {"nome": "Sociedade de Socorro", "sexo_alvo": "feminino",  "idade_min": 18,  "idade_max": None},
    {"nome": "Rapazes",              "sexo_alvo": "masculino", "idade_min": 12,  "idade_max": 17},
    {"nome": "Moças",                "sexo_alvo": "feminino",  "idade_min": 12,  "idade_max": 17},
    {"nome": "Primária",             "sexo_alvo": None,        "idade_min": 0,   "idade_max": 11},
]

AUXILIARY_ORGS = [
    "Missionários de Ala",
    "Templo e História da Família",
    "Escola Dominical",
    "Bispado",
    "Jovens Adultos Solteiros",
    "Bem-estar e Autossuficiência",
    "Instalações",
    "Música",
]

BUDGET_GROUPS = [
    {"nome": "Quórum de Élderes",    "peso": 3.0, "orgs": ["Quórum de Élderes"]},
    {"nome": "Sociedade de Socorro", "peso": 3.0, "orgs": ["Sociedade de Socorro"]},
    {"nome": "Jovens",               "peso": 2.0, "orgs": ["Rapazes", "Moças"]},
    {"nome": "Primária",             "peso": 2.0, "orgs": ["Primária"]},
]

async def seed_ward(ala_id: int, db: AsyncSession) -> None:
    await _seed_organizations(ala_id, db)
    await _seed_budget_groups(ala_id, db)
    await _seed_config(ala_id, db)
    
async def _seed_organizations(ala_id: int, db: AsyncSession) -> None:
    # Buscar IDs dos tipos
    principal_id = await _get_tipo_org_id("principal", db)
    auxiliar_id = await _get_tipo_org_id("auxiliar", db)

    # Inserir organizações principais
    for org in PRINCIPAL_ORGS:
        await db.execute(text("""
            INSERT INTO organizacoes
                (ala_id, tipo_organizacao_id, nome, sexo_alvo, idade_min, idade_max, origem)
            VALUES
                (:ala_id, :tipo_id, :nome, :sexo_alvo, :idade_min, :idade_max, 'global')
            ON CONFLICT (ala_id, nome) DO NOTHING
        """), {
            "ala_id": ala_id, "tipo_id": principal_id,
            "nome": org["nome"], "sexo_alvo": org["sexo_alvo"],
            "idade_min": org["idade_min"], "idade_max": org["idade_max"],
        })

    # Inserir organizações auxiliares
    for nome in AUXILIARY_ORGS:
        await db.execute(text("""
            INSERT INTO organizacoes
                (ala_id, tipo_organizacao_id, nome, origem)
            VALUES
                (:ala_id, :tipo_id, :nome, 'global')
            ON CONFLICT (ala_id, nome) DO NOTHING
        """), {"ala_id": ala_id, "tipo_id": auxiliar_id, "nome": nome})


async def _get_tipo_org_id(nome: str, db: AsyncSession) -> int:
    result = await db.execute(
        text("SELECT id FROM tipos_organizacao WHERE nome = :nome"),
        {"nome": nome}
    )
    return result.scalar_one()


async def _seed_budget_groups(ala_id: int, db: AsyncSession) -> None:
    for group in BUDGET_GROUPS:
        # Inserir grupo
        result = await db.execute(text("""
            INSERT INTO grupos_orcamento (ala_id, nome, peso, origem)
            VALUES (:ala_id, :nome, :peso, 'global')
            ON CONFLICT (ala_id, nome) DO NOTHING
            RETURNING id
        """), {"ala_id": ala_id, "nome": group["nome"], "peso": group["peso"]})

        row = result.mappings().first()
        if not row:
            # Já existia — buscar o id
            row = (await db.execute(
                text("SELECT id FROM grupos_orcamento WHERE ala_id = :ala_id AND nome = :nome"),
                {"ala_id": ala_id, "nome": group["nome"]}
            )).mappings().first()

        grupo_id = row["id"]

        # Vincular organizações ao grupo
        for org_nome in group["orgs"]:
            org = (await db.execute(
                text("SELECT id FROM organizacoes WHERE ala_id = :ala_id AND nome = :nome"),
                {"ala_id": ala_id, "nome": org_nome}
            )).mappings().first()

            if org:
                await db.execute(text("""
                    INSERT INTO grupos_orcamento_organizacoes (grupo_id, organizacao_id)
                    VALUES (:grupo_id, :org_id)
                    ON CONFLICT DO NOTHING
                """), {"grupo_id": grupo_id, "org_id": org["id"]})


async def _seed_config(ala_id: int, db: AsyncSession) -> None:
    await db.execute(text("""
        INSERT INTO system_config (ala_id, key, value)
        VALUES (:ala_id, 'absence_threshold_weeks', '2')
        ON CONFLICT (COALESCE(ala_id, 0), key) DO NOTHING
    """), {"ala_id": ala_id})