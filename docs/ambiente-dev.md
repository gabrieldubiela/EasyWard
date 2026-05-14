# EasyWard — Ambiente de Desenvolvimento

## 1. Objetivo

Guia para configurar o ambiente local do EasyWard do zero, sem depender de serviços externos pagos durante o desenvolvimento.

---

## 2. Pré-requisitos

Instale as seguintes ferramentas antes de começar:

| Ferramenta | Versão mínima | Download |
|---|---|---|
| Git | 2.x | https://git-scm.com |
| Node.js | 20.x (LTS) | https://nodejs.org |
| Python | 3.11+ | https://python.org |
| Docker Desktop | 4.x | https://docker.com/products/docker-desktop |
| VS Code (recomendado) | — | https://code.visualstudio.com |

Verificar instalações:
```bash
git --version
node --version
python --version
docker --version
```

---

## 3. Clonar o Repositório

```bash
git clone https://github.com/seu-usuario/easyward.git
cd easyward
```

---

## 4. Banco de Dados Local (PostgreSQL via Docker)

Em vez de usar o Supabase durante o desenvolvimento, suba um PostgreSQL local com Docker:

```bash
docker run -d \
  --name easyward-db \
  -e POSTGRES_USER=easyward \
  -e POSTGRES_PASSWORD=easyward \
  -e POSTGRES_DB=easyward_dev \
  -p 5432:5432 \
  postgres:16
```

Verificar se está rodando:
```bash
docker ps
```

String de conexão local:
```
postgresql+asyncpg://easyward:easyward@localhost:5432/easyward_dev
```

Para parar e iniciar novamente:
```bash
docker stop easyward-db
docker start easyward-db
```

---

## 5. Configurar o Backend

### 5.1 Criar ambiente virtual Python

```bash
cd backend
python -m venv venv

# Ativar no Linux/macOS
source venv/bin/activate

# Ativar no Windows (PowerShell)
venv\Scripts\Activate.ps1
```

### 5.2 Instalar dependências

```bash
pip install -r requirements.txt
```

### 5.3 Criar arquivo de variáveis de ambiente

Copiar o modelo:
```bash
cp .env.example .env
```

Editar `.env` com os valores locais:
```env
# Banco de dados
DATABASE_URL=postgresql+asyncpg://easyward:easyward@localhost:5432/easyward_dev

# JWT
JWT_SECRET=dev_secret_key_mude_em_producao
JWT_REFRESH_SECRET=dev_refresh_secret_mude_em_producao

# Jobs (qualquer valor para dev)
JOB_SECRET=dev_job_secret

# Ambiente
APP_ENV=development

# E-mail (deixar em branco para não enviar em dev)
RESEND_API_KEY=

# Firebase (deixar em branco para não enviar push em dev)
FIREBASE_CREDENTIALS=

# Sentry (deixar em branco para não reportar em dev)
SENTRY_DSN=

# CORS
CORS_ORIGINS=http://localhost:5173
```

### 5.4 Aplicar o schema e seeds

```bash
# Aplicar schema completo
psql postgresql://easyward:easyward@localhost:5432/easyward_dev -f ../docs/schema.sql

# (Opcional) Seeds de hinos
psql postgresql://easyward:easyward@localhost:5432/easyward_dev -f ../docs/seeds-hinos.sql

# Nota: seeds-organizacoes.sql e seeds-chamados.sql são executados automaticamente pelo backend
# ao criar uma nova ala (ward_seed_service.py). Não rodar manualmente.
# Eles estão em /docs/ apenas como documentação de referência.
```

### 5.5 Configurar e aplicar migrações com Alembic

```bash
# Inicializar o Alembic (apenas na primeira vez)
alembic init alembic

# Gerar migração inicial (apenas na primeira vez, após o schema já ter sido aplicado)
alembic revision --autogenerate -m "initial"

# Aplicar migrações
alembic upgrade head
```

### 5.6 Rodar o backend

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

O backend estará disponível em:
- API: http://localhost:8000
- Documentação interativa (Swagger): http://localhost:8000/docs
- Documentação alternativa (ReDoc): http://localhost:8000/redoc

---

## 6. Configurar o Frontend

### 6.1 Instalar dependências

```bash
cd frontend
npm install
```

### 6.2 Criar arquivo de variáveis de ambiente

```bash
cp .env.example .env
```

Editar `.env`:
```env
VITE_API_URL=http://localhost:8000/api/v1
VITE_APP_ENV=development

# Firebase (opcional em dev — push não funcionará sem configuração)
VITE_FIREBASE_API_KEY=
VITE_FIREBASE_PROJECT_ID=
VITE_FIREBASE_MESSAGING_SENDER_ID=
VITE_FIREBASE_APP_ID=
VITE_FIREBASE_VAPID_KEY=
```

