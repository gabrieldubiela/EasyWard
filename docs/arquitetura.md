# EasyWard — Arquitetura

## 1. Objetivo

Definir a estrutura técnica do sistema EasyWard, descrevendo camadas, componentes, fluxos de comunicação, segurança e infraestrutura.

---

## 2. Visão em Camadas

```
┌─────────────────────────────────────────────┐
│           APRESENTAÇÃO (Frontend)           │
│   React + TypeScript + Vite + PWA           │
│   Vercel Free                               │
└─────────────────┬───────────────────────────┘
                  │ HTTPS / REST (JSON)
                  │ Authorization: Bearer <access_token>
                  │ Cookie: refresh_token (httpOnly)
┌─────────────────▼───────────────────────────┐
│              API (Backend)                  │
│   Python + FastAPI                          │
│   JWT, regras de negócio, validação,        │
│   relatórios, notificações, jobs            │
│   Render Free                               │
└──────┬──────────────────────────────────────┘
       │ asyncpg / SQLAlchemy
       │ DATABASE_URL (env var)
┌──────▼──────────────┐   ┌────────────────────┐
│  PERSISTÊNCIA       │   │  SERVIÇOS EXTERNOS │
│  PostgreSQL         │   │  Resend (e-mail)   │
│  Supabase Free      │   │  FCM (push)        │
└─────────────────────┘   │  Google Drive      │
                          │  (backup)          │
┌─────────────────────┐   └────────────────────┘
│  AUTOMAÇÃO          │
│  GitHub Actions     │
│  (cron → API)       │
└─────────────────────┘
```

---

## 3. Componentes Principais

### 3.1 Frontend
- Exibição de telas, formulários e relatórios
- Consumo da API via Axios com interceptor de refresh token
- Controle de navegação (React Router)
- Estado global com Zustand
- Formulários com React Hook Form + Zod
- PWA: instalável no celular, suporte a cache offline via service worker

### 3.2 Backend
- Autenticação e autorização por permissões granulares
- Processamento de todos os módulos (membros, frequência, reuniões, tarefas, entrevistas, limpeza, orçamento)
- Geração de relatórios
- Envio de notificações (push e e-mail)
- Exposição de endpoints para disparo manual de jobs

### 3.3 Banco de Dados
- PostgreSQL no Supabase Free
- Acesso exclusivo pelo backend via `DATABASE_URL`
- Sem uso do SDK do Supabase — PostgreSQL puro
- Integridade referencial com chaves estrangeiras e constraints

### 3.4 Jobs (Automação)
- Executados pelo **GitHub Actions** via cron
- O Actions chama um endpoint autenticado da API (`POST /api/v1/jobs/{nome}/run`)
- O backend acorda (resolvendo o cold start do Render) e processa o job
- Logs de execução registrados na tabela `job_execution_logs`

---

## 4. Hierarquia Organizacional

```
Brasil
└── Estado (seed fixo — 27 UFs)
    └── Estaca (criada pelo usuário no onboarding)
        └── Ala (criada pelo usuário no onboarding)
            └── Bispado (organização interna da ala)
```

Cada ala é completamente isolada. Nenhum usuário acessa dados de outra ala.

---

## 5. Fluxo de Onboarding

### 5.1 Criação de nova ala
1. Usuário acessa o sistema sem conta e escolhe "criar nova ala"
2. Seleciona estado → estaca (existente ou nova) → nome da ala
3. Preenche seus próprios dados como membro
4. Sistema cria: estaca (se nova) → ala → seeds (hinos, organizações, chamados padrão) → membro → usuário
5. Primeiro usuário recebe todas as permissões automaticamente

### 5.2 Cadastro em ala existente
1. Usuário acessa o sistema sem conta e escolhe "criar conta"
2. Filtra por estado → estaca → seleciona ala
3. Informa nome completo e credenciais
4. Sistema verifica se o nome completo existe na lista de membros da ala
5. Se existir → conta criada sem nenhuma permissão
6. Se não existir → erro: "você precisa ser cadastrado como membro antes de criar uma conta"

---

## 6. Autenticação

- Login retorna `access_token` (JWT, 30 min) e `refresh_token` (JWT, 7 dias)
- `access_token` enviado no header `Authorization: Bearer <token>`
- `refresh_token` armazenado em cookie `httpOnly` (não acessível via JavaScript — mais seguro)
- Ao expirar o access token, o frontend chama `POST /api/v1/auth/refresh` automaticamente via interceptor Axios
- Logout invalida o refresh token no servidor (tabela `refresh_tokens`)

---

## 7. Permissões

O sistema usa **permissões granulares por função**, sem perfis fixos. Cada usuário recebe um conjunto individual de permissões. Ver [docs/permissoes.md](permissoes.md) para a lista completa.

Proteção especial: a permissão "gerir permissões de usuários" só pode ser revogada se outro usuário da mesma ala também a possuir, e exige aprovação ativa desse usuário.

---

## 8. Seeds Automáticos por Ala

Ao criar uma nova ala, o sistema insere automaticamente:

| Seed | Origem | Editável? |
|---|---|---|
| Hinos do hinário padrão | Global (`origem = 'global'`) | Não — mas novos podem ser adicionados |
| Organizações padrão (Soc. de Socorro, Sacerdócio, etc.) | Global | Não — mas novas podem ser adicionadas |
| Chamados padrão (Bispo, Conselheiro, etc.) | Global | Podem ser inativados, mas não editados |

Itens criados pelo usuário ficam marcados como `origem = 'local'` e pertencem exclusivamente à ala.

---

## 9. Módulos do Backend

| Módulo | Responsabilidade |
|---|---|
| `auth` | Login, logout, refresh token, onboarding |
| `users` | Gestão de usuários e permissões |
| `wards` | Dados da ala, estacas, estados |
| `families` | Famílias |
| `members` | Membros (com soft delete) |
| `visitors` | Visitantes |
| `organizations` | Organizações |
| `callings` | Chamados |
| `cleaning` | Grupos de limpeza e escala |
| `meetings` | Reunião sacramental (ata completa) |
| `bishopric_meetings` | Reunião de bispado |
| `ward_council` | Reunião de conselho da ala |
| `attendance` | Frequência |
| `tasks` | Tarefas do bispado |
| `interviews` | Entrevistas |
| `budget` | Orçamento trimestral |
| `reports` | Relatórios consolidados com persistência em banco |
| `jobs` | Execução e histórico de automações |
| `notifications` | Push (FCM), e-mail (Resend) e notificações em tela |

---

## 10. Infraestrutura e Cold Start

| Problema | Solução |
|---|---|
| Render Free hiberna após 15 min | UptimeRobot pinga `GET /api/v1/health` a cada 5 min |
| Supabase pausa após 7 dias | UptimeRobot mantém o backend ativo, que mantém o banco ativo |
| Jobs não disparam em backend hibernado | GitHub Actions chama o endpoint — o ping acorda o backend antes |

---

## 11. Ambientes

| Ambiente | Frontend | Backend | Banco |
|---|---|---|---|
| Desenvolvimento | `localhost:5173` | `localhost:8000` | Supabase (projeto separado de dev) |
| Produção | Vercel | Render | Supabase (projeto de produção) |

> Use projetos Supabase separados para dev e produção para evitar contaminação de dados.

---

## 12. CI/CD

- Push na branch `main` → deploy automático no Vercel (frontend) e Render (backend)
- GitHub Actions executa jobs automáticos via cron
- GitHub Actions executa backup diário via cron

---

*EasyWard v0.1*
