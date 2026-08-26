# EasyWard — Roadmap

## Objetivo

Definir a ordem de desenvolvimento do EasyWard, priorizando o que precisa estar pronto para o sistema ser minimamente utilizável, e evoluindo progressivamente.

---

## Critério de Priorização

1. **Fundação** — sem isso nada funciona
2. **MVP** — o mínimo para uma ala usar o sistema no dia a dia
3. **Completo** — todas as funcionalidades planejadas
4. **Expansão** — melhorias e funcionalidades adicionais

---

## Fase 0 — Fundação (pré-requisito para tudo)

**Meta:** ambiente configurado, banco funcionando, autenticação operacional.

### Backend
- [X] Estrutura de pastas do projeto (conforme `docs/estrutura-pastas.md`)
- [X] Configuração do FastAPI com CORS, middleware e exception handlers
- [X] Conexão com o banco de dados (SQLAlchemy async + asyncpg)
- [X] Aplicação do schema SQL (`docs/schema.sql`)
- [ ] Aplicação dos seeds globais (`docs/schema.sql` — seção seeds)
- [ ] Configuração do Alembic para migrações
- [X] Endpoint de health check (`GET /api/v1/health`)
- [ ] Módulo `auth`: login, logout, refresh token
- [ ] Middleware de autenticação JWT (`get_current_user`)
- [ ] Sistema de permissões (`require_permission`)
- [X] Log estruturado com structlog
- [ ] Integração com Sentry

### Frontend
- [ ] Estrutura de pastas do projeto (conforme `docs/estrutura-pastas.md`)
- [ ] Configuração do Vite + TypeScript + React Router
- [ ] Instância Axios com interceptor de refresh token
- [ ] Store Zustand de autenticação
- [ ] Tela de login
- [ ] Rota protegida (`PrivateRoute`)
- [ ] Layout base (AppShell, Sidebar, BottomNav mobile)
- [ ] Componentes UI base (Button, Input, Modal, Table, Alert, Loader)
- [ ] Design tokens CSS (`docs/design.md`)

### Infraestrutura
- [X] Repositório GitHub criado com estrutura de branches (main, develop)
- [X] Deploy automático configurado (Vercel + Render)
- [X] Projeto Supabase criado (dev + produção)
- [ ] Variáveis de ambiente configuradas em todos os serviços
- [ ] UptimeRobot configurado
- [X] Template de PR (`.github/PULL_REQUEST_TEMPLATE.md`)

**Entrega:** sistema no ar, login funcionando, sem nenhuma funcionalidade de negócio.

---

## Fase 1 — MVP (sistema utilizável)

**Meta:** uma ala consegue cadastrar membros, lançar frequência e ver relatório semanal.

### Onboarding
- [ ] Endpoint `POST /auth/register/new-ward` (cria ala + membro + usuário)
- [ ] Endpoint `POST /auth/register/existing-ward` (cria usuário em ala existente)
- [ ] Seeds por ala ao criar via `ward_seed_service.py` (5 org. principais, 8 org. auxiliares, 113 chamados, 4 grupos de orçamento, config) — `docs/modelo-dados-seed.md` + `docs/seeds-organizacoes.sql` + `docs/seeds-chamados.sql`
- [ ] Tela de onboarding no frontend (3 passos)
- [ ] Filtro estado → estaca → ala no onboarding

### Estrutura base
- [ ] CRUD de alas (`GET /wards/me`, `PUT /wards/me`)
- [ ] CRUD de famílias
- [ ] CRUD de membros (com soft delete e filtros)
- [ ] CRUD de visitantes
- [ ] Listagem de organizações (principais e auxiliares — globais + locais da ala)
- [ ] Listagem de chamados (globais + locais)

### Frequência
- [ ] CRUD de reuniões sacramentais (informações gerais)
- [ ] Lançamento de frequência em lote
- [ ] Consulta de frequência por reunião
- [ ] Cálculo de ausência prolongada

### Relatório semanal
- [ ] Job semanal (GitHub Actions + endpoint)
- [ ] Geração do relatório semanal
- [ ] Persistência do relatório na tabela `relatorios`
- [ ] Tela de relatório semanal no frontend

### Usuários e permissões
- [ ] Listagem e edição de permissões de usuários
- [ ] Proteção da permissão `manage_user_permissions`

### Dashboard
- [ ] Painel inicial com indicadores básicos (frequência, tarefas pendentes, limpeza)

**Entrega:** sistema utilizável por uma ala real para as rotinas semanais essenciais.

---

## Fase 2 — Funcionalidades Operacionais

**Meta:** ata completa da reunião sacramental, tarefas, entrevistas e limpeza.

