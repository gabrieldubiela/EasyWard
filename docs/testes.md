# EasyWard — Testes

## 1. Objetivo

Definir a estratégia de testes do EasyWard: o que testar, como organizar e como integrar ao CI.

---

## 2. Pirâmide de Testes

```
        /\
       /  \       E2E (poucos — fluxos críticos)
      /────\
     /      \     Integração (endpoints da API)
    /────────\
   /          \   Unitários (regras de negócio e services)
  /────────────\
```

Foco principal: **testes de integração de API** — testam o backend de ponta a ponta (endpoint → service → banco) de forma confiável e sem excesso de mocks.

---

## 3. Backend

### 3.1 Stack de Testes
| Ferramenta | Uso |
|---|---|
| `pytest` | Framework de testes |
| `pytest-asyncio` | Suporte a testes assíncronos |
| `httpx` | Cliente HTTP para testar endpoints FastAPI |
| `pytest-cov` | Cobertura de código |
| PostgreSQL (Docker) | Banco de dados de teste isolado |

### 3.2 Configuração

```python
# tests/conftest.py
import pytest
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from app.main import app
from app.core.database import get_db
from app.core.config import settings

TEST_DATABASE_URL = "postgresql+asyncpg://easyward:easyward@localhost:5432/easyward_test"

@pytest.fixture(scope="session")
async def db_engine():
    engine = create_async_engine(TEST_DATABASE_URL)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield engine
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()

@pytest.fixture
async def db_session(db_engine):
    async with AsyncSession(db_engine) as session:
        yield session
        await session.rollback()  # rollback após cada teste

@pytest.fixture
async def client(db_session):
    async def override_get_db():
        yield db_session
    app.dependency_overrides[get_db] = override_get_db
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c
    app.dependency_overrides.clear()

@pytest.fixture
async def auth_headers(client, db_session):
    """Cria usuário de teste e retorna headers autenticados."""
    # criar ala, membro e usuário de teste
    # fazer login
    # retornar {"Authorization": "Bearer <token>"}
    ...
```

### 3.3 Testes Unitários

Testar funções de cálculo e regras de negócio isoladamente:

```python
# tests/unit/test_attendance.py
from app.modules.attendance.service import calculate_absence_streak

def test_absence_streak_two_weeks():
    """Membro ausente nas últimas 2 reuniões deve ser identificado."""
    meetings = [False, False]  # ausente, ausente
    assert calculate_absence_streak(meetings) == 2

def test_absence_streak_resets_on_presence():
    """Presença interrompe a sequência de ausência."""
    meetings = [False, True, False]
    assert calculate_absence_streak(meetings) == 1
```

```python
# tests/unit/test_budget.py
from app.modules.budget.service import calculate_distribution

def test_distribution_sum_equals_total():
    """Soma das distribuições deve ser igual ao valor recebido."""
    grupos = [
        {"nome": "Quórum de Élderes", "peso": 3.0, "frequencia": 0.75},
        {"nome": "Sociedade de Socorro", "peso": 3.0, "frequencia": 0.80},
        {"nome": "Jovens", "peso": 2.0, "frequencia": 0.60},  # Rapazes + Moças combinados
        {"nome": "Primária", "peso": 2.0, "frequencia": 0.50},
    ]
    result = calculate_distribution(grupos, valor_recebido=1000.0)
    total = sum(r["valor_distribuido"] for r in result)
    assert abs(total - 1000.0) < 0.01  # tolerância de arredondamento

def test_jovens_group_combines_organizations():
    """Grupo Jovens deve somar frequência de Rapazes e Moças."""
    # Rapazes: 10 membros, 6 presentes (60%)
    # Moças:   8 membros, 7 presentes (87.5%)
    # Jovens (combinado): 18 membros, 13 presentes = 72.2%
    from app.modules.budget.service import calculate_group_frequency
    freq = calculate_group_frequency(
        organizacoes=[
            {"membros": 10, "presentes": 6},   # Rapazes
            {"membros": 8,  "presentes": 7},   # Moças
        ]
    )
    assert abs(freq - (13 / 18)) < 0.001

def test_organization_yearly_reassignment():
    """Job anual deve atribuir organização correta por faixa etária (por ano)."""
    from app.modules.jobs.yearly_service import get_expected_organization
    import datetime
    current_year = datetime.date.today().year

    # Menino que completa 12 anos este ano → Rapazes (mesmo que em dezembro)
    birth_year_12 = current_year - 12
    assert get_expected_organization(sexo="masculino", birth_year=birth_year_12) == "Rapazes"

    # Menina que completa 18 anos este ano → Sociedade de Socorro
    birth_year_18 = current_year - 18
    assert get_expected_organization(sexo="feminino", birth_year=birth_year_18) == "Sociedade de Socorro"

    # Criança de 11 anos → Primária
    birth_year_11 = current_year - 11
    assert get_expected_organization(sexo="masculino", birth_year=birth_year_11) == "Primária"
```

### 3.4 Testes de Integração (Endpoints)

