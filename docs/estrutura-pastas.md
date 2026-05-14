# EasyWard — Estrutura de Pastas

## 1. Visão Geral do Repositório

```
easyward/
├── .github/
│   └── workflows/
│       ├── backup.yml          # Backup diário → Google Drive
│       └── jobs.yml            # Jobs automáticos (semanal, mensal, trimestral)
├── backend/
├── frontend/
├── docs/
│   ├── arquitetura.md
│   ├── api.md
│   ├── backend.md
│   ├── frontend.md
│   ├── banco-de-dados.md
│   ├── permissoes.md
│   ├── jobs.md
│   ├── monitoramento.md
│   ├── backup.md
│   ├── deploy.md
│   ├── notificacoes.md
│   ├── ambiente-dev.md
│   ├── glossario.md
│   ├── estrutura-pastas.md
│   ├── design.md
│   ├── schema.sql
│   ├── seeds-hinos.sql
│   ├── seeds-organizacoes.sql       # Seeds de organizações por ala (backend)
│   └── seeds-chamados.sql            # Seeds de 113 chamados padrão por ala (backend)
├── README.md
└── .gitignore
```

---

## 2. Backend

```
backend/
├── alembic/
│   ├── versions/               # Arquivos de migração gerados pelo Alembic
│   └── env.py                  # Configuração do Alembic
├── app/
│   ├── main.py                 # Ponto de entrada da aplicação FastAPI
│   ├── core/
│   │   ├── config.py           # Variáveis de ambiente (pydantic-settings)
│   │   ├── database.py         # Engine, sessão assíncrona e get_db
│   │   ├── security.py         # JWT: criação, decodificação, hash de senha
│   │   ├── dependencies.py     # get_current_user, require_permission
│   │   ├── response.py         # ApiResponse e ApiError (wrappers padrão)
│   │   ├── exceptions.py       # Exceções de domínio (NotFoundError, etc.)
│   │   ├── exception_handlers.py # Handlers globais de exceção
│   │   ├── audit.py            # Serviço de log de auditoria
│   │   ├── middleware.py       # CORS, rate limiting, logging de requisição
│   │   └── seeds.py            # Inserção dos dados iniciais (estados, tipos, etc.)
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── router.py
│   │   │   ├── service.py
│   │   │   ├── repository.py
│   │   │   └── schemas.py
│   │   ├── users/
│   │   │   ├── router.py
│   │   │   ├── service.py
│   │   │   ├── repository.py
│   │   │   ├── schemas.py
│   │   │   └── models.py
│   │   ├── geo/                # Estados, estacas, alas
│   │   │   ├── router.py
│   │   │   ├── service.py
│   │   │   ├── repository.py
│   │   │   ├── schemas.py
│   │   │   └── models.py
│   │   ├── families/
│   │   ├── members/
│   │   ├── visitors/
│   │   ├── organizations/
│   │   ├── callings/
│   │   ├── cleaning/
│   │   ├── hymns/
│   │   ├── meetings/           # Reunião sacramental
│   │   │   ├── router.py
│   │   │   ├── service.py
│   │   │   ├── repository.py
│   │   │   ├── schemas.py
│   │   │   └── models.py
│   │   ├── bishopric_meetings/ # Reunião de bispado
│   │   ├── ward_council/       # Reunião de conselho da ala
│   │   ├── attendance/
│   │   ├── tasks/
│   │   ├── interviews/
│   │   ├── budget/
│   │   ├── reports/
│   │   ├── jobs/
│   │   └── notifications/
│   └── shared/
│       ├── pagination.py       # Helpers de paginação
│       ├── filters.py          # Helpers de filtros e ordenação
│       └── utils.py            # Utilitários gerais
├── tests/
│   ├── conftest.py             # Fixtures globais (DB de teste, cliente HTTP)
│   ├── unit/                   # Testes unitários por módulo
│   │   ├── test_auth.py
│   │   ├── test_members.py
│   │   └── ...
│   └── integration/            # Testes de integração de endpoints
│       ├── test_auth_api.py
│       └── ...
├── .env                        # Variáveis de ambiente locais (não commitado)
├── .env.example                # Modelo de variáveis de ambiente
├── alembic.ini
├── pyproject.toml              # Dependências e configuração do projeto Python
└── requirements.txt
```

---

## 3. Frontend

