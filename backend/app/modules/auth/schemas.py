from pydantic import BaseModel, EmailStr, model_validator

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: int
    name: str
    ward_id: int
    permissions: list[str]

class LoginResponse(BaseModel):
    access_token: str
    user: UserResponse

class NewWardRequest(BaseModel):
    estado_id: int
    estaca_id: int | None = None
    estaca_nome: str | None = None
    ala_nome: str
    nome_completo: str
    email: EmailStr
    password: str

    @model_validator(mode="after")
    def validate_estaca(self):
        if self.estaca_id is None and not self.estaca_nome:
            raise ValueError(
                "estaca_nome é obrigatório quando estaca_id não é informado."
            )
        return self

class ExistingWardRequest(BaseModel):
    ala_id: int
    nome_completo: str
    email: EmailStr
    password: str