```python
# tests/integration/test_members_api.py
import pytest

@pytest.mark.asyncio
async def test_create_member(client, auth_headers):
    response = await client.post(
        "/api/v1/members",
        json={"nome_completo": "João Silva", "sexo": "masculino"},
        headers=auth_headers,
    )
    assert response.status_code == 201
    data = response.json()
    assert data["success"] is True
    assert data["data"]["nome_completo"] == "João Silva"

@pytest.mark.asyncio
async def test_list_members_only_own_ward(client, auth_headers):
    """Listagem deve retornar apenas membros da ala do usuário."""
    response = await client.get("/api/v1/members", headers=auth_headers)
    assert response.status_code == 200
    members = response.json()["data"]["items"]
    # todos os membros devem pertencer à ala do usuário autenticado
    ward_ids = {m["ala_id"] for m in members}
    assert len(ward_ids) <= 1

@pytest.mark.asyncio
async def test_create_member_without_permission(client):
    """Usuário sem permissão não deve criar membro."""
    # headers de usuário sem a permissão manage_members
    response = await client.post(
        "/api/v1/members",
        json={"nome_completo": "Teste"},
        headers={"Authorization": "Bearer token_sem_permissao"},
    )
    assert response.status_code == 403

@pytest.mark.asyncio
async def test_unauthenticated_request(client):
    """Requisição sem token deve retornar 401."""
    response = await client.get("/api/v1/members")
    assert response.status_code == 401
```

### 3.5 O Que Testar por Módulo

| Módulo | Testes prioritários |
|---|---|
| `auth` | Login válido/inválido, refresh token, logout, rate limiting |
| `members` | CRUD completo, soft delete, filtro por ala, permissões |
| `attendance` | Registro em lote, constraint de pessoa única, cálculo de ausência |
| `reports` | Geração semanal/mensal/trimestral, idempotência |
| `jobs` | Disparo manual, autenticação por JOB_SECRET, idempotência |
| `permissions` | Atribuição, revogação, proteção da permissão crítica |
| `budget` | Distribuição por grupos (incluindo grupos compostos como Jovens), unicidade por trimestre, cálculo de acumulado |
| `jobs` (yearly) | Recálculo de organização por faixa etária, cálculo de idade por ano de nascimento |

### 3.6 Executar Testes

```bash
# Todos os testes
pytest tests/

# Com cobertura
pytest --cov=app --cov-report=term-missing tests/

# Apenas unitários
pytest tests/unit/

# Apenas integração
pytest tests/integration/

# Arquivo específico
pytest tests/integration/test_members_api.py -v

# Teste específico
pytest tests/integration/test_members_api.py::test_create_member -v
```

---

## 4. Frontend

### 4.1 Stack de Testes
| Ferramenta | Uso |
|---|---|
| `vitest` | Framework de testes (integrado ao Vite) |
| `@testing-library/react` | Renderização e interação com componentes |
| `msw` (Mock Service Worker) | Mock das chamadas de API |

### 4.2 O Que Testar

Foco em **componentes com lógica** e **hooks customizados**:

```typescript
// tests/hooks/usePermission.test.ts
import { renderHook } from '@testing-library/react';
import { usePermission } from '@/hooks/usePermission';

test('retorna true para permissão existente', () => {
  // mock do store com permissões
  const { result } = renderHook(() => usePermission('view_members'));
  expect(result.current).toBe(true);
});

test('retorna false para permissão ausente', () => {
  const { result } = renderHook(() => usePermission('manage_budget'));
  expect(result.current).toBe(false);
});
```

```typescript
// tests/components/AttendanceRow.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { AttendanceRow } from '@/components/domain/AttendanceRow';

test('alterna presença ao clicar', () => {
  const onChange = vi.fn();
  render(<AttendanceRow member={{ nome_completo: 'João' }} presente={false} onChange={onChange} />);
  fireEvent.click(screen.getByRole('checkbox'));
  expect(onChange).toHaveBeenCalledWith(true);
});
```

---

## 5. Cobertura de Código

Metas mínimas (a atingir antes da v1.0):

| Camada | Meta |
|---|---|
| Backend — services (regras de negócio) | 80% |
| Backend — endpoints críticos (auth, members, attendance) | 70% |
| Frontend — hooks customizados | 70% |
| Frontend — componentes com lógica | 50% |

---

## 6. CI — GitHub Actions

```yaml
# .github/workflows/tests.yml
name: Testes

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: easyward
          POSTGRES_PASSWORD: easyward
          POSTGRES_DB: easyward_test
        ports: ['5432:5432']
        options: --health-cmd pg_isready --health-interval 5s

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Instalar dependências
        run: |
          cd backend
          pip install -r requirements.txt

      - name: Aplicar schema de teste
        run: psql postgresql://easyward:easyward@localhost:5432/easyward_test -f docs/schema.sql
        env:
          PGPASSWORD: easyward

      - name: Executar testes
        run: |
          cd backend
          pytest --cov=app --cov-report=xml tests/
        env:
          DATABASE_URL: postgresql+asyncpg://easyward:easyward@localhost:5432/easyward_test
          JWT_SECRET: test_secret
          JWT_REFRESH_SECRET: test_refresh_secret
          JOB_SECRET: test_job_secret
          APP_ENV: test

  frontend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Instalar dependências
        run: cd frontend && npm ci

      - name: Executar testes
        run: cd frontend && npm run test
```

---

## 7. O Que NÃO Testar

- Bibliotecas de terceiros (FastAPI, SQLAlchemy, Pydantic)
- Migrations do Alembic (testadas pelo próprio Alembic)
- Componentes puramente visuais sem lógica (ex: Button simples)
- Seeds de dados

---

*EasyWard v0.1*