```
frontend/
├── public/
│   ├── icons/                  # Ícones PWA (192x192, 512x512, maskable)
│   ├── manifest.json           # Manifesto PWA
│   └── favicon.ico
├── src/
│   ├── app/
│   │   ├── App.tsx             # Componente raiz
│   │   ├── router.tsx          # Definição de todas as rotas
│   │   └── providers.tsx       # Providers globais (QueryClient, etc.)
│   ├── modules/                # Um diretório por domínio
│   │   ├── auth/
│   │   │   ├── pages/
│   │   │   │   ├── LoginPage.tsx
│   │   │   │   └── OnboardingPage.tsx
│   │   │   ├── components/
│   │   │   │   └── LoginForm.tsx
│   │   │   ├── services/
│   │   │   │   └── auth.service.ts
│   │   │   └── schemas/
│   │   │       └── login.schema.ts
│   │   ├── dashboard/
│   │   │   └── pages/
│   │   │       └── DashboardPage.tsx
│   │   ├── members/
│   │   │   ├── pages/
│   │   │   │   ├── MemberListPage.tsx
│   │   │   │   ├── MemberDetailPage.tsx
│   │   │   │   └── MemberFormPage.tsx
│   │   │   ├── components/
│   │   │   │   └── MemberCard.tsx
│   │   │   ├── services/
│   │   │   │   └── members.service.ts
│   │   │   └── schemas/
│   │   │       └── member.schema.ts
│   │   ├── families/
│   │   ├── visitors/
│   │   ├── attendance/
│   │   ├── meetings/
│   │   ├── bishopric-meetings/
│   │   ├── ward-council/
│   │   ├── tasks/
│   │   ├── interviews/
│   │   ├── cleaning/
│   │   ├── budget/
│   │   ├── reports/
│   │   ├── users/
│   │   └── settings/
│   ├── components/
│   │   ├── ui/                 # Componentes base reutilizáveis
│   │   │   ├── Button.tsx
│   │   │   ├── Input.tsx
│   │   │   ├── Select.tsx
│   │   │   ├── Textarea.tsx
│   │   │   ├── Checkbox.tsx
│   │   │   ├── DatePicker.tsx
│   │   │   ├── Modal.tsx
│   │   │   ├── Table.tsx
│   │   │   ├── Badge.tsx
│   │   │   ├── Alert.tsx
│   │   │   ├── Loader.tsx
│   │   │   ├── Skeleton.tsx
│   │   │   ├── Breadcrumb.tsx
│   │   │   ├── Pagination.tsx
│   │   │   └── EmptyState.tsx
│   │   ├── layout/             # Estrutura visual da aplicação
│   │   │   ├── AppShell.tsx    # Layout principal (menu + conteúdo)
│   │   │   ├── Sidebar.tsx     # Menu lateral (desktop)
│   │   │   ├── BottomNav.tsx   # Menu inferior (mobile)
│   │   │   ├── Header.tsx
│   │   │   └── PrivateRoute.tsx
│   │   └── domain/             # Componentes de domínio reutilizáveis
│   │       ├── MemberCard.tsx
│   │       ├── TaskCard.tsx
│   │       ├── InterviewCard.tsx
│   │       ├── AttendanceRow.tsx
│   │       ├── ReportSummary.tsx
│   │       └── NotificationBell.tsx
│   ├── services/               # Camada de consumo da API (Axios)
│   │   └── api.ts              # Instância Axios com interceptors
│   ├── store/                  # Stores Zustand
│   │   ├── auth.store.ts       # Usuário, permissões, sessão
│   │   └── ui.store.ts         # Estado de UI global (loading, toasts)
│   ├── hooks/                  # Hooks customizados
│   │   ├── usePermission.ts    # Verifica permissão do usuário
│   │   ├── usePagination.ts
│   │   └── useDebounce.ts
│   ├── lib/
│   │   ├── axios.ts            # Configuração e interceptors Axios
│   │   └── utils.ts            # Formatadores de data, moeda, etc.
│   ├── types/                  # Tipos TypeScript globais
│   │   ├── api.types.ts        # Tipos de resposta da API
│   │   ├── user.types.ts
│   │   └── common.types.ts
│   └── styles/
│       ├── global.css          # Reset e variáveis CSS globais
│       └── tokens.css          # Design tokens (cores, espaçamento, tipografia)
├── .env                        # Variáveis locais (não commitado)
├── .env.example
├── index.html
├── vite.config.ts
├── tsconfig.json
└── package.json
```

---

## 4. GitHub Actions

```
.github/
├── PULL_REQUEST_TEMPLATE.md    # Template padrão para Pull Requests
└── workflows/
    ├── backup.yml              # Backup diário do banco → Google Drive
    ├── jobs.yml                # Jobs automáticos periódicos
    └── tests.yml               # Testes automáticos em PRs
```

---

## 5. Convenções de Nomenclatura de Arquivos

| Tipo | Padrão | Exemplo |
|---|---|---|
| Páginas React | `PascalCase` + sufixo `Page` | `MemberListPage.tsx` |
| Componentes React | `PascalCase` | `MemberCard.tsx` |
| Serviços frontend | `camelCase` + sufixo `.service` | `members.service.ts` |
| Schemas Zod | `camelCase` + sufixo `.schema` | `member.schema.ts` |
| Stores Zustand | `camelCase` + sufixo `.store` | `auth.store.ts` |
| Hooks | `camelCase` com prefixo `use` | `usePermission.ts` |
| Arquivos Python | `snake_case` | `member_service.py` |
| Módulos backend | `snake_case` | `bishopric_meetings/` |

---

## 6. Gitignore

Arquivos que não devem ser commitados:

```
# Ambiente
.env
.env.local
.env.*.local

# Python
__pycache__/
*.pyc
*.pyo
.venv/
venv/

# Node
node_modules/
dist/
.vite/

# IDEs
.vscode/
.idea/
*.swp

# Sistema
.DS_Store
Thumbs.db

# Alembic (não commitar versões sem revisão)
# alembic/versions/*.py  ← manter commitados após revisão

# Logs locais
*.log
```

---

*EasyWard v0.1*
