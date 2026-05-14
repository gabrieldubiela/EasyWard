# EasyWard — Backend

## 1. Objetivo

Definir a estrutura técnica, padrões de código, organização de módulos e responsabilidades da camada de backend do EasyWard.

---

## 2. Stack

| Tecnologia | Uso |
|---|---|
| Python 3.11+ | Linguagem principal |
| FastAPI | Framework web |
| SQLAlchemy 2.x (async) | ORM e query builder |
| asyncpg | Driver PostgreSQL assíncrono |
| Alembic | Migrações de banco de dados |
| Pydantic v2 | Validação de dados e schemas |
| python-jose | Geração e validação de JWT |
| bcrypt | Hash de senhas |
| structlog | Logs estruturados |
| APScheduler | Scheduler interno (reserva — jobs são disparados via GitHub Actions) |
| httpx | Cliente HTTP assíncrono (para chamadas externas) |
| Resend SDK | Envio de e-mails |
| firebase-admin | Notificações push (FCM) |
| sentry-sdk | Rastreamento de erros |

---

## 3. Organização de Módulos

Cada domínio funcional é um módulo independente com responsabilidades bem definidas. Ver estrutura completa em `docs/estrutura-pastas.md`.

### Responsabilidades por módulo

| Módulo | Responsabilidade |
|---|---|
| `auth` | Login, logout, refresh token, onboarding de ala e usuário |
| `ward_seed_service` | Serviço interno chamado no onboarding: insere 5 org. principais, 8 org. auxiliares, 113 chamados padrão, 4 grupos de orçamento e config padrão para cada ala criada |
| `users` | Gestão de usuários e permissões |
| `geo` | Estados, estacas e alas |
| `families` | Famílias |
| `members` | Membros (com soft delete) |
| `visitors` | Visitantes |
| `organizations` | Organizações (globais e locais) |
| `callings` | Chamados (globais e locais) |
| `cleaning` | Grupos de limpeza e escala semanal |
| `hymns` | Hinos (globais e locais) |
| `meetings` | Reunião sacramental completa |
| `bishopric_meetings` | Reunião de bispado |
| `ward_council` | Reunião de conselho da ala |
| `attendance` | Frequência |
| `tasks` | Tarefas do bispado |
| `interviews` | Entrevistas |
| `budget` | Orçamento trimestral e grupos de orçamento |
| `reports` | Geração e persistência de relatórios (semanal, mensal, trimestral) |
| `jobs` | Execução (semanal, mensal, trimestral, **anual**), disparo manual e histórico de automações |
| `notifications` | Notificações em tela, push via FCM e e-mail via Resend |

---

## 4. Padrão de Camadas por Módulo

Cada módulo segue a separação em três camadas:

```
módulo/
├── router.py       # Endpoints FastAPI — entrada e saída HTTP
├── service.py      # Regras de negócio e orquestração
├── repository.py   # Acesso ao banco de dados (queries SQLAlchemy)
├── schemas.py      # Modelos Pydantic (request/response)
└── models.py       # Modelos SQLAlchemy (tabelas)
```

### Responsabilidades

**`router.py`**
- Recebe e valida a requisição HTTP
- Extrai dados do body, path params e query params
- Chama o service
- Retorna a resposta padronizada
- Não contém lógica de negócio

**`service.py`**
- Aplica as regras de negócio
- Orquestra chamadas ao repository
- Lança exceções de domínio
- Não acessa o banco diretamente

**`repository.py`**
- Executa queries no banco via SQLAlchemy
- Não contém regras de negócio
- Retorna modelos SQLAlchemy ou valores primitivos

**`schemas.py`**
- Define os modelos de entrada (`...Request`, `...Create`, `...Update`)
- Define os modelos de saída (`...Response`, `...Summary`)
- Usa Pydantic v2 com validações explícitas

**`models.py`**
- Define as tabelas SQLAlchemy
- Sem lógica de negócio

---

## 5. Padrões de Código

### 5.1 Nomenclatura

| Elemento | Padrão | Exemplo |
|---|---|---|
| Arquivos | `snake_case` | `member_service.py` |
| Classes | `PascalCase` | `MemberService` |
| Funções e variáveis | `snake_case` | `get_active_members` |
| Constantes | `UPPER_SNAKE_CASE` | `JWT_ALGORITHM` |
| Rotas | `kebab-case` | `/bishopric-tasks` |
| Tabelas do banco | `snake_case` plural | `reunioes_sacramentais` |

### 5.2 Tipagem

Todo código deve ser totalmente tipado com type hints do Python:

```python
async def get_member(
    member_id: int,
    ward_id: int,
    db: AsyncSession,
) -> MemberResponse:
    ...
```

### 5.3 Async

Todos os endpoints e funções de I/O devem ser assíncronos (`async/await`):

```python
@router.get("/{id}", response_model=MemberResponse)
async def get_member(
    id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> MemberResponse:
    return await member_service.get_by_id(id, current_user.ward_id, db)
```

### 5.4 Injeção de Dependências

Usar o sistema de `Depends` do FastAPI para:
- Sessão do banco: `Depends(get_db)`
- Usuário autenticado: `Depends(get_current_user)`
- Verificação de permissão: `Depends(require_permission("manage_members"))`