### 6.3 Rodar o frontend

```bash
npm run dev
```

O frontend estará disponível em: http://localhost:5173

---

## 7. Extensões Recomendadas para VS Code

Instalar via VS Code ou via linha de comando:

```bash
# Python
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance

# Frontend
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension bradlc.vscode-tailwindcss

# Banco de dados
code --install-extension cweijan.vscode-postgresql-client2

# Geral
code --install-extension eamodio.gitlens
code --install-extension yzhang.markdown-all-in-one
```

---

## 8. Scripts Úteis

### Backend

```bash
# Rodar com hot reload
uvicorn app.main:app --reload --port 8000

# Rodar testes
pytest tests/

# Rodar testes com cobertura
pytest --cov=app tests/

# Formatar código
black app/
isort app/

# Verificar tipos
mypy app/

# Criar nova migração
alembic revision --autogenerate -m "nome_da_mudanca"

# Aplicar migrações
alembic upgrade head

# Reverter última migração
alembic downgrade -1

# Ver histórico de migrações
alembic history
```

### Frontend

```bash
# Rodar em desenvolvimento
npm run dev

# Build de produção
npm run build

# Preview do build
npm run preview

# Verificar tipos TypeScript
npm run type-check

# Lint
npm run lint

# Formatar código
npm run format
```

### Docker (banco de dados)

```bash
# Iniciar banco
docker start easyward-db

# Parar banco
docker stop easyward-db

# Acessar banco via psql
docker exec -it easyward-db psql -U easyward -d easyward_dev

# Ver logs do banco
docker logs easyward-db

# Apagar banco e recriar do zero
docker rm -f easyward-db
# (repetir o comando docker run da seção 4)
```

---

## 9. Fluxo de Desenvolvimento

```
1. Criar branch a partir de develop
   git checkout develop
   git pull
   git checkout -b feature/nome-da-feature

2. Desenvolver e testar localmente

3. Rodar testes antes do commit
   pytest tests/         (backend)
   npm run type-check    (frontend)

4. Commitar com mensagem descritiva
   git commit -m "feat: adiciona cadastro de visitantes"

5. Abrir PR para develop
   - Descrever o que foi feito
   - Referenciar a funcionalidade ou correção

6. Após aprovação, merge para develop

7. Quando estável, PR de develop para main
   → Deploy automático em produção
```

### Convenção de mensagens de commit

| Prefixo | Uso |
|---|---|
| `feat:` | Nova funcionalidade |
| `fix:` | Correção de bug |
| `docs:` | Alteração em documentação |
| `refactor:` | Refatoração sem mudança de comportamento |
| `test:` | Adição ou correção de testes |
| `chore:` | Tarefas de manutenção (deps, config) |

---

## 10. Acessar o Banco Localmente (Interface Visual)

Além do `psql`, você pode usar ferramentas visuais:

| Ferramenta | Tipo | Download |
|---|---|---|
| DBeaver | Desktop (gratuito) | https://dbeaver.io |
| TablePlus | Desktop (gratuito limitado) | https://tableplus.com |
| Extensão VS Code | No próprio editor | `cweijan.vscode-postgresql-client2` |

Dados de conexão local:
```
Host:     localhost
Port:     5432
Database: easyward_dev
User:     easyward
Password: easyward
```

---

## 11. Simulando Jobs Localmente

Para testar um job sem esperar o GitHub Actions, chame o endpoint diretamente:

```bash
# Job semanal
curl -X POST http://localhost:8000/api/v1/jobs/weekly/run \
  -H "Authorization: Bearer dev_job_secret"

# Job mensal
curl -X POST http://localhost:8000/api/v1/jobs/monthly/run \
  -H "Authorization: Bearer dev_job_secret"
```

---

## 12. Problemas Comuns

**Backend não conecta ao banco:**
- Verificar se o container Docker está rodando: `docker ps`
- Verificar se `DATABASE_URL` no `.env` está correto
- Verificar se a porta 5432 não está ocupada por outro processo

**Frontend não conecta à API:**
- Verificar se o backend está rodando na porta 8000
- Verificar se `VITE_API_URL` no `.env` está correto (`http://localhost:8000/api/v1`)
- Verificar se o CORS está configurado para aceitar `http://localhost:5173`

**Erro de migração Alembic:**
- Verificar se o banco está acessível
- Verificar se a versão do Alembic bate com o estado do banco: `alembic current`
- Em desenvolvimento, é seguro apagar o banco e recriar do zero

**`npm install` falha:**
- Verificar versão do Node: `node --version` (precisa ser 20.x+)
- Tentar limpar cache: `npm cache clean --force && npm install`

---

*EasyWard v0.1*
