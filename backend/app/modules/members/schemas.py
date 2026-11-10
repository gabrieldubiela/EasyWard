from datetime import date
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator

Sexo = Literal["masculino", "feminino", "outro"]


class MemberBase(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    nome_completo: str = Field(min_length=3, max_length=150)
    sexo: Sexo | None = None
    cargo: str | None = Field(default=None, max_length=120)
    aniversario: date | None = None
    familia_id: int | None = None
    grupo_limpeza_id: int | None = None
    chamado_id: int | None = None
    data_inicio_chamado: date | None = None
    mes_recomendacao: int | None = Field(default=None, ge=1, le=12)

    @field_validator("nome_completo")
    @classmethod
    def normalizar_nome(cls, v: str) -> str:
        # "Gabriel   Dubiela" -> "Gabriel Dubiela"
        return " ".join(v.split())

    @field_validator("aniversario")
    @classmethod
    def aniversario_no_passado(cls, v: date | None) -> date | None:
        if v is not None and v > date.today():
            raise ValueError("A data de aniversário não pode estar no futuro.")
        return v


class MemberCreate(MemberBase):
    pass


class MemberUpdate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    nome_completo: str | None = Field(default=None, min_length=3, max_length=150)
    sexo: Sexo | None = None
    cargo: str | None = Field(default=None, max_length=120)
    aniversario: date | None = None
    familia_id: int | None = None
    grupo_limpeza_id: int | None = None
    chamado_id: int | None = None
    data_inicio_chamado: date | None = None
    mes_recomendacao: int | None = Field(default=None, ge=1, le=12)
    
    @field_validator("nome_completo")
    @classmethod
    def normalizar_nome(cls, v: str | None) -> str | None:
        return " ".join(v.split()) if v else v
    
    @field_validator("aniversario")
    @classmethod
    def aniversario_no_passado(cls, v: date | None) -> date | None:
        if v is not None and v > date.today():
            raise ValueError("A data de aniversário não pode estar no futuro.")
        return v


class MemberStatusUpdate(BaseModel):
    ativo: bool


class MemberOrganizationUpdate(BaseModel):
    organizacao_id: int | None = None


class MemberResponse(BaseModel):
    id: int
    ala_id: int
    organizacao_id: int | None
    nome_completo: str
    sexo: Sexo | None
    cargo: str | None
    aniversario: date | None
    familia_id: int | None
    grupo_limpeza_id: int | None
    chamado_id: int | None
    data_inicio_chamado: date | None
    apto_trocar_chamado: bool
    data_ultimo_discurso: date | None
    mes_recomendacao: int | None
    apto_recomendacao: bool
    ativo: bool