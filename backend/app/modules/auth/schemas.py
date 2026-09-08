from pydantic import BaseModel, EmailStr

class LoginRequest(BaseModel):
    email: EmailStr
    password: str
    
class UserResponse(BaseModel):
    id: int
    name: str        # nome_completo do membro vinculado
    ward_id: int
    permissions: list[str]
    
class LoginResponse(BaseModel):
    access_token: str
    user: UserResponse
    
# Schema para criar nova ala
class NewWardRequest(BaseModel):
    # Localização
    estado_id: int
    estaca_id: int | None = None   # None se for criar nova estaca
    estaca_nome: str | None = None # obrigatório se estaca_id for None
    ala_nome: str

    # Dados do primeiro membro/usuário
    nome_completo: str
    email: EmailStr
    password: str


# Schema para entrar em ala existente
class ExistingWardRequest(BaseModel):
    ala_id: int
    nome_completo: str
    email: EmailStr
    password: str