```python
def require_permission(code: str):
    async def checker(
        current_user: User = Depends(get_current_user),
        db: AsyncSession = Depends(get_db),
    ) -> User:
        if not await user_service.has_permission(current_user.id, code, db):
            raise HTTPException(status_code=403, detail="Permissão insuficiente.")
        return current_user
    return checker
```

---

## 6. Autenticação e Autorização

### 6.1 JWT

```python
# Geração
access_token = create_access_token(
    data={"sub": str(user.id), "ward_id": user.ward_id},
    expires_delta=timedelta(minutes=30),
)

# Validação (via Depends)
async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
) -> User:
    payload = decode_token(token)
    user = await user_repository.get_by_id(payload["sub"], db)
    if not user or not user.ativo:
        raise HTTPException(status_code=401)
    return user
```

### 6.2 Filtro por ala

Todo repository deve filtrar automaticamente pelo `ward_id` do usuário autenticado. Nenhum dado de outra ala deve ser acessível:

```python
async def list_members(ward_id: int, db: AsyncSession) -> list[Member]:
    result = await db.execute(
        select(Member)
        .where(Member.ala_id == ward_id, Member.ativo == True)
        .order_by(Member.nome_completo)
    )
    return result.scalars().all()
```

---

## 7. Resposta Padronizada

Usar um wrapper de resposta consistente em todos os endpoints:

```python
# app/core/response.py
from typing import Any, Generic, TypeVar
from pydantic import BaseModel

T = TypeVar("T")

class ApiResponse(BaseModel, Generic[T]):
    success: bool = True
    message: str = "Operação realizada com sucesso."
    data: T | None = None

class ApiError(BaseModel):
    success: bool = False
    message: str
    errors: list[dict] | None = None
```

---

## 8. Tratamento de Erros

Usar exceções de domínio customizadas e um handler global:

```python
# app/core/exceptions.py
class NotFoundError(Exception):
    def __init__(self, entity: str, id: int):
        self.message = f"{entity} com id {id} não encontrado."

class PermissionError(Exception):
    def __init__(self):
        self.message = "Permissão insuficiente para esta operação."

class BusinessRuleError(Exception):
    def __init__(self, message: str):
        self.message = message
```

```python
# app/core/exception_handlers.py
@app.exception_handler(NotFoundError)
async def not_found_handler(request, exc):
    return JSONResponse(status_code=404, content={"success": False, "message": exc.message})
```

---

## 9. Banco de Dados

### Sessão assíncrona

```python
# app/core/database.py
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker

engine = create_async_engine(settings.DATABASE_URL, echo=False)
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

### Migrações

```bash
# Criar migração
alembic revision --autogenerate -m "descricao"

# Aplicar
alembic upgrade head

# Reverter
alembic downgrade -1
```

---

## 10. Auditoria

Operações críticas devem registrar um `audit_log` automaticamente via serviço centralizado:

```python
# app/core/audit.py
async def log_action(
    db: AsyncSession,
    user_id: int,
    ward_id: int,
    action: str,
    entity: str,
    entity_id: int | None = None,
    before: dict | None = None,
    after: dict | None = None,
    ip_address: str | None = None,
) -> None:
    ...
```

Ações que devem gerar audit log:
- Criar, editar, inativar membro
- Criar, editar, remover usuário
- Alterar permissões de usuário
- Lançar frequência
- Registrar entrevista
- Editar orçamento
- Disparar job manualmente

---

## 11. Logs Estruturados

```python
import structlog

log = structlog.get_logger()

# Uso em services
log.info("member.created",
    user_id=current_user.id,
    ward_id=current_user.ward_id,
    member_id=new_member.id,
)

log.error("job.failed",
    job_name="weekly",
    ward_id=ward_id,
    error=str(exc),
)
```

---

## 12. Variáveis de Ambiente

Gerenciar via `pydantic-settings`:

```python
# app/core/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str
    JWT_SECRET: str
    JWT_REFRESH_SECRET: str
    JOB_SECRET: str
    APP_ENV: str = "development"
    RESEND_API_KEY: str
    FIREBASE_CREDENTIALS: str
    SENTRY_DSN: str
    CORS_ORIGINS: str

    class Config:
        env_file = ".env"

settings = Settings()
```

---

## 13. CORS

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS.split(","),
    allow_credentials=True,  # necessário para cookie httpOnly
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## 14. Rate Limiting

Aplicar rate limiting nas rotas de autenticação para prevenir força bruta:

```python
# Usar slowapi (wrapper do limits para FastAPI)
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

@router.post("/login")
@limiter.limit("10/minute")
async def login(request: Request, ...):
    ...
```

---

## 15. Health Check

```python
@router.get("/health")
async def health_check(db: AsyncSession = Depends(get_db)):
    try:
        await db.execute(text("SELECT 1"))
        db_status = "connected"
    except Exception:
        db_status = "disconnected"

    return {
        "status": "ok",
        "environment": settings.APP_ENV,
        "database": db_status,
    }
```

---

*EasyWard v0.1*
