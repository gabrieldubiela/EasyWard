from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import require_permission
from app.core.response import success_response
from app.modules.members import service
from app.modules.members.schemas import (
    MemberCreate,
    MemberOrganizationUpdate,
    MemberResponse,
    MemberStatusUpdate,
    MemberUpdate,
    Sexo,
)

router = APIRouter(prefix="/members", tags=["members"])


@router.get("")
async def list_members(
    organizacao_id: int | None = None,
    chamado_id: int | None = None,
    grupo_limpeza_id: int | None = None,
    sexo: Sexo | None = None,
    ativo: bool = True,
    search: str | None = None,
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: dict = Depends(require_permission("view_members")),
    db: AsyncSession = Depends(get_db),
):
    result = await service.list_members(
        current_user["ala_id"],
        db,
        organizacao_id=organizacao_id,
        chamado_id=chamado_id,
        grupo_limpeza_id=grupo_limpeza_id,
        sexo=sexo,
        ativo=ativo,
        search=search,
        page=page,
        page_size=page_size,
    )
    result["items"] = [MemberResponse(**item) for item in result["items"]]
    return success_response(data=result)


@router.post("", status_code=201)
async def create_member(
    data: MemberCreate,
    current_user: dict = Depends(require_permission("manage_members")),
    db: AsyncSession = Depends(get_db),
):
    member = await service.create_member(data, current_user["ala_id"], db)
    return success_response(MemberResponse(**member), "Membro cadastrado com sucesso.")


@router.get("/{member_id}")
async def get_member(
    member_id: int,
    current_user: dict = Depends(require_permission("view_members")),
    db: AsyncSession = Depends(get_db),
):
    member = await service.get_member(member_id, current_user["ala_id"], db)
    return success_response(MemberResponse(**member))


@router.put("/{member_id}")
async def update_member(
    member_id: int,
    data: MemberUpdate,
    current_user: dict = Depends(require_permission("manage_members")),
    db: AsyncSession = Depends(get_db),
):
    member = await service.update_member(member_id, data, current_user["ala_id"], db)
    return success_response(MemberResponse(**member), "Membro atualizado com sucesso.")


@router.patch("/{member_id}/status")
async def set_member_status(
    member_id: int,
    data: MemberStatusUpdate,
    current_user: dict = Depends(require_permission("deactivate_members")),
    db: AsyncSession = Depends(get_db),
):
    member = await service.set_member_status(
        member_id, data.ativo, current_user["ala_id"], db
    )
    return success_response(MemberResponse(**member), "Status atualizado com sucesso.")


@router.patch("/{member_id}/organization")
async def set_member_organization(
    member_id: int,
    data: MemberOrganizationUpdate,
    current_user: dict = Depends(require_permission("manage_members")),
    db: AsyncSession = Depends(get_db),
):
    member = await service.set_member_organization(
        member_id, data.organizacao_id, current_user["ala_id"], db
    )
    return success_response(MemberResponse(**member), "Organização atualizada com sucesso.")