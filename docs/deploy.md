# EasyWard — Deploy

## 1. Objetivo

Descrever a publicação do sistema com foco em serviços gratuitos, sem cartão de crédito.

---

## 2. Serviços

| Componente | Serviço |
|---|---|
| Frontend | Vercel Free |
| Backend | Render Free |
| Banco de dados | Supabase Free |
| Repositório | GitHub |
| Jobs e backup | GitHub Actions |

---

## 3. Ambientes

O projeto opera com dois ambientes:

| Ambiente | Frontend | Backend | Banco |
|---|---|---|---|
| **Desenvolvimento** | `localhost:5173` (Vite) | `localhost:8000` (Uvicorn) | Supabase (projeto dev separado) |
| **Produção** | Vercel | Render | Supabase (projeto produção) |

> Use projetos Supabase separados para cada ambiente. Isso evita que dados de teste contaminem dados reais.

> Homologação formal não é viável no Render Free (apenas uma instância gratuita). Validações são feitas localmente antes do merge para `main`.

---

## 4. Estratégia de Branches

| Branch | Finalidade | Deploy |
|---|---|---|
| `main` | Produção — código estável | Deploy automático (Vercel + Render) |
| `develop` | Integração de funcionalidades | Sem deploy automático |
| `feature/*` | Desenvolvimento de funcionalidade | Sem deploy |
| `fix/*` | Correções | Sem deploy |

Fluxo: `feature/*` → PR para `develop` → revisão → merge → PR para `main` → deploy.

---

## 5. Variáveis de Ambiente

### Backend (Render)

| Variável | Descrição |
|---|---|
| `DATABASE_URL` | String de conexão PostgreSQL (Supabase) |
| `JWT_SECRET` | Chave secreta para assinar access tokens JWT |
| `JWT_REFRESH_SECRET` | Chave secreta para refresh tokens JWT |
| `JOB_SECRET` | Token fixo para autenticar chamadas dos jobs via GitHub Actions |
| `APP_ENV` | `production` ou `development` |
| `RESEND_API_KEY` | Chave da API do Resend (e-mail) |
| `FIREBASE_CREDENTIALS` | JSON de credenciais do Firebase Admin SDK (FCM push) |
| `SENTRY_DSN` | DSN do projeto no Sentry |
| `CORS_ORIGINS` | Origens permitidas (URL do frontend Vercel) |

### Frontend (Vercel)

| Variável | Descrição |
|---|---|
| `VITE_API_URL` | URL base da API (ex: `https://easyward-api.onrender.com/api/v1`) |
| `VITE_APP_ENV` | `production` ou `development` |
| `VITE_FIREBASE_API_KEY` | API key do projeto Firebase |
| `VITE_FIREBASE_PROJECT_ID` | ID do projeto Firebase |
| `VITE_FIREBASE_MESSAGING_SENDER_ID` | Sender ID do FCM |
| `VITE_FIREBASE_APP_ID` | App ID do Firebase |
| `VITE_FIREBASE_VAPID_KEY` | Chave VAPID para push web (PWA) |

---

## 6. Fluxo de Deploy

```
1. Desenvolvedor faz push na branch main
         │
2. GitHub Actions executa verificações (lint, testes)
         │
3. Vercel detecta o push → build do frontend → publicação automática
         │
4. Render detecta o push → build do backend → publicação automática
         │
5. Aplicar migrações do banco (Alembic):
   alembic upgrade head
   (executado manualmente ou via script pós-deploy)
         │
6. Verificar health check: GET /api/v1/health
         │
7. Smoke test manual nas funcionalidades críticas
         │
8. Deploy concluído
```

---

## 7. Migrações de Banco

Ferramenta: **Alembic** (integrado ao SQLAlchemy/FastAPI)

```bash
# Criar nova migração
alembic revision --autogenerate -m "descricao_da_mudanca"

# Aplicar migrações pendentes
alembic upgrade head

# Reverter última migração (rollback)
alembic downgrade -1
```

> ⚠️ Sempre gerar backup manual antes de aplicar migrações em produção.

---

## 8. Rollback

| Situação | Ação |
|---|---|
| Bug no frontend | Revert do commit + push na `main` (Vercel republica automaticamente) |
| Bug no backend | Revert do commit + push na `main` (Render republica automaticamente) |
| Migração com problema | `alembic downgrade -1` + revert do commit |
| Dados corrompidos | Restaurar backup via procedimento do `docs/backup.md` |

---

## 9. Health Check

O backend expõe um endpoint de health check usado pelo Render para verificar se o serviço subiu corretamente e pelo UptimeRobot para monitoramento contínuo:

```
GET /api/v1/health
```

Resposta esperada:
```json
{
  "status": "ok",
  "environment": "production",
  "database": "connected"
}
```

---

## 10. Cold Start

O Render Free hiberna o backend após ~15 minutos de inatividade. O UptimeRobot pinga `/api/v1/health` a cada 5 minutos, evitando a hibernação.

Se mesmo assim ocorrer um cold start (ex: primeiro acesso do dia muito cedo), o frontend deve exibir um indicador de carregamento enquanto o backend acorda (pode levar até 60 segundos).

---

## 11. Configuração Inicial dos Serviços

### Supabase
1. Criar projeto em [supabase.com](https://supabase.com)
2. Copiar a `DATABASE_URL` em Settings → Database → Connection string
3. Executar o script SQL inicial (`docs/schema.sql`)
4. Executar o script de seeds (`docs/seeds.sql`)

### Render
1. Criar Web Service apontando para o repositório GitHub
2. Configurar variáveis de ambiente
3. Definir o comando de start: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
4. Configurar health check path: `/api/v1/health`

### Vercel
1. Importar repositório GitHub
2. Configurar variáveis de ambiente
3. Definir o diretório raiz do frontend (ex: `frontend/`)
4. Deploy automático configurado por padrão

### UptimeRobot
1. Criar monitor HTTP apontando para `https://{url-do-render}/api/v1/health`
2. Intervalo: 5 minutos
3. Configurar alerta por e-mail

---

*EasyWard v0.1*