### Reunião Sacramental (ata completa)
- [ ] Módulo de boas-vindas
- [ ] Módulo de reconhecimentos
- [ ] Módulo de anúncios
- [ ] Módulo de assuntos da estaca e da ala
- [ ] Módulo de músicas (com busca de hinos)
- [ ] Módulo de mensagens e discursos
- [ ] Seeds de hinos (`docs/seeds-hinos.sql`)
- [ ] Telas completas no frontend

### Tarefas do Bispado
- [ ] CRUD de tarefas com responsável e prazo
- [ ] Conclusão de tarefas
- [ ] Listagem com filtros no frontend

### Entrevistas
- [ ] CRUD de entrevistas com tipo, data, status e entrevistador
- [ ] Listagem de entrevistas pendentes
- [ ] Telas no frontend

### Limpeza
- [ ] CRUD de grupos de limpeza
- [ ] Cálculo de rotação semanal
- [ ] Aviso de limpeza no relatório e dashboard

### Relatórios mensais e trimestrais
- [ ] Job mensal (GitHub Actions + endpoint)
- [ ] Job trimestral (GitHub Actions + endpoint)
- [ ] **Job anual** — recálculo de organização de todos os membros na virada de ano (1º de janeiro)
- [ ] Geração dos relatórios mensal e trimestral
- [ ] Telas no frontend
- [ ] Histórico de relatórios

**Entrega:** sistema completo para uso nas rotinas semanais e mensais da ala.

---

## Fase 3 — Funcionalidades Complementares

**Meta:** orçamento, outras reuniões, notificações e refinamentos.

### Orçamento
- [ ] CRUD de orçamentos trimestrais
- [ ] Cálculo de distribuição por **grupo de orçamento** (com suporte a grupos compostos, ex: Jovens = Rapazes + Moças)
- [ ] Tela de orçamento no frontend

### Outras Reuniões
- [ ] CRUD de reunião de bispado (com participantes, assuntos, designações)
- [ ] CRUD de reunião de conselho da ala
- [ ] Telas no frontend

### Notificações
- [ ] Tabelas `notifications` e `fcm_tokens`
- [ ] Serviço de notificações em tela
- [ ] Sino de notificações no frontend
- [ ] Integração com Resend (e-mails)
- [ ] Integração com FCM (push)
- [ ] Registro do token FCM no frontend

### Monitoramento
- [ ] Tabela `audit_logs` com registro automático nas operações críticas
- [ ] Tabela `job_execution_logs`

### Backup
- [ ] Workflow de backup (`docs/backup.md`)
- [ ] Configuração do rclone com Google Drive
- [ ] Teste de restauração

**Entrega:** sistema completo com todas as funcionalidades planejadas.

---

## Fase 4 — Qualidade e Expansão

**Meta:** testes, refinamentos de UX e funcionalidades extras.

### Qualidade
- [ ] Testes unitários dos services principais (cobertura ≥ 80%)
- [ ] Testes de integração dos endpoints críticos
- [ ] CI com testes automáticos no GitHub Actions
- [ ] PWA completo (manifest, service worker, cache offline)

### UX e Refinamentos
- [ ] Exportação de relatórios em PDF
- [ ] Filtros avançados em todas as listagens
- [ ] Busca global
- [ ] Modo de impressão das atas

### Gerenciamento de Dados
- [ ] Tela de configurações da ala (organizações locais auxiliares, chamados locais, hinos locais, grupos de orçamento locais)
- [ ] Parâmetro de ausência prolongada configurável por ala
- [ ] Purge automático de notificações e logs antigos

**Entrega:** sistema robusto, testado e pronto para crescer.

---

## Resumo das Fases

| Fase | Foco | Resultado |
|---|---|---|
| 0 — Fundação | Infraestrutura e autenticação | Sistema no ar |
| 1 — MVP | Membros, frequência, relatório semanal | Utilizável por uma ala |
| 2 — Operacional | Ata, tarefas, entrevistas, limpeza | Rotinas completas |
| 3 — Complementar | Orçamento, outras reuniões, notificações | Sistema completo |
| 4 — Qualidade | Testes, UX, exportações | Sistema robusto |

---

## Ordem Recomendada para Começar

Se for desenvolver sozinho, esta é a ordem mais eficiente para ter algo funcional rapidamente:

1. Fase 0 completa (fundação)
2. Onboarding (criar ala + login)
3. Cadastro de membros
4. Lançamento de frequência
5. Relatório semanal básico
6. → **Testar com uma ala real antes de continuar**
7. Ata da reunião sacramental
8. Tarefas e entrevistas
9. Demais fases na ordem

> O ponto crítico é chegar ao passo 6 o mais rápido possível. Feedback real de uso vale mais do que funcionalidades planejadas.

---

*EasyWard v0.1*
